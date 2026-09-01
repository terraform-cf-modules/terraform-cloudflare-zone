output "enabled" {
  description = "Whether this submodule created its resources."
  value       = var.enabled
}

output "tiered_cache" {
  description = "The full cloudflare_tiered_cache object, or null when not managed."
  value       = one(cloudflare_tiered_cache.this)
}

output "argo_tiered_caching" {
  description = "The full cloudflare_argo_tiered_caching object, or null when not managed."
  value       = one(cloudflare_argo_tiered_caching.this)
}

output "regional_tiered_cache" {
  description = "The full cloudflare_regional_tiered_cache object, or null when not managed."
  value       = one(cloudflare_regional_tiered_cache.this)
}

output "cache_reserve" {
  description = "The full cloudflare_zone_cache_reserve object, or null when not managed."
  value       = one(cloudflare_zone_cache_reserve.this)
}

output "cache_variants" {
  description = "The full cloudflare_zone_cache_variants object, or null when not managed."
  value       = one(cloudflare_zone_cache_variants.this)
}

output "argo_smart_routing" {
  description = "The full cloudflare_argo_smart_routing object, or null when not managed."
  value       = one(cloudflare_argo_smart_routing.this)
}

output "cache" {
  description = "Every cache object this submodule manages, collected into one map. Each entry is null when the corresponding input was left unset."
  value = {
    tiered_cache          = one(cloudflare_tiered_cache.this)
    argo_tiered_caching   = one(cloudflare_argo_tiered_caching.this)
    regional_tiered_cache = one(cloudflare_regional_tiered_cache.this)
    cache_reserve         = one(cloudflare_zone_cache_reserve.this)
    cache_variants        = one(cloudflare_zone_cache_variants.this)
    argo_smart_routing    = one(cloudflare_argo_smart_routing.this)
  }
}
