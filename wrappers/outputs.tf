output "wrapper" {
  description = "Map of module outputs, keyed by the same keys as var.items."
  value       = module.wrapper
  sensitive   = true
}

output "zone_ids" {
  description = "Map of zone IDs, keyed by the same keys as var.items."
  value       = { for key, zone in module.wrapper : key => zone.zone_id }
}

output "name_servers" {
  description = "Map of name server lists, keyed by the same keys as var.items."
  value       = { for key, zone in module.wrapper : key => zone.name_servers }
}
