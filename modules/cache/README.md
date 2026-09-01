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
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_argo_smart_routing"></a> [argo\_smart\_routing](#input\_argo\_smart\_routing) | Argo Smart Routing, which routes requests over Cloudflare's fastest available paths. Null leaves the current Cloudflare value untouched. Argo is billed separately. | `string` | `null` | no |
| <a name="input_argo_tiered_caching"></a> [argo\_tiered\_caching](#input\_argo\_tiered\_caching) | Argo Tiered Caching, the paid tiered cache topology. Null leaves the current Cloudflare value untouched. | `string` | `null` | no |
| <a name="input_cache_reserve"></a> [cache\_reserve](#input\_cache\_reserve) | Cache Reserve, which persists cached objects in R2. Null leaves the current Cloudflare value untouched. Cache Reserve is billed separately and needs Tiered Cache enabled. | `string` | `null` | no |
| <a name="input_cache_variants"></a> [cache\_variants](#input\_cache\_variants) | Cache variants by image format, mapping a format to the list of Content-Type values that share one cache entry. Null means variants are not managed. | <pre>object({<br/>    avif = optional(list(string))<br/>    bmp  = optional(list(string))<br/>    gif  = optional(list(string))<br/>    jp2  = optional(list(string))<br/>    jpeg = optional(list(string))<br/>    jpg  = optional(list(string))<br/>    jpg2 = optional(list(string))<br/>    png  = optional(list(string))<br/>    tif  = optional(list(string))<br/>    tiff = optional(list(string))<br/>    webp = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_regional_tiered_cache"></a> [regional\_tiered\_cache](#input\_regional\_tiered\_cache) | Regional Tiered Cache, which adds a regional tier between the lower and upper tiers. Null leaves the current Cloudflare value untouched. | `string` | `null` | no |
| <a name="input_tiered_cache"></a> [tiered\_cache](#input\_tiered\_cache) | Smart Tiered Cache topology, which lets Cloudflare pick a single upper tier data centre per lower tier. Null leaves the current Cloudflare value untouched. | `string` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID the cache configuration applies to. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_argo_smart_routing"></a> [argo\_smart\_routing](#output\_argo\_smart\_routing) | The full cloudflare\_argo\_smart\_routing object, or null when not managed. |
| <a name="output_argo_tiered_caching"></a> [argo\_tiered\_caching](#output\_argo\_tiered\_caching) | The full cloudflare\_argo\_tiered\_caching object, or null when not managed. |
| <a name="output_cache"></a> [cache](#output\_cache) | Every cache object this submodule manages, collected into one map. Each entry is null when the corresponding input was left unset. |
| <a name="output_cache_reserve"></a> [cache\_reserve](#output\_cache\_reserve) | The full cloudflare\_zone\_cache\_reserve object, or null when not managed. |
| <a name="output_cache_variants"></a> [cache\_variants](#output\_cache\_variants) | The full cloudflare\_zone\_cache\_variants object, or null when not managed. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_regional_tiered_cache"></a> [regional\_tiered\_cache](#output\_regional\_tiered\_cache) | The full cloudflare\_regional\_tiered\_cache object, or null when not managed. |
| <a name="output_tiered_cache"></a> [tiered\_cache](#output\_tiered\_cache) | The full cloudflare\_tiered\_cache object, or null when not managed. |
<!-- END_TF_DOCS -->
