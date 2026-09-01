variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID the records belong to."
  type        = string
  default     = null
}

variable "records" {
  description = "DNS records to create, keyed by a stable identifier. The key is only a state address, it does not have to match the record name. Renaming a key destroys and recreates the record."
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

  validation {
    condition = alltrue([
      for record in values(var.records) :
      contains(
        ["A", "AAAA", "CNAME", "MX", "NS", "OPENPGPKEY", "PTR", "TXT", "CAA", "CERT", "DNSKEY", "DS", "HTTPS", "LOC", "NAPTR", "SMIMEA", "SRV", "SSHFP", "SVCB", "TLSA", "URI"],
        record.type
      )
    ])
    error_message = "Each record type must be one of A, AAAA, CNAME, MX, NS, OPENPGPKEY, PTR, TXT, CAA, CERT, DNSKEY, DS, HTTPS, LOC, NAPTR, SMIMEA, SRV, SSHFP, SVCB, TLSA, URI."
  }

  validation {
    condition = alltrue([
      for record in values(var.records) :
      record.ttl == 1 || (record.ttl >= 30 && record.ttl <= 86400)
    ])
    error_message = "Each record ttl must be 1, which means automatic, or between 30 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for record in values(var.records) :
      record.content != null || record.data != null
    ])
    error_message = "Each record must set either content or data. Simple types such as A, AAAA, CNAME and TXT use content, structured types such as SRV, CAA, LOC and SSHFP use data."
  }

  validation {
    condition = alltrue([
      for record in values(var.records) :
      record.priority != null if contains(["MX", "URI"], record.type)
    ])
    error_message = "MX and URI records must set priority."
  }

  validation {
    condition = alltrue([
      for record in values(var.records) :
      !record.proxied if !contains(["A", "AAAA", "CNAME"], record.type)
    ])
    error_message = "Only A, AAAA and CNAME records can be proxied through Cloudflare."
  }
}
