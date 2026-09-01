# Submodule: cache

Cache topology and edge routing for a zone.

```hcl
module "cache" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/cache"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  tiered_cache          = "on"
  argo_tiered_caching   = "on"
  regional_tiered_cache = "on"
  cache_reserve         = "on"
  argo_smart_routing    = "on"

  cache_variants = {
    jpeg = ["image/webp", "image/avif"]
    png  = ["image/webp"]
  }
}
```

Notes:

- Every input defaults to `null`, meaning "leave the current Cloudflare value alone". The submodule creates
  nothing until an input is set.
- `cloudflare_tiered_cache` is Smart Tiered Cache and `cloudflare_argo_tiered_caching` is the Argo topology.
  They are separate API surfaces, so both exist here, but setting both to `on` on the same zone is usually not
  what you want.
- Cache Reserve and Argo Smart Routing are billed separately from the zone plan.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
