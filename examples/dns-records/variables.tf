variable "zone_id" {
  description = "Cloudflare zone ID of the existing zone."
  type        = string
  default     = "00000000000000000000000000000000"
}

variable "zone_name" {
  description = "Domain name of the existing zone, used to build record names."
  type        = string
  default     = "example.com"
}
