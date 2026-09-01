output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "zone_settings" {
  description = "Map of full cloudflare_zone_setting objects, keyed by the Cloudflare setting ID."
  value       = cloudflare_zone_setting.this
}

output "zone_setting_ids" {
  description = "Map of zone setting resource IDs, keyed by the Cloudflare setting ID."
  value       = { for setting_id, setting in cloudflare_zone_setting.this : setting_id => setting.id }
}

output "dns_settings" {
  description = "The full cloudflare_zone_dns_settings object, or null when not managed."
  value       = one(cloudflare_zone_dns_settings.this)
}

output "zone_hold" {
  description = "The full cloudflare_zone_hold object, or null when not managed."
  value       = one(cloudflare_zone_hold.this)
}

output "zone_hold_id" {
  description = "ID of the zone hold, or null when not managed."
  value       = try(one(cloudflare_zone_hold.this[*].id), null)
}

output "url_normalization" {
  description = "The full cloudflare_url_normalization_settings object, or null when not managed."
  value       = one(cloudflare_url_normalization_settings.this)
}

output "url_normalization_id" {
  description = "ID of the URL normalization settings, or null when not managed."
  value       = try(one(cloudflare_url_normalization_settings.this[*].id), null)
}

output "managed_transforms" {
  description = "The full cloudflare_managed_transforms object, or null when not managed."
  value       = one(cloudflare_managed_transforms.this)
}

output "managed_transforms_id" {
  description = "ID of the managed transforms resource, or null when not managed."
  value       = try(one(cloudflare_managed_transforms.this[*].id), null)
}
