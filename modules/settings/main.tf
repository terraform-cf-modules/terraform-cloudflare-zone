# -----------------------------------------------------------------------------
# Submodule: settings
#
# Zone settings, zone level DNS settings, zone holds, URL normalization and
# managed header transforms.
#
# In provider v5 cloudflare_zone_setting is a single generic resource keyed by
# setting_id with a dynamic value, rather than the one big cloudflare_zone_settings_override
# resource that v4 had. One resource instance is created per setting.
# -----------------------------------------------------------------------------

locals {
  # for_each over a map(string) of setting IDs keeps the key set statically known
  # even though the setting values themselves are of mixed types.
  setting_ids = var.enabled ? { for setting_id in keys(var.zone_settings) : setting_id => setting_id } : {}
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.setting_ids

  zone_id    = var.zone_id
  setting_id = each.key
  value      = var.zone_settings[each.key]
  enabled    = try(var.zone_settings_enabled[each.key], null)
}

resource "cloudflare_zone_dns_settings" "this" {
  count = var.enabled && var.dns_settings != null ? 1 : 0

  zone_id             = var.zone_id
  flatten_all_cnames  = try(var.dns_settings.flatten_all_cnames, null)
  foundation_dns      = try(var.dns_settings.foundation_dns, null)
  multi_provider      = try(var.dns_settings.multi_provider, null)
  ns_ttl              = try(var.dns_settings.ns_ttl, null)
  secondary_overrides = try(var.dns_settings.secondary_overrides, null)
  zone_mode           = try(var.dns_settings.zone_mode, null)
  internal_dns        = try(var.dns_settings.internal_dns, null)
  nameservers         = try(var.dns_settings.nameservers, null)
  soa                 = try(var.dns_settings.soa, null)
}

resource "cloudflare_zone_hold" "this" {
  count = var.enabled && var.zone_hold != null ? 1 : 0

  zone_id            = var.zone_id
  hold_after         = try(var.zone_hold.hold_after, null)
  include_subdomains = try(var.zone_hold.include_subdomains, null)
}

resource "cloudflare_url_normalization_settings" "this" {
  count = var.enabled && var.url_normalization != null ? 1 : 0

  zone_id = var.zone_id
  scope   = var.url_normalization.scope
  type    = var.url_normalization.type
}

resource "cloudflare_managed_transforms" "this" {
  count = var.enabled && var.managed_transforms != null ? 1 : 0

  zone_id = var.zone_id

  managed_request_headers = [
    for transform_id, transform_enabled in try(var.managed_transforms.managed_request_headers, {}) : {
      id      = transform_id
      enabled = transform_enabled
    }
  ]

  managed_response_headers = [
    for transform_id, transform_enabled in try(var.managed_transforms.managed_response_headers, {}) : {
      id      = transform_id
      enabled = transform_enabled
    }
  ]
}
