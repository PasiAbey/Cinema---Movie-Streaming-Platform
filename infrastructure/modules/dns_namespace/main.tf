resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace-name
  vpc         = var.vpc-id

  tags = {
    Name = var.namespace-name
  }
}