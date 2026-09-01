variable "zone_id" {
  description = "Cloudflare zone ID of the SaaS provider's own zone."
  type        = string
  default     = "00000000000000000000000000000000"
}

variable "zone_name" {
  description = "Domain name of the SaaS provider's own zone."
  type        = string
  default     = "example.com"
}

variable "customers" {
  description = "Customer domains to serve, keyed by a stable customer identifier."
  type = map(object({
    hostname = string
    origin   = optional(string)
  }))
  default = {
    customer_one = {
      hostname = "app.customer-one.example"
    }
    customer_two = {
      hostname = "portal.customer-two.example"
      origin   = "tenant-two.origin.example.com"
    }
  }
}
