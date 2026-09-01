# -----------------------------------------------------------------------------
# Module: Cloudflare Zone
# Zones, DNS records, DNSSEC, TLS settings, custom hostnames, and cache configuration.
#
# The root module composes the common case: create the zone, publish its DNS
# records, and apply a secure baseline. Individual building blocks live under
# modules/ and are consumed with the double slash source syntax:
#
#   source = "terraform-cf-modules/zone/cloudflare//modules/<name>"
# -----------------------------------------------------------------------------

resource "cloudflare_zone" "this" {
  count = local.create_zone ? 1 : 0

  account = {
    id = var.account_id
  }

  name                = var.zone_name
  type                = var.zone_type
  paused              = var.paused
  vanity_name_servers = var.vanity_name_servers
}

module "dns_record" {
  source = "./modules/dns-record"

  enabled = local.enabled
  zone_id = local.zone_id
  records = var.dns_records
}

module "dnssec" {
  source = "./modules/dnssec"

  enabled             = local.enabled && var.dnssec_enabled
  zone_id             = local.zone_id
  status              = var.dnssec.status
  dnssec_multi_signer = var.dnssec.dnssec_multi_signer
  dnssec_presigned    = var.dnssec.dnssec_presigned
  dnssec_use_nsec3    = var.dnssec.dnssec_use_nsec3
}

module "settings" {
  source = "./modules/settings"

  enabled               = local.enabled
  zone_id               = local.zone_id
  zone_settings         = local.zone_settings
  zone_settings_enabled = var.zone_settings_enabled
  dns_settings          = var.dns_settings
  zone_hold             = var.zone_hold
  url_normalization     = var.url_normalization
  managed_transforms    = var.managed_transforms
}

module "ssl" {
  source = "./modules/ssl"

  enabled               = local.enabled
  zone_id               = local.zone_id
  universal_ssl_enabled = var.universal_ssl_enabled
  total_tls             = var.total_tls
  certificate_packs     = var.certificate_packs
  custom_certificates   = var.custom_certificates
  hostname_tls_settings = var.hostname_tls_settings
}

module "custom_hostname" {
  source = "./modules/custom-hostname"

  enabled            = local.enabled
  zone_id            = local.zone_id
  custom_hostnames   = var.custom_hostnames
  fallback_origin    = var.custom_hostname_fallback_origin
  regional_hostnames = var.regional_hostnames
}

module "cache" {
  source = "./modules/cache"

  enabled               = local.enabled
  zone_id               = local.zone_id
  tiered_cache          = var.tiered_cache
  argo_tiered_caching   = var.argo_tiered_caching
  regional_tiered_cache = var.regional_tiered_cache
  cache_reserve         = var.cache_reserve
  cache_variants        = var.cache_variants
  argo_smart_routing    = var.argo_smart_routing
}
