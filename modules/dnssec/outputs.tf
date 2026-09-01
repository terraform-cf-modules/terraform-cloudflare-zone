output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "dnssec" {
  description = "The full cloudflare_zone_dnssec object, or null when DNSSEC is not managed."
  value       = one(cloudflare_zone_dnssec.this)
}

output "id" {
  description = "ID of the DNSSEC resource, or null when DNSSEC is not managed."
  value       = try(one(cloudflare_zone_dnssec.this[*].id), null)
}

output "ds" {
  description = "DS record to publish at the registrar to complete the chain of trust."
  value       = try(one(cloudflare_zone_dnssec.this[*].ds), null)
}

output "digest" {
  description = "Digest of the zone signing key."
  value       = try(one(cloudflare_zone_dnssec.this[*].digest), null)
}

output "key_tag" {
  description = "Key tag of the zone signing key."
  value       = try(one(cloudflare_zone_dnssec.this[*].key_tag), null)
}

output "public_key" {
  description = "Public key of the zone signing key."
  value       = try(one(cloudflare_zone_dnssec.this[*].public_key), null)
}

output "status" {
  description = "Reported DNSSEC status for the zone."
  value       = try(one(cloudflare_zone_dnssec.this[*].status), null)
}
