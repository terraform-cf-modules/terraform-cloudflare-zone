output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "universal_ssl" {
  description = "The full cloudflare_universal_ssl_setting object, or null when not managed."
  value       = one(cloudflare_universal_ssl_setting.this)
}

output "total_tls" {
  description = "The full cloudflare_total_tls object, or null when not managed."
  value       = one(cloudflare_total_tls.this)
}

output "certificate_packs" {
  description = "Map of full cloudflare_certificate_pack objects, keyed by the same keys as var.certificate_packs."
  value       = cloudflare_certificate_pack.this
}

output "certificate_pack_ids" {
  description = "Map of certificate pack IDs, keyed by the same keys as var.certificate_packs."
  value       = { for key, pack in cloudflare_certificate_pack.this : key => pack.id }
}

output "certificate_pack_validation_records" {
  description = "Validation records that must be published before each certificate pack is issued, keyed by the same keys as var.certificate_packs."
  value       = { for key, pack in cloudflare_certificate_pack.this : key => pack.validation_records }
}

output "custom_certificates" {
  description = "Map of full cloudflare_custom_ssl objects, keyed by the same keys as var.custom_certificates."
  value       = cloudflare_custom_ssl.this
  sensitive   = true
}

output "custom_certificate_ids" {
  description = "Map of custom certificate IDs, keyed by the same keys as var.custom_certificates."
  value       = { for key, certificate in cloudflare_custom_ssl.this : key => certificate.id }
}

output "hostname_tls_settings" {
  description = "Map of full cloudflare_hostname_tls_setting objects, keyed by the same keys as var.hostname_tls_settings."
  value       = cloudflare_hostname_tls_setting.this
}
