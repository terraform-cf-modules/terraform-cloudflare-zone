locals {
  # Single switch consulted by every resource in this module.
  enabled = var.enabled

  # The zone resource is only created when the caller asks for it. When
  # create_zone is false the module manages records and settings on a zone that
  # already exists, addressed by var.zone_id.
  create_zone = local.enabled && var.create_zone

  # Downstream submodules always read the zone through this value so that the
  # created and the pre existing case look identical to them.
  zone_id = var.create_zone ? one(cloudflare_zone.this[*].id) : var.zone_id

  # Baseline security posture. Any entry set to null by the caller drops out and
  # is left untouched in Cloudflare.
  baseline_settings = {
    for setting_id, value in {
      ssl                      = var.ssl_mode
      min_tls_version          = var.min_tls_version
      always_use_https         = var.always_use_https
      tls_1_3                  = var.tls_1_3
      automatic_https_rewrites = var.automatic_https_rewrites
    } : setting_id => value if value != null
  }

  # Caller supplied settings win over the baseline.
  zone_settings = merge(local.baseline_settings, var.zone_settings)
}
