# -----------------------------------------------------------------------------
# Wrapper: create many zones from a single map.
#
#   module "zones" {
#     source = "terraform-cf-modules/zone/cloudflare//wrappers"
#
#     defaults = {
#       account_id       = var.account_id
#       ssl_mode         = "strict"
#       min_tls_version  = "1.2"
#       dnssec_enabled   = true
#     }
#
#     items = {
#       example_com = {
#         zone_name = "example.com"
#         dns_records = {
#           apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
#         }
#       }
#       example_org = { zone_name = "example.org" }
#     }
#   }
# -----------------------------------------------------------------------------

module "wrapper" {
  source = "../"

  for_each = var.items

  enabled    = try(each.value.enabled, var.defaults.enabled, true)
  account_id = try(each.value.account_id, var.defaults.account_id, null)
  zone_id    = try(each.value.zone_id, var.defaults.zone_id, null)

  create_zone         = try(each.value.create_zone, var.defaults.create_zone, true)
  zone_name           = try(each.value.zone_name, var.defaults.zone_name, null)
  zone_type           = try(each.value.zone_type, var.defaults.zone_type, null)
  paused              = try(each.value.paused, var.defaults.paused, null)
  vanity_name_servers = try(each.value.vanity_name_servers, var.defaults.vanity_name_servers, null)

  dns_records  = try(each.value.dns_records, var.defaults.dns_records, {})
  dns_settings = try(each.value.dns_settings, var.defaults.dns_settings, null)

  dnssec_enabled = try(each.value.dnssec_enabled, var.defaults.dnssec_enabled, false)
  dnssec         = try(each.value.dnssec, var.defaults.dnssec, {})

  ssl_mode                 = try(each.value.ssl_mode, var.defaults.ssl_mode, "full")
  min_tls_version          = try(each.value.min_tls_version, var.defaults.min_tls_version, "1.2")
  always_use_https         = try(each.value.always_use_https, var.defaults.always_use_https, "on")
  tls_1_3                  = try(each.value.tls_1_3, var.defaults.tls_1_3, "on")
  automatic_https_rewrites = try(each.value.automatic_https_rewrites, var.defaults.automatic_https_rewrites, "on")

  zone_settings         = try(each.value.zone_settings, var.defaults.zone_settings, {})
  zone_settings_enabled = try(each.value.zone_settings_enabled, var.defaults.zone_settings_enabled, {})
  zone_hold             = try(each.value.zone_hold, var.defaults.zone_hold, null)
  url_normalization     = try(each.value.url_normalization, var.defaults.url_normalization, null)
  managed_transforms    = try(each.value.managed_transforms, var.defaults.managed_transforms, null)

  universal_ssl_enabled = try(each.value.universal_ssl_enabled, var.defaults.universal_ssl_enabled, null)
  total_tls             = try(each.value.total_tls, var.defaults.total_tls, null)
  certificate_packs     = try(each.value.certificate_packs, var.defaults.certificate_packs, {})
  custom_certificates   = try(each.value.custom_certificates, var.defaults.custom_certificates, {})
  hostname_tls_settings = try(each.value.hostname_tls_settings, var.defaults.hostname_tls_settings, {})

  custom_hostnames                = try(each.value.custom_hostnames, var.defaults.custom_hostnames, {})
  custom_hostname_fallback_origin = try(each.value.custom_hostname_fallback_origin, var.defaults.custom_hostname_fallback_origin, null)
  regional_hostnames              = try(each.value.regional_hostnames, var.defaults.regional_hostnames, {})

  tiered_cache          = try(each.value.tiered_cache, var.defaults.tiered_cache, null)
  argo_tiered_caching   = try(each.value.argo_tiered_caching, var.defaults.argo_tiered_caching, null)
  regional_tiered_cache = try(each.value.regional_tiered_cache, var.defaults.regional_tiered_cache, null)
  cache_reserve         = try(each.value.cache_reserve, var.defaults.cache_reserve, null)
  cache_variants        = try(each.value.cache_variants, var.defaults.cache_variants, null)
  argo_smart_routing    = try(each.value.argo_smart_routing, var.defaults.argo_smart_routing, null)
}
