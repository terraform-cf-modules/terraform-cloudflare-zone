# -----------------------------------------------------------------------------
# Submodule: cache
#
# Tiered cache topology, cache reserve, cache variants and Argo smart routing.
# Every input defaults to null, which means "leave whatever Cloudflare currently
# has", so this submodule creates nothing unless asked.
# -----------------------------------------------------------------------------

resource "cloudflare_tiered_cache" "this" {
  count = var.enabled && var.tiered_cache != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.tiered_cache
}

resource "cloudflare_argo_tiered_caching" "this" {
  count = var.enabled && var.argo_tiered_caching != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.argo_tiered_caching
}

resource "cloudflare_regional_tiered_cache" "this" {
  count = var.enabled && var.regional_tiered_cache != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.regional_tiered_cache
}

resource "cloudflare_zone_cache_reserve" "this" {
  count = var.enabled && var.cache_reserve != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.cache_reserve
}

resource "cloudflare_zone_cache_variants" "this" {
  count = var.enabled && var.cache_variants != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.cache_variants
}

resource "cloudflare_argo_smart_routing" "this" {
  count = var.enabled && var.argo_smart_routing != null ? 1 : 0

  zone_id = var.zone_id
  value   = var.argo_smart_routing
}
