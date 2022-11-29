# Banyan AWS Access Tier 2 Module

This module creates an auto-scaling instance group and Network Load Balancer in Amazon Web Services for a Banyan Access Tier. A network load balancer forwards traffic to the instance group which, when added to the proper tags and banyan zero trust policies, allows for connections to internal services or to the network via service tunnel.

This module will create an access tier definition in the Banyan API, and an `access_tier` scoped API key. It will populate the launch configuration of all instances in the auto-scaling group with a short script to download the latest version of the Banyan NetAgent (or a pinned version if set), install it as a service, and launch the netagent with the API key and access tier configuration name for your Banyan organization.

### Why Access Tier 2?

In order to ease the installation and configuration of the access tier, the new netagent only needs an access tier scoped API key, Banyan API URL, and the name of an access tier configuration in order to successfully connect. In this new module the access tier is defined in the Banyan API with the `banyan_accesstier` resource from the `banyan` terraform provider. The API key is created specifically for the access tier and added to the launch configuration


## Usage

```terraform
terraform {
  required_providers {
    banyan = {
      source  = "banyansecurity/banyan"
      version = "1.0"
    }
  }
}

provider "banyan" {
  api_key = "ADMIN-SCOPE-API-KEY"
}

provider "aws" {
  region = "us-west-2"
}

module "aws_accesstier" {
  source                 = "banyansecurity/banyan-accesstier2/aws"
  name                   = "example"
  banyan_host            = var.banyan_host
  private_subnet_ids     = ["subnet-0bff66824ea1ede35", "subnet-0e4680564d8fd1f69"]
  public_subnet_ids      = ["subnet-0bd9c5568baa33137", "subnet-0a2f69d9f6cdc0b1a"]
  vpc_id                 = "vpc-0c5252fae45fe5011"
  member_security_groups = [aws_security_group.allow_at.id]
}
```

## Example Stack with Service Tunnel and Wildcard DNS Record

This example will configure the Banyan terraform provider and the AWS provider. It will then create an access tier
with a wildcard DNS record pointing to the address of the access tier. The access tier is configured with the tunnel CIDR of `10.10.0.0/16`.
This corresponds to CIDR of the private network(s) (the entire VPC or individual subnets in AWS). A service tunnel is configured
to use this access tier, with a policy which allows any user with a `High` trust level access to the service tunnel.

This policy could be narrowed down further using the `access.l4_access` attribute of the `banyan_policy_tunnel` resource.

This is an effective replacement of a VPN tunnel, which leverages the device trust, continuous authorization
and SAML capabilities of Banyan.

```terraform
terraform {
  required_providers {
    banyan = {
      source  = "banyansecurity/banyan"
      version = "0.9.2"
    }
  }
}

provider "banyan" {
  api_key = "ADMIN-SCOPE-API-KEY"
}

provider "aws" {
  region = "us-west-2"
}

module "aws_accesstier" {
  source                 = "banyansecurity/banyan-accesstier2/aws"
  name                   = "example"
  private_subnet_ids     = ["subnet-0bff66824ea1ede35", "subnet-0e4680564d8fd1f69"]
  public_subnet_ids      = ["subnet-0bd9c5568baa33137", "subnet-0a2f69d9f6cdc0b1a"]
  vpc_id                 = "vpc-0c5252fae45fe5011"
  member_security_groups = [aws_security_group.allow_at.id]
  tunnel_cidrs           = ["10.10.0.0/16"]
}

resource "banyan_service_tunnel" "example" {
  name        = "example-anyone-high"
  description = "tunnel allowing anyone with a high trust level"
  access_tier = banyan_accesstier.example.name
  policy      = banyan_policy_infra.anyone-high.id
}

resource "banyan_policy_infra" "anyone-high" {
  name        = "allow-anyone-high-trust"
  description = "${module.aws_accesstier.name} allow"
  access {
    roles       = ["ANY"]
    trust_level = "High"
  }
}

resource "aws_route53_record" "aws_accesstier" {
  zone_id = local.route53_zone_id
  name    = "*.${module.aws_accesstier.name}.mycompany.com"
  type    = "CNAME"
  ttl     = 300
  records = [module.aws_accesstier.address]
}
```

## Upgrading Netagent

Set `netagent_version` to the desired version number. This will ensure all instances are pinned to the same version number. If `netagent_version` is not specified, each instance will automatically install the latest version.

## Notes

* The default value for `management_cidr` leaves SSH closed to instances in the access tier.

