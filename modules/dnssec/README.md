# Submodule: dnssec

Enables DNSSEC on a zone with `cloudflare_zone_dnssec` and exposes the DS record that must be published at the
registrar. Until that DS record exists, Cloudflare reports the zone as `pending`.

```hcl
module "dnssec" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/dnssec"
  version = "~> 0.1"

  enabled          = true
  zone_id          = var.zone_id
  status           = "active"
  dnssec_use_nsec3 = true
}

output "ds_record" {
  value = module.dnssec.ds
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
