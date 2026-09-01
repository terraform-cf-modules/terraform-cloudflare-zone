# -----------------------------------------------------------------------------
# Submodule: ssl
#
# Universal SSL, Total TLS, advanced certificate packs, customer supplied
# certificates and per hostname TLS overrides.
# -----------------------------------------------------------------------------

locals {
  custom_certificate_keys = var.enabled ? nonsensitive(toset(keys(var.custom_certificates))) : toset([])
}

resource "cloudflare_universal_ssl_setting" "this" {
  count = var.enabled && var.universal_ssl_enabled != null ? 1 : 0

  zone_id = var.zone_id
  enabled = var.universal_ssl_enabled
}

resource "cloudflare_total_tls" "this" {
  count = var.enabled && var.total_tls != null ? 1 : 0

  zone_id               = var.zone_id
  enabled               = var.total_tls.enabled
  certificate_authority = try(var.total_tls.certificate_authority, null)
}

resource "cloudflare_certificate_pack" "this" {
  for_each = var.enabled ? var.certificate_packs : {}

  zone_id               = var.zone_id
  certificate_authority = each.value.certificate_authority
  hosts                 = each.value.hosts
  type                  = each.value.type
  validation_method     = each.value.validation_method
  validity_days         = each.value.validity_days
  cloudflare_branding   = each.value.cloudflare_branding
}

# The map keys are plain identifiers, but the map itself is sensitive because it
# carries private keys. for_each rejects sensitive values, so iterate the keys
# with the sensitivity stripped and look the entry up by key.
resource "cloudflare_custom_ssl" "this" {
  for_each = local.custom_certificate_keys

  zone_id          = var.zone_id
  certificate      = var.custom_certificates[each.key].certificate
  private_key      = var.custom_certificates[each.key].private_key
  bundle_method    = var.custom_certificates[each.key].bundle_method
  custom_csr_id    = var.custom_certificates[each.key].custom_csr_id
  deploy           = var.custom_certificates[each.key].deploy
  policy           = var.custom_certificates[each.key].policy
  type             = var.custom_certificates[each.key].type
  geo_restrictions = var.custom_certificates[each.key].geo_restrictions
}

resource "cloudflare_hostname_tls_setting" "this" {
  for_each = var.enabled ? var.hostname_tls_settings : {}

  zone_id    = var.zone_id
  hostname   = each.value.hostname
  setting_id = each.value.setting_id
  value      = each.value.value
}
