output "zone_id" {
  description = "ID of the created zone."
  value       = module.this.zone_id
}

output "name_servers" {
  description = "Name servers to set at the registrar."
  value       = module.this.name_servers
}

output "dns_record_ids" {
  description = "IDs of the DNS records created by the module."
  value       = module.this.dns_record_ids
}

output "dnssec_ds" {
  description = "DS record to publish at the registrar."
  value       = module.this.dnssec_ds
}

output "zone_settings" {
  description = "Zone settings the module applied."
  value       = module.this.zone_settings
}

output "certificate_pack_validation_records" {
  description = "Validation records for the ordered certificate packs."
  value       = module.this.certificate_pack_validation_records
}

output "custom_hostname_ownership_verification" {
  description = "Ownership verification tokens for each custom hostname."
  value       = module.this.custom_hostname_ownership_verification
}

output "cache" {
  description = "Cache configuration objects the module manages."
  value       = module.this.cache
}
