# -----------------------------------------------------------------------------
# Submodule: dnssec
#
# Signs the zone. Cloudflare generates the keys, this module only records the
# desired state and exposes the DS record that has to be published at the
# registrar before the chain of trust is complete.
# -----------------------------------------------------------------------------

resource "cloudflare_zone_dnssec" "this" {
  count = var.enabled ? 1 : 0

  zone_id             = var.zone_id
  status              = var.status
  dnssec_multi_signer = var.dnssec_multi_signer
  dnssec_presigned    = var.dnssec_presigned
  dnssec_use_nsec3    = var.dnssec_use_nsec3
}
