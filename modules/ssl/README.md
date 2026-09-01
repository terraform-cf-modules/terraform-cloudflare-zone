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
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_certificate_packs"></a> [certificate\_packs](#input\_certificate\_packs) | Advanced certificate packs to order, keyed by a stable identifier. | <pre>map(object({<br/>    certificate_authority = string<br/>    hosts                 = set(string)<br/>    validation_method     = string<br/>    validity_days         = number<br/>    type                  = optional(string, "advanced")<br/>    cloudflare_branding   = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_certificates"></a> [custom\_certificates](#input\_custom\_certificates) | Customer supplied SSL certificates to upload to the zone, keyed by a stable identifier. private\_key is the certificate key, not a Cloudflare API credential, and the variable is marked sensitive. | <pre>map(object({<br/>    certificate   = string<br/>    private_key   = string<br/>    bundle_method = optional(string)<br/>    custom_csr_id = optional(string)<br/>    deploy        = optional(string)<br/>    policy        = optional(string)<br/>    type          = optional(string)<br/>    geo_restrictions = optional(object({<br/>      label = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_hostname_tls_settings"></a> [hostname\_tls\_settings](#input\_hostname\_tls\_settings) | Per hostname TLS overrides, keyed by a stable identifier. Each entry sets one setting on one hostname. | <pre>map(object({<br/>    hostname   = string<br/>    setting_id = string<br/>    value      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_total_tls"></a> [total\_tls](#input\_total\_tls) | Total TLS, which issues certificates for every hostname in the zone rather than only the apex and one wildcard level. Null means Total TLS is not managed. | <pre>object({<br/>    enabled               = bool<br/>    certificate_authority = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_universal_ssl_enabled"></a> [universal\_ssl\_enabled](#input\_universal\_ssl\_enabled) | Whether Universal SSL is enabled for the zone. Null leaves the current Cloudflare value untouched. Disabling it removes the free certificate from every hostname in the zone. | `bool` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID the certificates and TLS settings apply to. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_certificate_pack_ids"></a> [certificate\_pack\_ids](#output\_certificate\_pack\_ids) | Map of certificate pack IDs, keyed by the same keys as var.certificate\_packs. |
| <a name="output_certificate_pack_validation_records"></a> [certificate\_pack\_validation\_records](#output\_certificate\_pack\_validation\_records) | Validation records that must be published before each certificate pack is issued, keyed by the same keys as var.certificate\_packs. |
| <a name="output_certificate_packs"></a> [certificate\_packs](#output\_certificate\_packs) | Map of full cloudflare\_certificate\_pack objects, keyed by the same keys as var.certificate\_packs. |
| <a name="output_custom_certificate_ids"></a> [custom\_certificate\_ids](#output\_custom\_certificate\_ids) | Map of custom certificate IDs, keyed by the same keys as var.custom\_certificates. |
| <a name="output_custom_certificates"></a> [custom\_certificates](#output\_custom\_certificates) | Map of full cloudflare\_custom\_ssl objects, keyed by the same keys as var.custom\_certificates. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_hostname_tls_settings"></a> [hostname\_tls\_settings](#output\_hostname\_tls\_settings) | Map of full cloudflare\_hostname\_tls\_setting objects, keyed by the same keys as var.hostname\_tls\_settings. |
| <a name="output_total_tls"></a> [total\_tls](#output\_total\_tls) | The full cloudflare\_total\_tls object, or null when not managed. |
| <a name="output_universal_ssl"></a> [universal\_ssl](#output\_universal\_ssl) | The full cloudflare\_universal\_ssl\_setting object, or null when not managed. |
<!-- END_TF_DOCS -->
