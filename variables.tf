# -----------------------------------------------------------------------------
# Common inputs. Every module in this organisation exposes these.
# -----------------------------------------------------------------------------

variable "enabled" {
  description = "Whether to create the resources managed by this module. Set to false to disable the module without removing the block."
  type        = bool
  default     = true
}

variable "account_id" {
  description = "Cloudflare account ID that owns the zone. Required when create_zone is true."
  type        = string
  default     = null

  validation {
    condition     = var.account_id == null || can(regex("^[0-9a-f]{32}$", var.account_id))
    error_message = "account_id must be a 32 character lowercase hexadecimal Cloudflare account ID."
  }

  validation {
    condition     = !var.create_zone || !var.enabled || var.account_id != null
    error_message = "account_id is required when create_zone is true, because a zone must be created inside an account."
  }
}

variable "zone_id" {
  description = "Cloudflare zone ID of an existing zone. Used only when create_zone is false, so that records and settings can be managed on a zone this module did not create."
  type        = string
  default     = null

  validation {
    condition     = var.zone_id == null || can(regex("^[0-9a-f]{32}$", var.zone_id))
    error_message = "zone_id must be a 32 character lowercase hexadecimal Cloudflare zone ID."
  }

  validation {
    condition     = var.create_zone || !var.enabled || var.zone_id != null
    error_message = "zone_id is required when create_zone is false, because there is no zone for the module to attach to."
  }
}

# -----------------------------------------------------------------------------
# The zone itself
# -----------------------------------------------------------------------------

variable "create_zone" {
  description = "Whether to create the Cloudflare zone. Set to false to manage DNS records and settings on a zone that already exists, addressed by zone_id."
  type        = bool
  default     = true
}

variable "zone_name" {
  description = "Domain name of the zone, for example example.com. Required when create_zone is true."
  type        = string
  default     = null

  validation {
    condition     = !var.create_zone || !var.enabled || var.zone_name != null
    error_message = "zone_name is required when create_zone is true."
  }

  validation {
    condition     = var.zone_name == null || can(regex("^(?:[a-zA-Z0-9_](?:[a-zA-Z0-9_-]{0,61}[a-zA-Z0-9_])?\\.)+[a-zA-Z]{2,}$", coalesce(var.zone_name, "example.com")))
    error_message = "zone_name must be a valid domain name, for example example.com."
  }
}

variable "zone_type" {
  description = "Zone setup. A full zone hosts DNS with Cloudflare, a partial zone is a partner hosted or CNAME setup."
  type        = string
  default     = null

  validation {
    condition     = var.zone_type == null || contains(["full", "partial", "secondary", "internal"], coalesce(var.zone_type, "full"))
    error_message = "zone_type must be one of full, partial, secondary, internal."
  }
}

variable "paused" {
  description = "Whether Cloudflare proxying is paused for the whole zone. When true, Cloudflare serves DNS only."
  type        = bool
  default     = null
}

