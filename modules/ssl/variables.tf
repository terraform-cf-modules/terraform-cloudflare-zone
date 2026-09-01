variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID the certificates and TLS settings apply to."
  type        = string
  default     = null
}

variable "universal_ssl_enabled" {
  description = "Whether Universal SSL is enabled for the zone. Null leaves the current Cloudflare value untouched. Disabling it removes the free certificate from every hostname in the zone."
  type        = bool
  default     = null
}

variable "total_tls" {
  description = "Total TLS, which issues certificates for every hostname in the zone rather than only the apex and one wildcard level. Null means Total TLS is not managed."
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

  validation {
    condition = alltrue([
      for pack in values(var.certificate_packs) :
      contains(["google", "lets_encrypt", "ssl_com"], pack.certificate_authority)
    ])
    error_message = "Each certificate_packs certificate_authority must be one of google, lets_encrypt, ssl_com."
  }

  validation {
    condition = alltrue([
      for pack in values(var.certificate_packs) :
      contains(["txt", "http", "email"], pack.validation_method)
    ])
    error_message = "Each certificate_packs validation_method must be one of txt, http, email."
  }

  validation {
    condition = alltrue([
      for pack in values(var.certificate_packs) :
      contains([14, 30, 90, 365], pack.validity_days)
    ])
    error_message = "Each certificate_packs validity_days must be one of 14, 30, 90, 365."
  }

  validation {
    condition = alltrue([
      for pack in values(var.certificate_packs) :
      pack.type == "advanced"
    ])
    error_message = "Each certificate_packs type must be advanced. It is the only value the Cloudflare API accepts."
  }
}

variable "custom_certificates" {
  description = "Customer supplied SSL certificates to upload to the zone, keyed by a stable identifier. private_key is the certificate key, not a Cloudflare API credential, and the variable is marked sensitive."
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

  validation {
    condition = alltrue([
      for certificate in values(var.custom_certificates) :
      certificate.bundle_method == null || contains(["ubiquitous", "optimal", "force"], coalesce(certificate.bundle_method, "ubiquitous"))
    ])
    error_message = "Each custom_certificates bundle_method must be one of ubiquitous, optimal, force."
  }

  validation {
    condition = alltrue([
      for certificate in values(var.custom_certificates) :
      certificate.type == null || contains(["legacy_custom", "sni_custom"], coalesce(certificate.type, "sni_custom"))
    ])
    error_message = "Each custom_certificates type must be one of legacy_custom, sni_custom."
  }

  validation {
    condition = alltrue([
      for certificate in values(var.custom_certificates) :
      certificate.deploy == null || contains(["staging", "production"], coalesce(certificate.deploy, "production"))
    ])
    error_message = "Each custom_certificates deploy must be one of staging, production."
  }
}

variable "hostname_tls_settings" {
  description = "Per hostname TLS overrides, keyed by a stable identifier. Each entry sets one setting on one hostname."
  type = map(object({
    hostname   = string
    setting_id = string
    value      = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for setting in values(var.hostname_tls_settings) :
      contains(["ciphers", "min_tls_version", "http2"], setting.setting_id)
    ])
    error_message = "Each hostname_tls_settings setting_id must be one of ciphers, min_tls_version, http2."
  }

  validation {
    condition = alltrue([
      for setting in values(var.hostname_tls_settings) :
      setting.setting_id != "min_tls_version" || contains(["1.0", "1.1", "1.2", "1.3"], setting.value)
    ])
    error_message = "A hostname_tls_settings entry with setting_id min_tls_version must have a value of 1.0, 1.1, 1.2 or 1.3."
  }

  validation {
    condition = alltrue([
      for setting in values(var.hostname_tls_settings) :
      setting.setting_id != "http2" || contains(["on", "off"], setting.value)
    ])
    error_message = "A hostname_tls_settings entry with setting_id http2 must have a value of on or off."
  }
}