* The current recommended setup for to use a banyan SSH service to SSH to a host inside the private network, which in turn has SSH access to the instances in the auto-scaling group. This way no SSH service is exposed to the internet.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_banyan"></a> [banyan](#requirement\_banyan) | >=0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_banyan"></a> [banyan](#provider\_banyan) | >=0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
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
| [banyan_accesstier.accesstier](https://registry.terraform.io/providers/banyansecurity/banyan/latest/docs/resources/accesstier) | resource |
| [banyan_api_key.accesstier](https://registry.terraform.io/providers/banyansecurity/banyan/latest/docs/resources/api_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name to use when registering this Access Tier with the Banyan command center | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | IDs of the subnets where the Access Tier should create instances | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | IDs of the subnets where the load balancer should create endpoints | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC in which to create the Access Tier | `string` | n/a | yes |
| <a name="input_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#input\_autoscaling\_group\_tags) | Additional tags to the autoscaling\_group | `map(any)` | `null` | no |
| <a name="input_banyan_host"></a> [banyan\_host](#input\_banyan\_host) | URL to the Banyan API server | `string` | `"https://net.banyanops.com/"` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Name of an existing Shield cluster to register this Access Tier with. This value is set automatically if omitted from the configuration | `string` | `null` | no |
| <a name="input_command_center_cidrs"></a> [command\_center\_cidrs](#input\_command\_center\_cidrs) | CIDR blocks to allow Command Center connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_console_log_level"></a> [console\_log\_level](#input\_console\_log\_level) | Controls verbosity of logs to console. Must be one of "ERR", "WARN", "INFO", "DEBUG" | `string` | `null` | no |
| <a name="input_cross_zone_enabled"></a> [cross\_zone\_enabled](#input\_cross\_zone\_enabled) | Allow load balancer to distribute traffic to other zones | `bool` | `true` | no |
| <a name="input_custom_user_data"></a> [custom\_user\_data](#input\_custom\_user\_data) | Custom commands to append to the launch configuration initialization script | `list(string)` | `[]` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | API key for DataDog | `string` | `null` | no |
| <a name="input_disable_snat"></a> [disable\_snat](#input\_disable\_snat) | Disable Source Network Address Translation (SNAT) | `bool` | `false` | no |
| <a name="input_enable_hsts"></a> [enable\_hsts](#input\_enable\_hsts) | If enabled, Banyan will send the HTTP Strict-Transport-Security response header | `bool` | `null` | no |
| <a name="input_event_key_rate_limiting"></a> [event\_key\_rate\_limiting](#input\_event\_key\_rate\_limiting) | Enable rate limiting of Access Event generated based on a derived “key” value. Each key has a separate rate limiter, and events with the same key value are subjected to the rate limiter for that key | `bool` | `null` | no |
| <a name="input_events_rate_limiting"></a> [events\_rate\_limiting](#input\_events\_rate\_limiting) | Enable rate limiting of Access Event generation based on a credit-based rate control mechanism | `bool` | `null` | no |
| <a name="input_file_log"></a> [file\_log](#input\_file\_log) | Whether to log to file or not | `bool` | `null` | no |
| <a name="input_file_log_level"></a> [file\_log\_level](#input\_file\_log\_level) | Controls verbosity of logs to file. Must be one of "ERR", "WARN", "INFO", "DEBUG" | `string` | `null` | no |
| <a name="input_forward_trust_cookie"></a> [forward\_trust\_cookie](#input\_forward\_trust\_cookie) | Forward the Banyan trust cookie to upstream servers. This may be enabled if upstream servers wish to make use of information in the Banyan trust cookie | `bool` | `null` | no |
| <a name="input_healthcheck_cidrs"></a> [healthcheck\_cidrs](#input\_healthcheck\_cidrs) | CIDR blocks to allow health check connections from (recommended to use the VPC CIDR range) | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_http_endpoint_imds_v2"></a> [http\_endpoint\_imds\_v2](#input\_http\_endpoint\_imds\_v2) | value for http\_endpoint to enable imds v2 for ec2 instance | `string` | `"enabled"` | no |
| <a name="input_http_hop_limit_imds_v2"></a> [http\_hop\_limit\_imds\_v2](#input\_http\_hop\_limit\_imds\_v2) | value for http\_put\_response\_hop\_limit to enable imds v2 for ec2 instance | `number` | `1` | no |
| <a name="input_http_tokens_imds_v2"></a> [http\_tokens\_imds\_v2](#input\_http\_tokens\_imds\_v2) | value for http\_tokens to enable imds v2 for ec2 instance | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The name attribute of the IAM instance profile to associate with launched instances | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type to use when creating Access Tier instances | `string` | `"t3.medium"` | no |
| <a name="input_lb_tags"></a> [lb\_tags](#input\_lb\_tags) | Additional tags to add to the load balancer | `map(any)` | `null` | no |
| <a name="input_log_num"></a> [log\_num](#input\_log\_num) | For file logs: Number of files to use for log rotation | `number` | `null` | no |
| <a name="input_log_size"></a> [log\_size](#input\_log\_size) | For file logs: Size of each file for log rotation | `number` | `null` | no |
| <a name="input_managed_internal_cidrs"></a> [managed\_internal\_cidrs](#input\_managed\_internal\_cidrs) | CIDR blocks to allow managed internal services connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_management_cidrs"></a> [management\_cidrs](#input\_management\_cidrs) | CIDR blocks to allow SSH connections from. Default is the VPC CIDR range | `list(string)` | `[]` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_member_security_groups"></a> [member\_security\_groups](#input\_member\_security\_groups) | Additional security groups which the access tier shou | `list(string)` | `[]` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum number of Access Tier instances to keep alive | `number` | `2` | no |
| <a name="input_netagent_version"></a> [netagent\_version](#input\_netagent\_version) | Override to use a specific version of netagent (e.g. `1.49.1`). Omit for the latest version available | `string` | `null` | no |
| <a name="input_redirect_http_to_https"></a> [redirect\_http\_to\_https](#input\_redirect\_http\_to\_https) | If true, requests to the Access Tier on port 80 will be redirected to port 443 | `bool` | `true` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Additional tags to the security\_group | `map(any)` | `null` | no |
| <a name="input_shield_cidrs"></a> [shield\_cidrs](#input\_shield\_cidrs) | CIDR blocks to allow Shield (Cluster Coordinator) connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_shield_port"></a> [shield\_port](#input\_shield\_port) | TCP port number to allow Shield (Cluster Coordinator) connections to | `number` | `0` | no |
| <a name="input_src_nat_cidr_range"></a> [src\_nat\_cidr\_range](#input\_src\_nat\_cidr\_range) | CIDR range which source Network Address Translation (SNAT) will be disabled for | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of an SSH key stored in AWS to allow management access | `string` | `""` | no |
| <a name="input_statsd_address"></a> [statsd\_address](#input\_statsd\_address) | Address to send statsd messages: “hostname:port” for UDP, “unix:///path/to/socket” for UDS | `string` | `null` | no |
| <a name="input_sticky_sessions"></a> [sticky\_sessions](#input\_sticky\_sessions) | Enable session stickiness for apps that require it | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Add tags to each resource | `map(any)` | `null` | no |
| <a name="input_target_group_tags"></a> [target\_group\_tags](#input\_target\_group\_tags) | Additional tags to each target\_group | `map(any)` | `null` | no |
| <a name="input_trustprovider_cidrs"></a> [trustprovider\_cidrs](#input\_trustprovider\_cidrs) | CIDR blocks to allow TrustProvider connections to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tunnel_cidrs"></a> [tunnel\_cidrs](#input\_tunnel\_cidrs) | Backend CIDR Ranges that correspond to the IP addresses in your private network(s) | `list(string)` | `null` | no |
| <a name="input_tunnel_port"></a> [tunnel\_port](#input\_tunnel\_port) | UDP port for end users to this access tier to utilize when using service tunnel | `number` | `null` | no |
| <a name="input_tunnel_private_domains"></a> [tunnel\_private\_domains](#input\_tunnel\_private\_domains) | Any internal domains that can only be resolved on your internal network’s private DNS | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | DNS name of the load balancer (example: `banyan-nlb-b335ff082d3b27ff.elb.us-east-1.amazonaws.com`) |
| <a name="output_api_key_id"></a> [api\_key\_id](#output\_api\_key\_id) | ID of the API key associated with the Access Tier |
| <a name="output_name"></a> [name](#output\_name) | Name to use when registering this Access Tier with the console |
| <a name="output_nlb_zone_id"></a> [nlb\_zone\_id](#output\_nlb\_zone\_id) | Zone ID of the load balancer (example: `Z26RNL4JYFTOTI`) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group, which can be added as an inbound rule on other backend groups (example: `sg-1234abcd`) |
<!-- END_TF_DOCS -->