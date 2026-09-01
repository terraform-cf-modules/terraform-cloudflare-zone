# Submodule: dns-record

Creates `cloudflare_dns_record` for every entry in a keyed map. Supports every record type the Cloudflare
provider exposes, including the structured types that use `data` rather than `content`.

```hcl
module "dns_records" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/dns-record"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  records = {
    apex = {
      name    = "example.com"
      type    = "A"
      content = "192.0.2.1"
      proxied = true
    }

    www = {
      name    = "www.example.com"
      type    = "CNAME"
      content = "example.com"
      proxied = true
    }

    spf = {
      name    = "example.com"
      type    = "TXT"
      content = "v=spf1 include:_spf.example.net -all"
      ttl     = 3600
    }

    mail = {
      name     = "example.com"
      type     = "MX"
      content  = "mx1.example.net"
      priority = 10
      ttl      = 3600
    }

    sip = {
      name = "_sip._tcp.example.com"
      type = "SRV"
      ttl  = 3600
      data = {
        priority = 10
        weight   = 20
        port     = 5060
        target   = "sip.example.net"
      }
    }
  }
}
```

Notes:

- `ttl` is `1` for automatic. Any other value must be between 30 and 86400.
- Only `A`, `AAAA` and `CNAME` records can be proxied.
- Map keys are state addresses. Renaming a key destroys and recreates the record.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
