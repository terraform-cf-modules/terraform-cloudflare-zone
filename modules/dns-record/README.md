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
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_records"></a> [records](#input\_records) | DNS records to create, keyed by a stable identifier. The key is only a state address, it does not have to match the record name. Renaming a key destroys and recreates the record. | <pre>map(object({<br/>    name            = string<br/>    type            = string<br/>    ttl             = optional(number, 1)<br/>    content         = optional(string)<br/>    priority        = optional(number)<br/>    proxied         = optional(bool, false)<br/>    comment         = optional(string)<br/>    tags            = optional(set(string))<br/>    private_routing = optional(bool)<br/><br/>    settings = optional(object({<br/>      flatten_cname = optional(bool)<br/>      ipv4_only     = optional(bool)<br/>      ipv6_only     = optional(bool)<br/>    }))<br/><br/>    data = optional(object({<br/>      algorithm      = optional(number)<br/>      altitude       = optional(number)<br/>      certificate    = optional(string)<br/>      digest         = optional(string)<br/>      digest_type    = optional(number)<br/>      fingerprint    = optional(string)<br/>      flags          = optional(number)<br/>      key_tag        = optional(number)<br/>      lat_degrees    = optional(number)<br/>      lat_direction  = optional(string)<br/>      lat_minutes    = optional(number)<br/>      lat_seconds    = optional(number)<br/>      long_degrees   = optional(number)<br/>      long_direction = optional(string)<br/>      long_minutes   = optional(number)<br/>      long_seconds   = optional(number)<br/>      matching_type  = optional(number)<br/>      order          = optional(number)<br/>      port           = optional(number)<br/>      precision_horz = optional(number)<br/>      precision_vert = optional(number)<br/>      preference     = optional(number)<br/>      priority       = optional(number)<br/>      protocol       = optional(number)<br/>      public_key     = optional(string)<br/>      regex          = optional(string)<br/>      replacement    = optional(string)<br/>      selector       = optional(number)<br/>      service        = optional(string)<br/>      size           = optional(number)<br/>      tag            = optional(string)<br/>      target         = optional(string)<br/>      type           = optional(number)<br/>      usage          = optional(number)<br/>      value          = optional(string)<br/>      weight         = optional(number)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID the records belong to. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_record_ids"></a> [record\_ids](#output\_record\_ids) | Map of DNS record IDs, keyed by the same keys as var.records. |
| <a name="output_record_names"></a> [record\_names](#output\_record\_names) | Map of fully qualified record names, keyed by the same keys as var.records. |
| <a name="output_records"></a> [records](#output\_records) | Map of full cloudflare\_dns\_record objects, keyed by the same keys as var.records. |
<!-- END_TF_DOCS -->
