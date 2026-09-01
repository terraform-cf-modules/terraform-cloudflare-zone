# -----------------------------------------------------------------------------
# Submodule: custom-hostname
#
# SSL for SaaS custom hostnames, their shared fallback origin, and Regional
# Services hostnames.
# -----------------------------------------------------------------------------

locals {
  # The map keys are plain identifiers, but the map itself is sensitive because
  # the ssl block can carry a certificate private key. for_each rejects
  # sensitive values, so iterate the keys with the sensitivity stripped and look
  # the entry up by key.
  custom_hostname_keys = var.enabled ? nonsensitive(toset(keys(var.custom_hostnames))) : toset([])
}

resource "cloudflare_custom_hostname" "this" {
  for_each = local.custom_hostname_keys

  zone_id              = var.zone_id
  hostname             = var.custom_hostnames[each.key].hostname
  custom_origin_server = var.custom_hostnames[each.key].custom_origin_server
  custom_origin_sni    = var.custom_hostnames[each.key].custom_origin_sni
  custom_metadata      = var.custom_hostnames[each.key].custom_metadata
  ssl                  = var.custom_hostnames[each.key].ssl
}

resource "cloudflare_custom_hostname_fallback_origin" "this" {
  count = var.enabled && var.fallback_origin != null ? 1 : 0

  zone_id = var.zone_id
  origin  = var.fallback_origin
}

resource "cloudflare_regional_hostname" "this" {
  for_each = var.enabled ? var.regional_hostnames : {}

  zone_id    = var.zone_id
  hostname   = each.value.hostname
  region_key = each.value.region_key
  routing    = each.value.routing
}
