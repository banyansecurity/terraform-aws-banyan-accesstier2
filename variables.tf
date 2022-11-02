// Common Banyan Variables followed by cloud specific variables
variable "name" {
  type        = string
  description = "Name to use when registering this Access Tier with the Banyan command center"
}

variable "api_key" {
  type        = string
  description = "An admin scoped API key to use for authentication to Banyan"
}

variable "banyan_host" {
  type        = string
  description = "URL to the Banyan API server"
  default     = "https://net.banyanops.com/"
}

variable "statsd_address" {
  description = "Address to send statsd messages: “hostname:port” for UDP, “unix:///path/to/socket” for UDS"
  default     = null
}

variable "events_rate_limiting" {
  description = "Enable rate limiting of Access Event generation based on a credit-based rate control mechanism"
  default     = null
}

variable "event_key_rate_limiting" {
  description = "Enable rate limiting of Access Event generated based on a derived “key” value. Each key has a separate rate limiter, and events with the same key value are subjected to the rate limiter for that key"
  default     = null
}

variable "forward_trust_cookie" {
  description = "Forward the Banyan trust cookie to upstream servers. This may be enabled if upstream servers wish to make use of information in the Banyan trust cookie."
  default     = null
}

variable "enable_hsts" {
  description = "If enabled, Banyan will send the HTTP Strict-Transport-Security response header"
  default     = null
}

variable "netagent_version" {
  type        = string
  description = "Override to use a specific version of netagent (e.g. `1.48.0`). Omit for the latest version available"
  default     = null
}

variable "disable_snat" {
  description = "Disable Source Network Address Translation (SNAT)"
  default     = false
}

variable "src_nat_cidr_range" {
  description = "CIDR range which source Network Address Translation (SNAT) will be disabled for"
  default     = null
}

variable "tunnel_port" {
  description = "UDP port for end users to this access tier to utilize when using service tunnel"
  default     = null
}

variable "tunnel_private_domain" {
  description = "Any internal domains that can only be resolved on your internal network’s private DNS"
  default     = null
}

variable "tunnel_cidrs" {
  description = "Enter the Backend CIDR Ranges that correspond to the IP addresses in your private network(s).="
  default     = null
}

variable "console_log_level" {
  description = "Controls verbosity of logs to console"
  default     = null
}

variable "file_log_level" {
  description = "Controls verbosity of logs to file"
  default     = null
}

variable "file_log" {
  description = "Whether to log to file or not"
  default     = null
}

variable "log_num" {
  description = "For file logs: Number of files to use for log rotation"
  default     = null
}

variable "log_size" {
  description = "For file logs: Size of each file for log rotation"
  default     = null
}

variable "cluster" {
  type        = string
  description = "Name of an existing Shield cluster to register this Access Tier with. This value is set automatically if omitted from the configuration"
  default     = null
}

// AWS specific variables
variable "member_security_groups" {
  type        = list(string)
  description = "Additional security groups which the access tier shou"
  default     = []
}

variable "redirect_http_to_https" {
  type        = bool
  description = "If true, requests to the Access Tier on port 80 will be redirected to port 443"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to use when creating Access Tier instances"
  default     = "t3.medium"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which to create the Access Tier"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets where the load balancer should create endpoints"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets where the Access Tier should create instances"
}

variable "healthcheck_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow health check connections from (recommended to use the VPC CIDR range)"
  default     = ["0.0.0.0/0"]
}

variable "management_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow SSH connections from"
  default     = ["0.0.0.0/0"]
}

variable "shield_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow Shield (Cluster Coordinator) connections to"
  default     = ["0.0.0.0/0"]
}

variable "shield_port" {
  type        = number
  description = "TCP port number to allow Shield (Cluster Coordinator) connections to"
  default     = 0
}

variable "command_center_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow Command Center connections to"
  default     = ["0.0.0.0/0"]
}

variable "trustprovider_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow TrustProvider connections to"
  default     = ["0.0.0.0/0"]
}

variable "managed_internal_cidrs" {
  type        = list(string)
  description = "CIDR blocks to allow managed internal services connections to"
  default     = ["0.0.0.0/0"]
}

variable "ssh_key_name" {
  type        = string
  description = "Name of an SSH key stored in AWS to allow management access"
  default     = ""
}

variable "cross_zone_enabled" {
  type        = bool
  description = "Allow load balancer to distribute traffic to other zones"
  default     = true
}

variable "min_instances" {
  type        = number
  description = "Minimum number of Access Tier instances to keep alive"
  default     = 2
}

variable "iam_instance_profile" {
  type        = string
  description = "The name attribute of the IAM instance profile to associate with launched instances."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Add tags to each resource"
  default     = null
}

variable "security_group_tags" {
  type        = map(any)
  description = "Additional tags to the security_group"
  default     = null
}

variable "autoscaling_group_tags" {
  type        = map(any)
  description = "Additional tags to the autoscaling_group"
  default     = null
}

variable "lb_tags" {
  type        = map(any)
  description = "Additional tags to add to the load balancer"
  default     = null
}

variable "target_group_tags" {
  type        = map(any)
  description = "Additional tags to each target_group"
  default     = null
}

variable "host_tags" {
  type        = map(any)
  description = "Additional tags to assign to this Access Tier"
  default     = { "type" : "access_tier" }
}

variable "groups_by_userinfo" {
  type        = bool
  description = "Derive groups information from userinfo endpoint"
  default     = false
}

variable "name_prefix" {
  type        = string
  description = "String to be added in front of all AWS object names"
  default     = "banyan"
}

variable "max_instance_lifetime" {
  type        = number
  default     = null
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds"
}

variable "http_endpoint_imds_v2" {
  type        = string
  description = "value for http_endpoint to enable imds v2 for ec2 instance"
  default     = "enabled"
}

variable "http_tokens_imds_v2" {
  type        = string
  description = "value for http_tokens to enable imds v2 for ec2 instance"
  default     = "required"
}

variable "http_hop_limit_imds_v2" {
  type        = number
  description = "value for http_put_response_hop_limit to enable imds v2 for ec2 instance"
  default     = 1
}

variable "datadog_api_key" {
  type        = string
  description = "API key for DataDog"
  default     = null
}

variable "sticky_sessions" {
  type        = bool
  description = "Enable session stickiness for apps that require it"
  default     = false
}

variable "custom_user_data" {
  type        = list(string)
  description = "Custom commands to append to the launch configuration initialization script."
  default     = []
}
