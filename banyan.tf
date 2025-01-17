terraform {
  required_providers {
    banyan = {
      source  = "banyansecurity/banyan"
      version = ">=1.2.14"
    }
  }
}

locals {
  access_tier_name = var.access_tier_name != "" ? var.access_tier_name : var.name
}

resource "banyan_accesstier" "accesstier" {
  name                    = local.access_tier_name
  address                 = aws_alb.nlb.dns_name
  cluster                 = var.cluster
  disable_snat            = var.disable_snat
  src_nat_cidr_range      = var.src_nat_cidr_range
  api_key_id              = banyan_api_key.accesstier.id
  tunnel_private_domains  = var.tunnel_private_domains
  tunnel_cidrs            = var.tunnel_cidrs
  console_log_level       = var.console_log_level
  file_log_level          = var.file_log_level
  file_log                = var.file_log
  log_num                 = var.log_num
  log_size                = var.log_size
  statsd_address          = var.statsd_address
  events_rate_limiting    = var.events_rate_limiting
  event_key_rate_limiting = var.event_key_rate_limiting
  forward_trust_cookie    = var.forward_trust_cookie
  enable_hsts             = var.enable_hsts
}

resource "banyan_api_key" "accesstier" {
  name        = local.access_tier_name
  description = "API key for ${local.access_tier_name} access tier"
  scope       = "access_tier"
}
