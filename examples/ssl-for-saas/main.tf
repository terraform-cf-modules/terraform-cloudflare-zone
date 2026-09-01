# SSL for SaaS: serving your customers' own domains from your zone.
#
# The moving parts, in the order they have to happen:
#
# 1. A proxied record inside your zone acts as the fallback origin. It is a real
#    hostname in your zone, not the customer's domain.
# 2. cloudflare_custom_hostname_fallback_origin points every custom hostname at
#    that record unless the hostname overrides it with custom_origin_server.
# 3. Each custom hostname is validated by the customer, who publishes the
#    ownership_verification token in their own DNS or serves the HTTP token.
# 4. Cloudflare issues a certificate for the customer domain once validation
#    passes. Until then the hostname sits at status "pending".
#
# The fallback origin record and the fallback origin resource are created by the
# same module call here, and the provider infers the ordering from the zone_id
# reference, so no depends_on is needed.

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}

module "this" {
  source = "../../"

  enabled     = true
  create_zone = false
  zone_id     = var.zone_id

  # The fallback origin has to be proxied, otherwise Cloudflare cannot terminate
  # TLS for the customer hostnames in front of it.
  dns_records = {
    fallback = {
      name    = "fallback.${var.zone_name}"
      type    = "CNAME"
      content = "origin.${var.zone_name}"
      proxied = true
    }
  }

  custom_hostname_fallback_origin = "fallback.${var.zone_name}"

  custom_hostnames = {
    for key, customer in var.customers : key => {
      hostname             = customer.hostname
      custom_origin_server = customer.origin

      ssl = {
        method                = "txt"
        type                  = "dv"
        certificate_authority = "google"
        bundle_method         = "ubiquitous"
        wildcard              = false

        settings = {
          min_tls_version = "1.2"
          http2           = "on"
          tls_1_3         = "on"
        }
      }
    }
  }

  # Total TLS covers every hostname in your own zone, not the customer domains,
  # which get their certificates through the custom hostname above.
  total_tls = {
    enabled               = true
    certificate_authority = "google"
  }

  # Leave the zone wide settings alone: this configuration owns SaaS hostnames.
  ssl_mode                 = null
  min_tls_version          = null
  always_use_https         = null
  tls_1_3                  = null
  automatic_https_rewrites = null
}
