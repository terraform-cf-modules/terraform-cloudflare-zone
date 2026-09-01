output "enabled" {
  description = "Whether this module created its resources."
  value       = local.enabled
}

# -----------------------------------------------------------------------------
# Zone
# -----------------------------------------------------------------------------

output "zone_id" {
  description = "ID of the zone this module manages, whether it created the zone or attached to an existing one."
  value       = local.zone_id
}

output "zone" {
  description = "The full cloudflare_zone object, or null when the module did not create the zone."
  value       = one(cloudflare_zone.this)
}

output "zone_name" {
  description = "Domain name of the zone."
  value       = try(one(cloudflare_zone.this[*].name), var.zone_name)
}

output "name_servers" {
  description = "Cloudflare name servers to set at the registrar. Empty when the module did not create the zone."
  value       = try(one(cloudflare_zone.this[*].name_servers), [])
}

output "zone_status" {
  description = "Activation status of the zone, one of initializing, pending, active, moved."
  value       = try(one(cloudflare_zone.this[*].status), null)
}

output "verification_key" {
  description = "Verification key used to prove ownership of a partial zone."
  value       = try(one(cloudflare_zone.this[*].verification_key), null)
}

# -----------------------------------------------------------------------------
# DNS
# -----------------------------------------------------------------------------

output "dns_record_ids" {
  description = "Map of DNS record IDs, keyed by the same keys as var.dns_records."
  value       = module.dns_record.record_ids
}

output "dns_records" {
  description = "Map of full cloudflare_dns_record objects, keyed by the same keys as var.dns_records."
  value       = module.dns_record.records
}

output "dnssec" {
  description = "The cloudflare_zone_dnssec object, or null when DNSSEC is not managed."
  value       = module.dnssec.dnssec
}

output "dnssec_ds" {
  description = "DS record to publish at the registrar to complete the DNSSEC chain of trust."
  value       = module.dnssec.ds
}

output "dns_settings" {
  description = "The cloudflare_zone_dns_settings object, or null when zone DNS settings are not managed."
  value       = module.settings.dns_settings
}

# -----------------------------------------------------------------------------
# Settings
# -----------------------------------------------------------------------------

output "zone_settings" {
  description = "Map of cloudflare_zone_setting objects, keyed by the Cloudflare setting ID."
  value       = module.settings.zone_settings
}

output "zone_hold" {
  description = "The cloudflare_zone_hold object, or null when no hold is managed."
  value       = module.settings.zone_hold
}

output "url_normalization" {
  description = "The cloudflare_url_normalization_settings object, or null when not managed."
  value       = module.settings.url_normalization
}

output "managed_transforms" {
  description = "The cloudflare_managed_transforms object, or null when not managed."
  value       = module.settings.managed_transforms
}

# -----------------------------------------------------------------------------
# TLS and certificates
# -----------------------------------------------------------------------------

output "universal_ssl" {
  description = "The cloudflare_universal_ssl_setting object, or null when not managed."
  value       = module.ssl.universal_ssl
}

output "total_tls" {
  description = "The cloudflare_total_tls object, or null when not managed."
  value       = module.ssl.total_tls
}

output "certificate_packs" {
  description = "Map of cloudflare_certificate_pack objects, keyed by the same keys as var.certificate_packs."
  value       = module.ssl.certificate_packs
}

output "certificate_pack_validation_records" {
  description = "Validation records that must be published before each certificate pack is issued, keyed by the same keys as var.certificate_packs."
  value       = module.ssl.certificate_pack_validation_records
}

output "custom_certificates" {
  description = "Map of cloudflare_custom_ssl objects, keyed by the same keys as var.custom_certificates."
  value       = module.ssl.custom_certificates
  sensitive   = true
}

output "hostname_tls_settings" {
  description = "Map of cloudflare_hostname_tls_setting objects, keyed by the same keys as var.hostname_tls_settings."
  value       = module.ssl.hostname_tls_settings
}

# -----------------------------------------------------------------------------
# Custom hostnames
# -----------------------------------------------------------------------------

output "custom_hostnames" {
  description = "Map of cloudflare_custom_hostname objects, keyed by the same keys as var.custom_hostnames."
  value       = module.custom_hostname.custom_hostnames
  sensitive   = true
}

output "custom_hostname_ids" {
  description = "Map of custom hostname IDs, keyed by the same keys as var.custom_hostnames."
  value       = module.custom_hostname.custom_hostname_ids
}

output "custom_hostname_ownership_verification" {
  description = "Ownership verification records for each custom hostname, keyed by the same keys as var.custom_hostnames."
  value       = module.custom_hostname.ownership_verification
}

output "custom_hostname_fallback_origin" {
  description = "The cloudflare_custom_hostname_fallback_origin object, or null when not managed."
  value       = module.custom_hostname.fallback_origin
}

output "regional_hostnames" {
  description = "Map of cloudflare_regional_hostname objects, keyed by the same keys as var.regional_hostnames."
  value       = module.custom_hostname.regional_hostnames
}

# -----------------------------------------------------------------------------
# Cache
# -----------------------------------------------------------------------------

output "cache" {
  description = "All cache related objects this module manages, each null when the corresponding input was left unset."
  value       = module.cache.cache
}
