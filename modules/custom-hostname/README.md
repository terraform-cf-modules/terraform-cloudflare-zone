# Submodule: custom-hostname

SSL for SaaS custom hostnames, the fallback origin they share, and Regional Services hostnames.

```hcl
module "custom_hostnames" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/custom-hostname"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  fallback_origin = "fallback.example.com"

  custom_hostnames = {
    customer_one = {
      hostname = "app.customer-one.com"
      ssl = {
        method                = "http"
        type                  = "dv"
        certificate_authority = "google"
        settings = {
          min_tls_version = "1.2"
          http2           = "on"
        }
      }
    }
  }

  regional_hostnames = {
    eu_api = {
      hostname   = "api.example.com"
      region_key = "eu"
    }
  }
}
```

Notes:

- The fallback origin must itself be a proxied record inside the zone, and it has to be reachable before
  Cloudflare will move a custom hostname to `active`.
- `ownership_verification` gives the DNS and HTTP tokens the customer publishes on their own domain.
- The `custom_hostnames` variable and matching output are `sensitive` because the `ssl` object can carry a
  certificate private key.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
