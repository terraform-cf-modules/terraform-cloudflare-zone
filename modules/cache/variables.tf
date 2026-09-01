variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID the cache configuration applies to."
  type        = string
  default     = null
}

variable "tiered_cache" {
  description = "Smart Tiered Cache topology, which lets Cloudflare pick a single upper tier data centre per lower tier. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.tiered_cache == null || contains(["on", "off"], coalesce(var.tiered_cache, "on"))
    error_message = "tiered_cache must be one of on, off."
  }
}

variable "argo_tiered_caching" {
  description = "Argo Tiered Caching, the paid tiered cache topology. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.argo_tiered_caching == null || contains(["on", "off"], coalesce(var.argo_tiered_caching, "on"))
    error_message = "argo_tiered_caching must be one of on, off."
  }
}

variable "regional_tiered_cache" {
  description = "Regional Tiered Cache, which adds a regional tier between the lower and upper tiers. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.regional_tiered_cache == null || contains(["on", "off"], coalesce(var.regional_tiered_cache, "on"))
    error_message = "regional_tiered_cache must be one of on, off."
  }
}

variable "cache_reserve" {
  description = "Cache Reserve, which persists cached objects in R2. Null leaves the current Cloudflare value untouched. Cache Reserve is billed separately and needs Tiered Cache enabled."
  type        = string
  default     = null

  validation {
    condition     = var.cache_reserve == null || contains(["on", "off"], coalesce(var.cache_reserve, "on"))
    error_message = "cache_reserve must be one of on, off."
  }
}

variable "cache_variants" {
  description = "Cache variants by image format, mapping a format to the list of Content-Type values that share one cache entry. Null means variants are not managed."
  type = object({
    avif = optional(list(string))
    bmp  = optional(list(string))
    gif  = optional(list(string))
    jp2  = optional(list(string))
    jpeg = optional(list(string))
    jpg  = optional(list(string))
    jpg2 = optional(list(string))
    png  = optional(list(string))
    tif  = optional(list(string))
    tiff = optional(list(string))
    webp = optional(list(string))
  })
  default = null
}

variable "argo_smart_routing" {
  description = "Argo Smart Routing, which routes requests over Cloudflare's fastest available paths. Null leaves the current Cloudflare value untouched. Argo is billed separately."
  type        = string
  default     = null

  validation {
    condition     = var.argo_smart_routing == null || contains(["on", "off"], coalesce(var.argo_smart_routing, "on"))
    error_message = "argo_smart_routing must be one of on, off."
  }
}