variable "vanity_name_servers" {
  description = "Custom name servers for the zone. Business and Enterprise plans only."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------------------
# DNS
# -----------------------------------------------------------------------------

variable "dns_records" {
  description = "DNS records to create in the zone, keyed by a stable identifier. The key is only a state address, it does not have to match the record name."
  type = map(object({
    name            = string
    type            = string
    ttl             = optional(number, 1)
    content         = optional(string)
    priority        = optional(number)
    proxied         = optional(bool, false)
    comment         = optional(string)
    tags            = optional(set(string))
    private_routing = optional(bool)

    settings = optional(object({
      flatten_cname = optional(bool)
      ipv4_only     = optional(bool)
      ipv6_only     = optional(bool)
    }))

    data = optional(object({
      algorithm      = optional(number)
      altitude       = optional(number)
      certificate    = optional(string)
      digest         = optional(string)
      digest_type    = optional(number)
      fingerprint    = optional(string)
      flags          = optional(number)
      key_tag        = optional(number)
      lat_degrees    = optional(number)
      lat_direction  = optional(string)
      lat_minutes    = optional(number)
      lat_seconds    = optional(number)
      long_degrees   = optional(number)
      long_direction = optional(string)
      long_minutes   = optional(number)
      long_seconds   = optional(number)
      matching_type  = optional(number)
      order          = optional(number)
      port           = optional(number)
      precision_horz = optional(number)
      precision_vert = optional(number)
      preference     = optional(number)
      priority       = optional(number)
      protocol       = optional(number)
      public_key     = optional(string)
      regex          = optional(string)
      replacement    = optional(string)
      selector       = optional(number)
      service        = optional(string)
      size           = optional(number)
      tag            = optional(string)
      target         = optional(string)
      type           = optional(number)
      usage          = optional(number)
      value          = optional(string)
      weight         = optional(number)
    }))
  }))
  default = {}
}

variable "dns_settings" {
  description = "Zone level DNS settings such as CNAME flattening, nameserver selection and the SOA record. Null leaves the Cloudflare defaults alone."
  type = object({
    flatten_all_cnames  = optional(bool)
    foundation_dns      = optional(bool)
    multi_provider      = optional(bool)
    ns_ttl              = optional(number)
    secondary_overrides = optional(bool)
    zone_mode           = optional(string)

    internal_dns = optional(object({
      reference_zone_id = optional(string)
    }))

    nameservers = optional(object({
      ns_set = optional(number)
      type   = optional(string)
    }))

    soa = optional(object({
      expire  = optional(number)
      min_ttl = optional(number)
      mname   = optional(string)
      refresh = optional(number)
      retry   = optional(number)
      rname   = optional(string)
      ttl     = optional(number)
    }))
  })
  default = null
}

# -----------------------------------------------------------------------------
# DNSSEC
# -----------------------------------------------------------------------------

variable "dnssec_enabled" {
  description = "Whether to manage DNSSEC for the zone. When true a cloudflare_zone_dnssec resource is created and the DS record is exposed as an output for the registrar."
  type        = bool
  default     = false
}

variable "dnssec" {
  description = "DNSSEC options. Only read when dnssec_enabled is true."
  type = object({
    status              = optional(string, "active")
    dnssec_multi_signer = optional(bool)
    dnssec_presigned    = optional(bool)
    dnssec_use_nsec3    = optional(bool)
  })
  default = {}

  validation {
    condition     = var.dnssec.status == null || contains(["active", "disabled"], coalesce(var.dnssec.status, "active"))
    error_message = "dnssec.status must be one of active, disabled."
  }
}

# -----------------------------------------------------------------------------
# Zone settings. Secure by default, every default overridable.
# -----------------------------------------------------------------------------

variable "ssl_mode" {
  description = "Zone SSL mode. Set to null to leave the current Cloudflare value untouched. strict is the most secure but needs a valid certificate on the origin."
  type        = string
  default     = "full"

  validation {
    condition     = var.ssl_mode == null || contains(["off", "flexible", "full", "strict", "origin_pull"], coalesce(var.ssl_mode, "full"))
    error_message = "ssl_mode must be one of off, flexible, full, strict, origin_pull."
  }
}

variable "min_tls_version" {
  description = "Minimum TLS version the zone accepts. Set to null to leave the current Cloudflare value untouched."
  type        = string
  default     = "1.2"

  validation {
    condition     = var.min_tls_version == null || contains(["1.0", "1.1", "1.2", "1.3"], coalesce(var.min_tls_version, "1.2"))
    error_message = "min_tls_version must be one of 1.0, 1.1, 1.2, 1.3."
  }
}

variable "always_use_https" {
  description = "Whether Cloudflare redirects every plain HTTP request to HTTPS. Set to null to leave the current Cloudflare value untouched."
  type        = string
  default     = "on"

  validation {
    condition     = var.always_use_https == null || contains(["on", "off"], coalesce(var.always_use_https, "on"))
    error_message = "always_use_https must be one of on, off."
  }
}

variable "tls_1_3" {
  description = "TLS 1.3 support. Set to null to leave the current Cloudflare value untouched."
  type        = string
  default     = "on"

  validation {
    condition     = var.tls_1_3 == null || contains(["on", "off", "zrt"], coalesce(var.tls_1_3, "on"))
    error_message = "tls_1_3 must be one of on, off, zrt."
  }
}

variable "automatic_https_rewrites" {
  description = "Whether Cloudflare rewrites insecure resource references in HTML to HTTPS. Set to null to leave the current Cloudflare value untouched."
  type        = string
  default     = "on"

  validation {
    condition     = var.automatic_https_rewrites == null || contains(["on", "off"], coalesce(var.automatic_https_rewrites, "on"))
    error_message = "automatic_https_rewrites must be one of on, off."
  }
}

variable "zone_settings" {
  description = "Additional zone settings, keyed by the Cloudflare setting ID, mapped to the setting value. Values are passed through untouched because cloudflare_zone_setting takes a dynamic value, so a string, a number or an object are all valid. Entries here override the ssl_mode, min_tls_version, always_use_https, tls_1_3 and automatic_https_rewrites defaults."
  type        = any
  default     = {}

  validation {
    condition     = can(keys(var.zone_settings))
    error_message = "zone_settings must be a map keyed by the Cloudflare zone setting ID."
  }

  validation {
    condition     = alltrue([for setting_id in keys(var.zone_settings) : can(regex("^[a-z0-9_]+$", setting_id))])
    error_message = "Each zone_settings key must be a Cloudflare setting ID in lower snake case, for example ssl or always_use_https."
  }
}

variable "zone_settings_enabled" {
  description = "Optional enabled flag per zone setting, keyed by the same setting ID used in zone_settings. Only a small number of settings, such as ssl_recommender, use it."
  type        = map(bool)
  default     = {}
}

variable "zone_hold" {
  description = "Zone hold, which blocks the domain from being added to another Cloudflare account. Null means no hold is managed."
  type = object({
    hold_after         = optional(string)
    include_subdomains = optional(bool)
  })
  default = null
}

variable "url_normalization" {
  description = "URL normalization applied before rules run. Null leaves the Cloudflare default alone."
  type = object({
    scope = string
    type  = string
  })
  default = null

  validation {
    condition     = var.url_normalization == null || contains(["incoming", "both", "none"], try(var.url_normalization.scope, "both"))
    error_message = "url_normalization.scope must be one of incoming, both, none."
  }

  validation {
    condition     = var.url_normalization == null || contains(["cloudflare", "rfc3986"], try(var.url_normalization.type, "cloudflare"))
    error_message = "url_normalization.type must be one of cloudflare, rfc3986."
  }
}

variable "managed_transforms" {
  description = "Cloudflare managed header transforms, keyed by the managed transform ID and mapped to whether it is enabled. Null means managed transforms are not managed by this module."
  type = object({
    managed_request_headers  = optional(map(bool), {})
    managed_response_headers = optional(map(bool), {})
  })
  default = null
}

# -----------------------------------------------------------------------------
# TLS and certificates
# -----------------------------------------------------------------------------

variable "universal_ssl_enabled" {
  description = "Whether Universal SSL is enabled for the zone. Null leaves the current Cloudflare value untouched. Disabling it removes the free certificate from every hostname in the zone."
  type        = bool
  default     = null
}

variable "total_tls" {
  description = "Total TLS, which issues certificates for every hostname in the zone rather than the apex and one wildcard level. Null means Total TLS is not managed."
  type = object({
    enabled               = bool
    certificate_authority = optional(string)
  })
  default = null

  validation {
    condition     = var.total_tls == null || try(var.total_tls.certificate_authority, null) == null || contains(["google", "lets_encrypt", "ssl_com"], try(var.total_tls.certificate_authority, "google"))
    error_message = "total_tls.certificate_authority must be one of google, lets_encrypt, ssl_com."
  }
}

variable "certificate_packs" {
  description = "Advanced certificate packs to order, keyed by a stable identifier."
  type = map(object({
    certificate_authority = string
    hosts                 = set(string)
    validation_method     = string
    validity_days         = number
    type                  = optional(string, "advanced")
    cloudflare_branding   = optional(bool)
  }))
  default = {}
}

variable "custom_certificates" {
  description = "Customer supplied SSL certificates to upload to the zone, keyed by a stable identifier. private_key is the certificate key, not a Cloudflare credential, and is marked sensitive."
  type = map(object({
    certificate   = string
    private_key   = string
    bundle_method = optional(string)
    custom_csr_id = optional(string)
    deploy        = optional(string)
    policy        = optional(string)
    type          = optional(string)
    geo_restrictions = optional(object({
      label = optional(string)
    }))
  }))
  default   = {}
  sensitive = true
}

variable "hostname_tls_settings" {
  description = "Per hostname TLS overrides, keyed by a stable identifier."
  type = map(object({
    hostname   = string
    setting_id = string
    value      = string
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Custom hostnames (SSL for SaaS)
# -----------------------------------------------------------------------------

variable "custom_hostnames" {
  description = "Custom hostnames for SSL for SaaS, keyed by a stable identifier."
  type = map(object({
    hostname             = string
    custom_origin_server = optional(string)
    custom_origin_sni    = optional(string)
    custom_metadata      = optional(map(string))

    ssl = optional(object({
      bundle_method         = optional(string)
      certificate_authority = optional(string)
      cloudflare_branding   = optional(bool)
      custom_certificate    = optional(string)
      custom_csr_id         = optional(string)
      custom_key            = optional(string)
      method                = optional(string)
      type                  = optional(string)
      wildcard              = optional(bool)

      custom_cert_bundle = optional(list(object({
        custom_certificate = string
        custom_key         = string
      })))

      settings = optional(object({
        ciphers         = optional(list(string))
        early_hints     = optional(string)
        http2           = optional(string)
        min_tls_version = optional(string)
        tls_1_3         = optional(string)
      }))
    }))
  }))
  default   = {}
  sensitive = true
}

variable "custom_hostname_fallback_origin" {
  description = "Fallback origin for custom hostnames in this zone. Null means no fallback origin is managed."
  type        = string
  default     = null
}

variable "regional_hostnames" {
  description = "Regional Services hostnames, which pin TLS termination to a Cloudflare region, keyed by a stable identifier."
  type = map(object({
    hostname   = string
    region_key = string
    routing    = optional(string)
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Cache
# -----------------------------------------------------------------------------

variable "tiered_cache" {
  description = "Smart Tiered Cache topology. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.tiered_cache == null || contains(["on", "off"], coalesce(var.tiered_cache, "on"))
    error_message = "tiered_cache must be one of on, off."
  }
}

variable "argo_tiered_caching" {
  description = "Argo Tiered Caching. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.argo_tiered_caching == null || contains(["on", "off"], coalesce(var.argo_tiered_caching, "on"))
    error_message = "argo_tiered_caching must be one of on, off."
  }
}

variable "regional_tiered_cache" {
  description = "Regional Tiered Cache. Null leaves the current Cloudflare value untouched."
  type        = string
  default     = null

  validation {
    condition     = var.regional_tiered_cache == null || contains(["on", "off"], coalesce(var.regional_tiered_cache, "on"))
    error_message = "regional_tiered_cache must be one of on, off."
  }
}

variable "cache_reserve" {
  description = "Cache Reserve, which stores cached objects in R2. Null leaves the current Cloudflare value untouched. Cache Reserve is billed separately."
  type        = string
  default     = null

  validation {
    condition     = var.cache_reserve == null || contains(["on", "off"], coalesce(var.cache_reserve, "on"))
    error_message = "cache_reserve must be one of on, off."
  }
}

variable "cache_variants" {
  description = "Cache variants by image format, mapping a format to the list of Content-Type values served from the same cache entry. Null means variants are not managed."
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
  description = "Argo Smart Routing. Null leaves the current Cloudflare value untouched. Argo is billed separately."
  type        = string
  default     = null

  validation {
    condition     = var.argo_smart_routing == null || contains(["on", "off"], coalesce(var.argo_smart_routing, "on"))
    error_message = "argo_smart_routing must be one of on, off."
  }
}
