# Submodule: settings

Zone settings, zone level DNS settings, zone holds, URL normalization and Cloudflare managed header transforms.

In provider v5, `cloudflare_zone_setting` is a generic resource: one instance per setting, addressed by
`setting_id`, with a `dynamic` value. The v4 `cloudflare_zone_settings_override` resource no longer exists.
That is why `zone_settings` here is an untyped map: the value can be a string, a number or an object depending
on which setting it is.

```hcl
module "settings" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/settings"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  zone_settings = {
    ssl                      = "full"
    min_tls_version          = "1.2"
    always_use_https         = "on"
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    brotli                   = "on"
    browser_cache_ttl        = 14400
  }

  dns_settings = {
    flatten_all_cnames = true
    ns_ttl             = 86400
  }

  zone_hold = {
    include_subdomains = true
  }

  url_normalization = {
    scope = "incoming"
    type  = "cloudflare"
  }

  managed_transforms = {
    managed_request_headers = {
      add_true_client_ip_headers = true
    }
    managed_response_headers = {
      remove_x_powered_by_header = true
    }
  }
}
```

Setting IDs are not validated against a fixed list, because Cloudflare adds settings without a provider
release. The provider rejects an unknown `setting_id` at apply time. See the
[zone settings API reference](https://developers.cloudflare.com/api/resources/zones/subresources/settings/)
for the current list.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_settings"></a> [dns\_settings](#input\_dns\_settings) | Zone level DNS settings such as CNAME flattening, nameserver selection and the SOA record. Null leaves the Cloudflare defaults alone. | <pre>object({<br/>    flatten_all_cnames  = optional(bool)<br/>    foundation_dns      = optional(bool)<br/>    multi_provider      = optional(bool)<br/>    ns_ttl              = optional(number)<br/>    secondary_overrides = optional(bool)<br/>    zone_mode           = optional(string)<br/><br/>    internal_dns = optional(object({<br/>      reference_zone_id = optional(string)<br/>    }))<br/><br/>    nameservers = optional(object({<br/>      ns_set = optional(number)<br/>      type   = optional(string)<br/>    }))<br/><br/>    soa = optional(object({<br/>      expire  = optional(number)<br/>      min_ttl = optional(number)<br/>      mname   = optional(string)<br/>      refresh = optional(number)<br/>      retry   = optional(number)<br/>      rname   = optional(string)<br/>      ttl     = optional(number)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_managed_transforms"></a> [managed\_transforms](#input\_managed\_transforms) | Cloudflare managed header transforms, keyed by the managed transform ID and mapped to whether it is enabled, for example { add\_true\_client\_ip\_headers = true }. Null means managed transforms are not managed by this module. | <pre>object({<br/>    managed_request_headers  = optional(map(bool), {})<br/>    managed_response_headers = optional(map(bool), {})<br/>  })</pre> | `null` | no |
| <a name="input_url_normalization"></a> [url\_normalization](#input\_url\_normalization) | URL normalization applied before rules run. Null leaves the Cloudflare default alone. | <pre>object({<br/>    scope = string<br/>    type  = string<br/>  })</pre> | `null` | no |
| <a name="input_zone_hold"></a> [zone\_hold](#input\_zone\_hold) | Zone hold, which stops the domain being added to another Cloudflare account. Null means no hold is managed. | <pre>object({<br/>    hold_after         = optional(string)<br/>    include_subdomains = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID the settings apply to. | `string` | `null` | no |
| <a name="input_zone_settings"></a> [zone\_settings](#input\_zone\_settings) | Zone settings, keyed by the Cloudflare setting ID and mapped to the setting value. The value is passed through untouched because cloudflare\_zone\_setting takes a dynamic value, so a string such as "full", a number such as 14400, or an object are all valid. | `any` | `{}` | no |
| <a name="input_zone_settings_enabled"></a> [zone\_settings\_enabled](#input\_zone\_settings\_enabled) | Optional enabled flag per zone setting, keyed by the same setting ID used in zone\_settings. Only a small number of settings, such as ssl\_recommender, use it. | `map(bool)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_settings"></a> [dns\_settings](#output\_dns\_settings) | The full cloudflare\_zone\_dns\_settings object, or null when not managed. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_managed_transforms"></a> [managed\_transforms](#output\_managed\_transforms) | The full cloudflare\_managed\_transforms object, or null when not managed. |
| <a name="output_managed_transforms_id"></a> [managed\_transforms\_id](#output\_managed\_transforms\_id) | ID of the managed transforms resource, or null when not managed. |
| <a name="output_url_normalization"></a> [url\_normalization](#output\_url\_normalization) | The full cloudflare\_url\_normalization\_settings object, or null when not managed. |
| <a name="output_url_normalization_id"></a> [url\_normalization\_id](#output\_url\_normalization\_id) | ID of the URL normalization settings, or null when not managed. |
| <a name="output_zone_hold"></a> [zone\_hold](#output\_zone\_hold) | The full cloudflare\_zone\_hold object, or null when not managed. |
| <a name="output_zone_hold_id"></a> [zone\_hold\_id](#output\_zone\_hold\_id) | ID of the zone hold, or null when not managed. |
| <a name="output_zone_setting_ids"></a> [zone\_setting\_ids](#output\_zone\_setting\_ids) | Map of zone setting resource IDs, keyed by the Cloudflare setting ID. |
| <a name="output_zone_settings"></a> [zone\_settings](#output\_zone\_settings) | Map of full cloudflare\_zone\_setting objects, keyed by the Cloudflare setting ID. |
<!-- END_TF_DOCS -->
