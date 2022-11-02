output "address" {
  value       = aws_alb.nlb.dns_name
  description = "DNS name of the load balancer (example: `banyan-nlb-b335ff082d3b27ff.elb.us-east-1.amazonaws.com`)"
}

output "nlb_zone_id" {
  value       = aws_alb.nlb.zone_id
  description = "Zone ID of the load balancer (example: `Z26RNL4JYFTOTI`)"
}

output "security_group_id" {
  value       = aws_security_group.sg.id
  description = "The ID of the security group, which can be added as an inbound rule on other backend groups (example: `sg-1234abcd`)"
}

output "sg" {
  value       = aws_security_group.sg
  description = "The `aws_security_group.sg` resource"
}

output "asg" {
  value       = aws_autoscaling_group.asg
  description = "The `aws_autoscaling_group.asg` resource"
}

output "nlb" {
  value       = aws_alb.nlb
  description = "The `aws_alb.nlb` resource"
}

output "target443" {
  value       = aws_lb_target_group.target443
  description = "The `aws_lb_target_group.target443` resource"
}

output "target8443" {
  value       = aws_lb_target_group.target8443
  description = "The `aws_lb_target_group.target8443` resource"
}

output "target80" {
  value       = aws_lb_target_group.target80
  description = "The `aws_lb_target_group.target80` resource"
}

output "listener443" {
  value       = aws_lb_listener.listener443
  description = "The `aws_lb_listener.listener443` resource"
}

output "listener8443" {
  value       = aws_lb_listener.listener8443
  description = "The `aws_lb_listener.listener8443` resource"
}

output "listener80" {
  value       = aws_lb_listener.listener80
  description = "The `aws_lb_listener.listener80` resource"
}

output "cpu_policy" {
  value       = aws_autoscaling_policy.cpu_policy
  description = "The `aws_autoscaling_policy.cpu_policy` resource"
}

output "name" {
  value       = var.name
  description = "Name to use when registering this Access Tier with the console"
}