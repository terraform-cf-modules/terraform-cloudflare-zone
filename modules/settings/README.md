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
<!-- END_TF_DOCS -->
