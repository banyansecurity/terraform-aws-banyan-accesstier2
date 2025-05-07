locals {
  tags = merge(var.tags, {
    Provider = "BanyanOps"
  })

  asg_tags = merge(local.tags, {
    Name = "${var.name}${var.autoscaling_group_name_tag_label}-accesstier"
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "sg" {
  name        = "${var.name}-accesstier${var.security_group_label}"
  description = "Elastic Access Tier ingress traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.redirect_http_to_https ? [true] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Redirect to 443"
    }
  }

  dynamic "ingress" {
    for_each = var.management_cidrs != null ? [true] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.management_cidrs
      description = "Management SSH"
    }
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Web traffic"
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Infra traffic"
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Service tunnel traffic"
  }

  ingress {
    from_port   = 9998
    to_port     = 9998
    protocol    = "tcp"
    cidr_blocks = var.healthcheck_cidrs
    description = "Healthcheck"
  }

  egress {
    from_port   = var.shield_port # shield_port defaults to 0
    to_port     = var.shield_port != 0 ? var.shield_port : 65535
    protocol    = "tcp"
    cidr_blocks = var.shield_cidrs
    description = "Shield (Cluster Coordinator)"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = distinct(concat(var.command_center_cidrs, var.trustprovider_cidrs))
    description = "Command Center and TrustProvider"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.managed_internal_cidrs
    description = "Managed internal services"
  }

  tags = merge(local.tags, var.security_group_tags)
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name}-accesstier${var.autoscaling_group_label}"
  max_size                  = var.max_instances
  min_size                  = var.min_instances
  desired_capacity          = var.min_instances
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = compact([join("", aws_lb_target_group.target80.*.arn), aws_lb_target_group.target443.arn, aws_lb_target_group.target8443.arn, aws_lb_target_group.target51820.arn, aws_lb_target_group.target9998.arn])
  max_instance_lifetime     = var.max_instance_lifetime
  enabled_metrics           = var.enabled_metrics

  launch_template {
    id      = aws_launch_template.conft.id
    version = aws_launch_template.conft.latest_version
  }

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 200
  }

  dynamic "tag" {
    # do another merge for application specific tags if need-be
    for_each = merge(local.asg_tags, var.autoscaling_group_tags)

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh ? [1] : []

    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage       = 100
        max_healthy_percentage       = 200
        instance_warmup              = 300
        scale_in_protected_instances = "Ignore"
        skip_matching                = true
        standby_instances            = "Ignore"
      }
    }
  }
}

