# Banyan AWS Access Tier 2 Module

This module creates a [Banyan Access Tier](https://docs.banyansecurity.io/docs/banyan-components/accesstier/) using the Netagent2 binary

Using the Access Tier and api key resources in Banyan, this module creates an AWS auto-scaling group (ASG) and a network load balancer (NLB) on AWS, and associated security groups.

Typically, this module will be deployed into a VPC where remote access via Banyan ZTNA is desired. This module will create an autoscaling group across the `private_subnets` which will deploy instances running the Banyan Netagent2 binary.
A network load balancer will be deployed into the `public_subnets` and is exposed to the internet. This group of infrastructure collectively functions as the Access Tier. Security groups control inbound connections to the Access Tier, and the Access Tier applies policy based ZTNA to services inside of the network.

## Usage

```hcl
provider "banyan" {
  api_key = var.api_key
  host    = var.banyan_host
}

provider "aws" {
  region = "us-east-1"
}

module "aws_accesstier" {
  source                 = "banyan/accesstier2-aws"
  name                   = "aws-terraform-test5"
  api_key                = var.api_key
  banyan_host            = var.banyan_host
  private_subnet_ids     = ["subnet-0e4680444d8fd1f69", "subnet-0bff68824ea1ede35"]
  public_subnet_ids      = ["subnet-0bd9c5568baa33137", "subnet-0a2f69d0f6cdc0b1a"]
  vpc_id                 = "vpc-0c5252fae11fe5011"
  member_security_groups = ["access-tier-allow"]
}
```

## Notes

The default value for `management_cidr` leaves SSH open to the VPC CIDR block for the VPC specified by `vpc_id`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_banyan"></a> [banyan](#requirement\_banyan) | >=0.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_banyan"></a> [banyan](#provider\_banyan) | >=0.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| banyan_accesstier.accesstier | resource |
| banyan_api_key.accesstier | resource |
| [aws_alb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.cpu_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_launch_configuration.conf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_lb_listener.listener443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.listener51820](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.listener80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.listener8443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.target443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.target51820](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.target80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.target8443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | An admin scoped API key to use for authentication to Banyan | `string` | n/a | yes |
| <a name="input_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#input\_autoscaling\_group\_tags) | Additional tags to the autoscaling\_group | `map(any)` | `null` | no |
| <a name="input_banyan_host"></a> [banyan\_host](#input\_banyan\_host) | URL to the Banyan API server | `string` | `"https://net.banyanops.com/"` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Name of an existing Shield cluster to register this Access Tier with. This value is set automatically if omitted from the configuration | `string` | `null` | no |
| <a name="input_command_center_cidrs"></a> [command\_center\_cidrs](#input\_command\_center\_cidrs) | CIDR blocks to allow Command Center connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_console_log_level"></a> [console\_log\_level](#input\_console\_log\_level) | Controls verbosity of logs to console | `any` | `null` | no |
| <a name="input_cross_zone_enabled"></a> [cross\_zone\_enabled](#input\_cross\_zone\_enabled) | Allow load balancer to distribute traffic to other zones | `bool` | `true` | no |
| <a name="input_custom_user_data"></a> [custom\_user\_data](#input\_custom\_user\_data) | Custom commands to append to the launch configuration initialization script. | `list(string)` | `[]` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | API key for DataDog | `string` | `null` | no |
| <a name="input_disable_snat"></a> [disable\_snat](#input\_disable\_snat) | Disable Source Network Address Translation (SNAT) | `bool` | `false` | no |
| <a name="input_enable_hsts"></a> [enable\_hsts](#input\_enable\_hsts) | If enabled, Banyan will send the HTTP Strict-Transport-Security response header | `any` | `null` | no |
| <a name="input_event_key_rate_limiting"></a> [event\_key\_rate\_limiting](#input\_event\_key\_rate\_limiting) | Enable rate limiting of Access Event generated based on a derived “key” value. Each key has a separate rate limiter, and events with the same key value are subjected to the rate limiter for that key | `any` | `null` | no |
| <a name="input_events_rate_limiting"></a> [events\_rate\_limiting](#input\_events\_rate\_limiting) | Enable rate limiting of Access Event generation based on a credit-based rate control mechanism | `any` | `null` | no |
| <a name="input_file_log"></a> [file\_log](#input\_file\_log) | Whether to log to file or not | `any` | `null` | no |
| <a name="input_file_log_level"></a> [file\_log\_level](#input\_file\_log\_level) | Controls verbosity of logs to file | `any` | `null` | no |
| <a name="input_forward_trust_cookie"></a> [forward\_trust\_cookie](#input\_forward\_trust\_cookie) | Forward the Banyan trust cookie to upstream servers. This may be enabled if upstream servers wish to make use of information in the Banyan trust cookie. | `any` | `null` | no |
| <a name="input_groups_by_userinfo"></a> [groups\_by\_userinfo](#input\_groups\_by\_userinfo) | Derive groups information from userinfo endpoint | `bool` | `false` | no |
| <a name="input_healthcheck_cidrs"></a> [healthcheck\_cidrs](#input\_healthcheck\_cidrs) | CIDR blocks to allow health check connections from (recommended to use the VPC CIDR range) | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_host_tags"></a> [host\_tags](#input\_host\_tags) | Additional tags to assign to this Access Tier | `map(any)` | <pre>{<br>  "type": "access_tier"<br>}</pre> | no |
| <a name="input_http_endpoint_imds_v2"></a> [http\_endpoint\_imds\_v2](#input\_http\_endpoint\_imds\_v2) | value for http\_endpoint to enable imds v2 for ec2 instance | `string` | `"enabled"` | no |
| <a name="input_http_hop_limit_imds_v2"></a> [http\_hop\_limit\_imds\_v2](#input\_http\_hop\_limit\_imds\_v2) | value for http\_put\_response\_hop\_limit to enable imds v2 for ec2 instance | `number` | `1` | no |
| <a name="input_http_tokens_imds_v2"></a> [http\_tokens\_imds\_v2](#input\_http\_tokens\_imds\_v2) | value for http\_tokens to enable imds v2 for ec2 instance | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The name attribute of the IAM instance profile to associate with launched instances. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type to use when creating Access Tier instances | `string` | `"t3.medium"` | no |
| <a name="input_lb_tags"></a> [lb\_tags](#input\_lb\_tags) | Additional tags to add to the load balancer | `map(any)` | `null` | no |
| <a name="input_log_num"></a> [log\_num](#input\_log\_num) | For file logs: Number of files to use for log rotation | `any` | `null` | no |
| <a name="input_log_size"></a> [log\_size](#input\_log\_size) | For file logs: Size of each file for log rotation | `any` | `null` | no |
| <a name="input_managed_internal_cidrs"></a> [managed\_internal\_cidrs](#input\_managed\_internal\_cidrs) | CIDR blocks to allow managed internal services connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_management_cidrs"></a> [management\_cidrs](#input\_management\_cidrs) | CIDR blocks to allow SSH connections from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_member_security_groups"></a> [member\_security\_groups](#input\_member\_security\_groups) | Additional security groups which the access tier shou | `list(string)` | `[]` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum number of Access Tier instances to keep alive | `number` | `2` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use when registering this Access Tier with the Banyan command center | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to be added in front of all AWS object names | `string` | `"banyan"` | no |
| <a name="input_netagent_version"></a> [netagent\_version](#input\_netagent\_version) | Override to use a specific version of netagent (e.g. `1.48.0`). Omit for the latest version available | `string` | `null` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | IDs of the subnets where the Access Tier should create instances | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | IDs of the subnets where the load balancer should create endpoints | `list(string)` | n/a | yes |
| <a name="input_redirect_http_to_https"></a> [redirect\_http\_to\_https](#input\_redirect\_http\_to\_https) | If true, requests to the Access Tier on port 80 will be redirected to port 443 | `bool` | `true` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags to the security\_group | `map(any)` | `null` | no |
| <a name="input_shield_cidrs"></a> [shield\_cidrs](#input\_shield\_cidrs) | CIDR blocks to allow Shield (Cluster Coordinator) connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_shield_port"></a> [shield\_port](#input\_shield\_port) | TCP port number to allow Shield (Cluster Coordinator) connections to | `number` | `0` | no |
| <a name="input_src_nat_cidr_range"></a> [src\_nat\_cidr\_range](#input\_src\_nat\_cidr\_range) | CIDR range which source Network Address Translation (SNAT) will be disabled for | `any` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of an SSH key stored in AWS to allow management access | `string` | `""` | no |
| <a name="input_statsd_address"></a> [statsd\_address](#input\_statsd\_address) | Address to send statsd messages: “hostname:port” for UDP, “unix:///path/to/socket” for UDS | `any` | `null` | no |
| <a name="input_sticky_sessions"></a> [sticky\_sessions](#input\_sticky\_sessions) | Enable session stickiness for apps that require it | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Add tags to each resource | `map(any)` | `null` | no |
| <a name="input_target_group_tags"></a> [target\_group\_tags](#input\_target\_group\_tags) | Additional tags to each target\_group | `map(any)` | `null` | no |
| <a name="input_trustprovider_cidrs"></a> [trustprovider\_cidrs](#input\_trustprovider\_cidrs) | CIDR blocks to allow TrustProvider connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tunnel_cidrs"></a> [tunnel\_cidrs](#input\_tunnel\_cidrs) | Enter the Backend CIDR Ranges that correspond to the IP addresses in your private network(s).= | `any` | `null` | no |
| <a name="input_tunnel_port"></a> [tunnel\_port](#input\_tunnel\_port) | UDP port for end users to this access tier to utilize when using service tunnel | `any` | `null` | no |
| <a name="input_tunnel_private_domain"></a> [tunnel\_private\_domain](#input\_tunnel\_private\_domain) | Any internal domains that can only be resolved on your internal network’s private DNS | `any` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC in which to create the Access Tier | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | DNS name of the load balancer (example: `banyan-nlb-b335ff082d3b27ff.elb.us-east-1.amazonaws.com`) |
| <a name="output_asg"></a> [asg](#output\_asg) | The `aws_autoscaling_group.asg` resource |
| <a name="output_cpu_policy"></a> [cpu\_policy](#output\_cpu\_policy) | The `aws_autoscaling_policy.cpu_policy` resource |
| <a name="output_listener443"></a> [listener443](#output\_listener443) | The `aws_lb_listener.listener443` resource |
| <a name="output_listener80"></a> [listener80](#output\_listener80) | The `aws_lb_listener.listener80` resource |
| <a name="output_listener8443"></a> [listener8443](#output\_listener8443) | The `aws_lb_listener.listener8443` resource |
| <a name="output_name"></a> [name](#output\_name) | Name to use when registering this Access Tier with the console |
| <a name="output_nlb"></a> [nlb](#output\_nlb) | The `aws_alb.nlb` resource |
| <a name="output_nlb_zone_id"></a> [nlb\_zone\_id](#output\_nlb\_zone\_id) | Zone ID of the load balancer (example: `Z26RNL4JYFTOTI`) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group, which can be added as an inbound rule on other backend groups (example: `sg-1234abcd`) |
| <a name="output_sg"></a> [sg](#output\_sg) | The `aws_security_group.sg` resource |
| <a name="output_target443"></a> [target443](#output\_target443) | The `aws_lb_target_group.target443` resource |
| <a name="output_target80"></a> [target80](#output\_target80) | The `aws_lb_target_group.target80` resource |
| <a name="output_target8443"></a> [target8443](#output\_target8443) | The `aws_lb_target_group.target8443` resource |
<!-- END_TF_DOCS -->