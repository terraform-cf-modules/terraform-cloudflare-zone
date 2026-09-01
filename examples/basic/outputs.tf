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

output "zone_settings" {
  description = "Zone settings the module applied."
  value       = module.this.zone_settings
}
