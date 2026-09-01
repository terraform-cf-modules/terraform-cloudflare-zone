variable "enabled" {
  description = "Whether to create the resources managed by this submodule."
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Cloudflare zone ID to sign."
  type        = string
  default     = null
}

variable "status" {
  description = "Desired DNSSEC state for the zone."
  type        = string
  default     = "active"

  validation {
    condition     = var.status == null || contains(["active", "disabled"], coalesce(var.status, "active"))
    error_message = "status must be one of active, disabled."
  }
}

variable "dnssec_multi_signer" {
  description = "Allow several providers to serve the signed zone at the same time. Required before external DNSKEY records can be added."
  type        = bool
  default     = null
}

variable "dnssec_presigned" {
  description = "Transfer in an already signed zone including its signatures, without Cloudflare signing records on the fly."
  type        = bool
  default     = null
}

variable "dnssec_use_nsec3" {
  description = "Use NSEC3 rather than NSEC for authenticated denial of existence."
  type        = bool
  default     = null
}
