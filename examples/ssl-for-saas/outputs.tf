output "custom_hostname_ids" {
  description = "IDs of the custom hostnames, keyed by customer."
  value       = module.this.custom_hostname_ids
}

output "ownership_verification" {
  description = "Tokens each customer publishes to prove they control their domain."
  value       = module.this.custom_hostname_ownership_verification
}

output "fallback_origin" {
  description = "The fallback origin object."
  value       = module.this.custom_hostname_fallback_origin
}
