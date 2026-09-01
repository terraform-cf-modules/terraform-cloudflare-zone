# -----------------------------------------------------------------------------
# Submodule: dns-record
#
# Creates cloudflare_dns_record for every entry in var.records. Structured record
# types (SRV, CAA, LOC, SSHFP, TLSA, SVCB, HTTPS, DS, NAPTR, CERT) use the data
# object instead of content.
# -----------------------------------------------------------------------------

resource "cloudflare_dns_record" "this" {
  for_each = var.enabled ? var.records : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl

  content         = each.value.content
  priority        = each.value.priority
  proxied         = each.value.proxied
  comment         = each.value.comment
  tags            = each.value.tags
  private_routing = each.value.private_routing

  data     = each.value.data
  settings = each.value.settings
}
