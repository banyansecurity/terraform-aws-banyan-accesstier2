output "name" {
  value       = var.name
  description = "Name to use when registering this Access Tier with the console"
}

output "address" {
  value       = aws_alb.nlb.dns_name
  description = "DNS name of the load balancer (example: `banyan-nlb-b335ff082d3b27ff.elb.us-east-1.amazonaws.com`)"
}

output "api_key_id" {
  value = banyan_api_key.accesstier.id
  description = "ID of the API key associated with the Access Tier"
}

output "nlb_zone_id" {
  value       = aws_alb.nlb.zone_id
  description = "Zone ID of the load balancer (example: `Z26RNL4JYFTOTI`)"
}

output "security_group_id" {
  value       = aws_security_group.sg.id
  description = "The ID of the security group, which can be added as an inbound rule on other backend groups (example: `sg-1234abcd`)"
}