output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "record_ids" {
  description = "Map of DNS record IDs, keyed by the same keys as var.records."
  value       = { for key, record in cloudflare_dns_record.this : key => record.id }
}

output "records" {
  description = "Map of full cloudflare_dns_record objects, keyed by the same keys as var.records."
  value       = cloudflare_dns_record.this
}

output "record_names" {
  description = "Map of fully qualified record names, keyed by the same keys as var.records."
  value       = { for key, record in cloudflare_dns_record.this : key => record.name }
}
