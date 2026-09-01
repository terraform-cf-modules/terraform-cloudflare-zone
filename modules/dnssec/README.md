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
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dnssec_multi_signer"></a> [dnssec\_multi\_signer](#input\_dnssec\_multi\_signer) | Allow several providers to serve the signed zone at the same time. Required before external DNSKEY records can be added. | `bool` | `null` | no |
| <a name="input_dnssec_presigned"></a> [dnssec\_presigned](#input\_dnssec\_presigned) | Transfer in an already signed zone including its signatures, without Cloudflare signing records on the fly. | `bool` | `null` | no |
| <a name="input_dnssec_use_nsec3"></a> [dnssec\_use\_nsec3](#input\_dnssec\_use\_nsec3) | Use NSEC3 rather than NSEC for authenticated denial of existence. | `bool` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to create the resources managed by this submodule. | `bool` | `true` | no |
| <a name="input_status"></a> [status](#input\_status) | Desired DNSSEC state for the zone. | `string` | `"active"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID to sign. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_digest"></a> [digest](#output\_digest) | Digest of the zone signing key. |
| <a name="output_dnssec"></a> [dnssec](#output\_dnssec) | The full cloudflare\_zone\_dnssec object, or null when DNSSEC is not managed. |
| <a name="output_ds"></a> [ds](#output\_ds) | DS record to publish at the registrar to complete the chain of trust. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether this submodule created its resources. |
| <a name="output_id"></a> [id](#output\_id) | ID of the DNSSEC resource, or null when DNSSEC is not managed. |
| <a name="output_key_tag"></a> [key\_tag](#output\_key\_tag) | Key tag of the zone signing key. |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | Public key of the zone signing key. |
| <a name="output_status"></a> [status](#output\_status) | Reported DNSSEC status for the zone. |
<!-- END_TF_DOCS -->
