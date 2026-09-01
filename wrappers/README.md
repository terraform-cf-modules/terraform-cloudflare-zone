# Wrapper

Creates many zones from a single map, so a fleet of domains does not need a repeated `module` block per domain.

```hcl
module "zones" {
  source = "terraform-cf-modules/zone/cloudflare//wrappers"

  defaults = {
    account_id      = var.account_id
    ssl_mode        = "strict"
    min_tls_version = "1.2"
    dnssec_enabled  = true
  }

  items = {
    example_com = {
      zone_name = "example.com"

      dns_records = {
        apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
        www  = { name = "www.example.com", type = "CNAME", content = "example.com", proxied = true }
      }
    }

    example_org = {
      zone_name = "example.org"
      paused    = true
    }

    legacy = {
      zone_name = "legacy.example"
      enabled   = false
    }
  }
}
```

Every root module input can be set in `defaults` or per item, and the item wins. Keys in `items` become the
state addresses, so keep them stable. Renaming a key destroys and recreates that zone.

The `wrapper` output is marked `sensitive` because the root module exposes custom certificates and custom
hostnames, which can carry private keys. Use `zone_ids` and `name_servers` for the values you want to print.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
