variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID the settings apply to."
  type        = string
  default     = null
}

variable "zone_settings" {
  description = "Zone settings, keyed by the Cloudflare setting ID and mapped to the setting value. The value is passed through untouched because cloudflare_zone_setting takes a dynamic value, so a string such as \"full\", a number such as 14400, or an object are all valid."
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

  validation {
    condition     = var.dns_settings == null || try(var.dns_settings.zone_mode, null) == null || contains(["standard", "cdn_only", "dns_only"], try(var.dns_settings.zone_mode, "standard"))
    error_message = "dns_settings.zone_mode must be one of standard, cdn_only, dns_only."
  }

  validation {
    condition     = var.dns_settings == null || try(var.dns_settings.nameservers.type, null) == null || contains(["cloudflare.standard", "custom.account", "custom.tenant", "custom.zone"], try(var.dns_settings.nameservers.type, "cloudflare.standard"))
    error_message = "dns_settings.nameservers.type must be one of cloudflare.standard, custom.account, custom.tenant, custom.zone."
  }
}

variable "zone_hold" {
  description = "Zone hold, which stops the domain being added to another Cloudflare account. Null means no hold is managed."
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
  description = "Cloudflare managed header transforms, keyed by the managed transform ID and mapped to whether it is enabled, for example { add_true_client_ip_headers = true }. Null means managed transforms are not managed by this module."
  type = object({
    managed_request_headers  = optional(map(bool), {})
    managed_response_headers = optional(map(bool), {})
  })
  default = null
}
