resource "aws_service_discovery_service" "this" {
  name = var.service-disc-name

  dns_config {
    namespace_id = var.namespace-id

    dns_records {
      ttl = 10
      type = "A"
    }
  }
}