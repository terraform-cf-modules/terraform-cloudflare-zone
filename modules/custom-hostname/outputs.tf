output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "custom_hostnames" {
  description = "Map of full cloudflare_custom_hostname objects, keyed by the same keys as var.custom_hostnames."
  value       = cloudflare_custom_hostname.this
  sensitive   = true
}

output "custom_hostname_ids" {
  description = "Map of custom hostname IDs, keyed by the same keys as var.custom_hostnames."
  value       = { for key, hostname in cloudflare_custom_hostname.this : key => hostname.id }
}

output "ownership_verification" {
  description = "Ownership verification records for each custom hostname, keyed by the same keys as var.custom_hostnames. Publish these in the customer's own DNS."
  value = {
    for key, hostname in cloudflare_custom_hostname.this : key => {
      dns  = hostname.ownership_verification
      http = hostname.ownership_verification_http
    }
  }
}

output "fallback_origin" {
  description = "The full cloudflare_custom_hostname_fallback_origin object, or null when not managed."
  value       = one(cloudflare_custom_hostname_fallback_origin.this)
}

output "fallback_origin_id" {
  description = "ID of the fallback origin, or null when not managed."
  value       = try(one(cloudflare_custom_hostname_fallback_origin.this[*].id), null)
}

output "regional_hostnames" {
  description = "Map of full cloudflare_regional_hostname objects, keyed by the same keys as var.regional_hostnames."
  value       = cloudflare_regional_hostname.this
}
