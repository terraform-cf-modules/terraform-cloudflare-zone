# Submodule: ssl

Certificate and TLS surface for a zone: Universal SSL, Total TLS, advanced certificate packs, customer supplied
certificates, and per hostname TLS overrides.

```hcl
module "ssl" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/ssl"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  universal_ssl_enabled = true

  total_tls = {
    enabled               = true
    certificate_authority = "google"
  }

  certificate_packs = {
    wildcard = {
      certificate_authority = "lets_encrypt"
      hosts                 = ["example.com", "*.example.com"]
      validation_method     = "txt"
      validity_days         = 90
    }
  }

  hostname_tls_settings = {
    api_min_tls = {
      hostname   = "api.example.com"
      setting_id = "min_tls_version"
      value      = "1.3"
    }
  }
}
```

Notes:

- `certificate_packs` needs Advanced Certificate Manager on the zone. `type` only accepts `advanced`.
- `custom_certificates` takes a certificate and its private key. That key is a TLS key, not a Cloudflare API
  credential, so the module accepts it, marks the variable and the matching output `sensitive`, and expects the
  caller to source it from a secret store rather than a `.tfvars` file.
- Disabling `universal_ssl_enabled` removes the free certificate from every hostname in the zone. Only do it
  when a custom certificate or certificate pack already covers those hostnames.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
