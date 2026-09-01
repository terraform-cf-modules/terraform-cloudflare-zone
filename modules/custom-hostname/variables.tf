variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID that serves the custom hostnames."
  type        = string
  default     = null
}

variable "custom_hostnames" {
  description = "Custom hostnames for SSL for SaaS, keyed by a stable identifier. Marked sensitive because the ssl block can carry a certificate private key."
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

  validation {
    condition = alltrue([
      for hostname in values(var.custom_hostnames) :
      try(hostname.ssl.method, null) == null || contains(["http", "txt", "email"], try(hostname.ssl.method, "txt"))
    ])
    error_message = "Each custom_hostnames ssl.method must be one of http, txt, email."
  }

  validation {
    condition = alltrue([
      for hostname in values(var.custom_hostnames) :
      try(hostname.ssl.certificate_authority, null) == null || contains(["digicert", "google", "lets_encrypt", "ssl_com"], try(hostname.ssl.certificate_authority, "google"))
    ])
    error_message = "Each custom_hostnames ssl.certificate_authority must be one of digicert, google, lets_encrypt, ssl_com."
  }

  validation {
    condition = alltrue([
      for hostname in values(var.custom_hostnames) :
      try(hostname.ssl.settings.min_tls_version, null) == null || contains(["1.0", "1.1", "1.2", "1.3"], try(hostname.ssl.settings.min_tls_version, "1.2"))
    ])
    error_message = "Each custom_hostnames ssl.settings.min_tls_version must be one of 1.0, 1.1, 1.2, 1.3."
  }

  validation {
    condition = alltrue([
      for hostname in values(var.custom_hostnames) :
      try(hostname.ssl.type, null) == null || try(hostname.ssl.type, "dv") == "dv"
    ])
    error_message = "Each custom_hostnames ssl.type must be dv. It is the only value the Cloudflare API accepts."
  }
}

variable "fallback_origin" {
  description = "Fallback origin hostname that serves every custom hostname in the zone that has no custom_origin_server of its own. Null means no fallback origin is managed."
  type        = string
  default     = null
}

variable "regional_hostnames" {
  description = "Regional Services hostnames, which pin TLS termination and HTTP processing to a Cloudflare region, keyed by a stable identifier."
  type = map(object({
    hostname   = string
    region_key = string
    routing    = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for regional in values(var.regional_hostnames) :
      can(regex("^[a-z0-9+_-]+$", regional.region_key))
    ])
    error_message = "Each regional_hostnames region_key must be a Cloudflare region key such as eu, in or ca, in lower case."
  }
}
