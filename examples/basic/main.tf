# Minimum viable configuration for the Cloudflare Zone module.
#
# Creates the zone, points the apex and www at an origin, and applies the
# module's secure baseline: SSL full, minimum TLS 1.2, always use HTTPS, TLS 1.3
# and automatic HTTPS rewrites on.

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}

module "this" {
  source = "../../"

  enabled    = true
  account_id = var.account_id
  zone_name  = var.zone_name

  dns_records = {
    apex = {
      name    = var.zone_name
      type    = "A"
      content = "192.0.2.1"
      proxied = true
    }

    www = {
      name    = "www.${var.zone_name}"
      type    = "CNAME"
      content = var.zone_name
      proxied = true
    }
  }
}