resource "aws_launch_template" "conft" {
  name_prefix            = "${var.name}-accesstier${var.autoscaling_launch_label}-"
  image_id               = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = concat([aws_security_group.sg.id], var.member_security_groups)
  ebs_optimized          = true

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [1] : []
    content {
      name = var.iam_instance_profile
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type = "gp3"
      volume_size = 10
      encrypted = var.ebs_encrypted
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      device_name = "/dev/sda1"

      ebs {
        volume_type = "gp3"
        volume_size = 10
        encrypted = var.ebs_encrypted
        kms_key_id  = var.kms_key_arn
      }
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = var.http_endpoint_imds_v2
    http_tokens                 = var.http_tokens_imds_v2
    http_put_response_hop_limit = var.http_hop_limit_imds_v2
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(join("", concat([
    "#!/bin/bash -ex\n",
    # increase file handle limits
    "echo '* soft nofile 100000' >> /etc/security/limits.d/banyan.conf\n",
    "echo '* hard nofile 100000' >> /etc/security/limits.d/banyan.conf\n",
    "echo 'fs.file-max = 100000' >> /etc/sysctl.d/90-banyan.conf\n",
    "sysctl -w fs.file-max=100000\n",
    # increase conntrack hashtable limits
    "echo 'options nf_conntrack hashsize=65536' >> /etc/modprobe.d/banyan.conf\n",
    "modprobe nf_conntrack\n",
    "echo '65536' > /proc/sys/net/netfilter/nf_conntrack_buckets\n",
    "echo '262144' > /proc/sys/net/netfilter/nf_conntrack_max\n",
    # install dogstatsd (if requested)
    var.datadog_api_key != null ? "curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh | DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${var.datadog_api_key} DD_SITE=datadoghq.com bash -v\n" : "",
    # install prerequisites and Banyan netagent
    "curl https://www.banyanops.com/onramp/deb-repo/banyan.key | apt-key add -\n",
    "apt-add-repository \"deb https://www.banyanops.com/onramp/deb-repo xenial main\"\n",
    var.netagent_version != null ? "apt-get update && apt-get install -y banyan-netagent2=${var.netagent_version} \n" : "apt-get update && apt-get install -y banyan-netagent2 \n",
    # configure and start netagent
    "cd /opt/banyan-packages \n",
    "export ACCESS_TIER_NAME=${banyan_accesstier.accesstier.name} \n",
    "export API_KEY_SECRET=${banyan_api_key.accesstier.secret} \n",
    "export COMMAND_CENTER_URL=${var.banyan_host} \n",
    "./install \n",
  ], var.custom_user_data)))

}

resource "aws_alb" "nlb" {
  name                             = "${var.name}${var.lb_label}"
  load_balancer_type               = "network"
  internal                         = var.lb_internal
  subnets                          = var.lb_internal ? var.private_subnet_ids : var.public_subnet_ids
  enable_cross_zone_load_balancing = var.cross_zone_enabled

  tags = merge(local.tags, var.lb_tags)
}

resource "aws_lb_target_group" "target443" {
  name     = "${var.name}${var.target_group_label}-443"
  vpc_id   = var.vpc_id
  port     = 443
  protocol = "TCP"
  stickiness {
    enabled = var.sticky_sessions
    type    = "source_ip"
  }
  health_check {
    port                = 9998
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, var.target_group_tags)
}

resource "aws_lb_listener" "listener443" {
  load_balancer_arn = aws_alb.nlb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target443.arn
  }
}

resource "aws_lb_target_group" "target80" {
  count = var.redirect_http_to_https ? 1 : 0

  name     = "${var.name}${var.target_group_label}-80"
  vpc_id   = var.vpc_id
  port     = 80
  protocol = "TCP"
  stickiness {
    enabled = var.sticky_sessions
    type    = "source_ip"
  }
  health_check {
    port                = 9998
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, var.target_group_tags)
}

resource "aws_lb_listener" "listener80" {
  count = var.redirect_http_to_https ? 1 : 0

  load_balancer_arn = aws_alb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target80[0].arn
  }
}

resource "aws_lb_target_group" "target8443" {
  name     = "${var.name}${var.target_group_label}-8443"
  vpc_id   = var.vpc_id
  port     = 8443
  protocol = "TCP"
  stickiness {
    enabled = var.sticky_sessions
    type    = "source_ip"
  }
  health_check {
    port                = 9998
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, var.target_group_tags)
}

resource "aws_lb_listener" "listener8443" {
  load_balancer_arn = aws_alb.nlb.arn
  port              = 8443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target8443.arn
  }
}

resource "aws_lb_target_group" "target51820" {
  name     = "${var.name}${var.target_group_label}-51820"
  vpc_id   = var.vpc_id
  port     = 51820
  protocol = "UDP"
  stickiness {
    enabled = var.sticky_sessions
    type    = "source_ip"
  }
  health_check {
    port                = 9998
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, var.target_group_tags)
}

resource "aws_lb_listener" "listener51820" {
  load_balancer_arn = aws_alb.nlb.arn
  port              = 51820
  protocol          = "UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target51820.arn
  }
}

resource "aws_lb_target_group" "target9998" {
  name     = "${var.name}-tg-9998"
  vpc_id   = var.vpc_id
  port     = 9998
  protocol = "TCP"
  stickiness {
    enabled = var.sticky_sessions
    type    = "source_ip"
  }
  health_check {
    port                = 9998
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, var.target_group_tags)
}

resource "aws_lb_listener" "listener9998" {
  load_balancer_arn = aws_alb.nlb.arn
  port              = 9998
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target9998.arn
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${var.name}-cpu${var.autoscaling_policy_label}"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80
  }
}
