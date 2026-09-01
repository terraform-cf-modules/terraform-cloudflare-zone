variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
  default     = "00000000000000000000000000000000"
}

variable "zone_name" {
  description = "Domain name of the zone to create."
  type        = string
  default     = "example.com"
}
