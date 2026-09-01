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
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_custom_hostnames"></a> [custom\_hostnames](#input\_custom\_hostnames) | Custom hostnames for SSL for SaaS, keyed by a stable identifier. Marked sensitive because the ssl block can carry a certificate private key. | <pre>map(object({<br/>    hostname             = string<br/>    custom_origin_server = optional(string)<br/>    custom_origin_sni    = optional(string)<br/>    custom_metadata      = optional(map(string))<br/><br/>    ssl = optional(object({<br/>      bundle_method         = optional(string)<br/>      certificate_authority = optional(string)<br/>      cloudflare_branding   = optional(bool)<br/>      custom_certificate    = optional(string)<br/>      custom_csr_id         = optional(string)<br/>      custom_key            = optional(string)<br/>      method                = optional(string)<br/>      type                  = optional(string)<br/>      wildcard              = optional(bool)<br/><br/>      custom_cert_bundle = optional(list(object({<br/>        custom_certificate = string<br/>        custom_key         = string<br/>      })))<br/><br/>      settings = optional(object({<br/>        ciphers         = optional(list(string))<br/>        early_hints     = optional(string)<br/>        http2           = optional(string)<br/>        min_tls_version = optional(string)<br/>        tls_1_3         = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_fallback_origin"></a> [fallback\_origin](#input\_fallback\_origin) | Fallback origin hostname that serves every custom hostname in the zone that has no custom\_origin\_server of its own. Null means no fallback origin is managed. | `string` | `null` | no |
| <a name="input_regional_hostnames"></a> [regional\_hostnames](#input\_regional\_hostnames) | Regional Services hostnames, which pin TLS termination and HTTP processing to a Cloudflare region, keyed by a stable identifier. | <pre>map(object({<br/>    hostname   = string<br/>    region_key = string<br/>    routing    = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID that serves the custom hostnames. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_custom_hostname_ids"></a> [custom\_hostname\_ids](#output\_custom\_hostname\_ids) | Map of custom hostname IDs, keyed by the same keys as var.custom\_hostnames. |
| <a name="output_custom_hostnames"></a> [custom\_hostnames](#output\_custom\_hostnames) | Map of full cloudflare\_custom\_hostname objects, keyed by the same keys as var.custom\_hostnames. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_fallback_origin"></a> [fallback\_origin](#output\_fallback\_origin) | The full cloudflare\_custom\_hostname\_fallback\_origin object, or null when not managed. |
| <a name="output_fallback_origin_id"></a> [fallback\_origin\_id](#output\_fallback\_origin\_id) | ID of the fallback origin, or null when not managed. |
| <a name="output_ownership_verification"></a> [ownership\_verification](#output\_ownership\_verification) | Ownership verification records for each custom hostname, keyed by the same keys as var.custom\_hostnames. Publish these in the customer's own DNS. |
| <a name="output_regional_hostnames"></a> [regional\_hostnames](#output\_regional\_hostnames) | Map of full cloudflare\_regional\_hostname objects, keyed by the same keys as var.regional\_hostnames. |
<!-- END_TF_DOCS -->
