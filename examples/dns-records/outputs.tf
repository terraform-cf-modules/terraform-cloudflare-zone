output "dns_record_ids" {
  description = "IDs of the DNS records, keyed by the same keys as the input map."
  value       = module.this.dns_record_ids
}

output "dns_record_names" {
  description = "Full cloudflare_dns_record objects, keyed by the same keys as the input map."
  value       = module.this.dns_records
}

output "dnssec_ds" {
  description = "DS record to publish at the registrar."
  value       = module.this.dnssec_ds
}
