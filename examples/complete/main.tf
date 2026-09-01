# Every optional feature of the Cloudflare Zone module turned on.
#
# This example is deliberately exhaustive rather than realistic. Several of the
# features here need a paid Cloudflare plan: certificate packs need Advanced
# Certificate Manager, custom hostnames need SSL for SaaS, and Argo Smart
# Routing and Cache Reserve are billed separately.

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}

module "this" {
  source = "../../"

  enabled    = true
  account_id = var.account_id

  # ---------------------------------------------------------------------------
  # Zone
  # ---------------------------------------------------------------------------
  create_zone = true
  zone_name   = var.zone_name
  zone_type   = "full"
  paused      = false

  # ---------------------------------------------------------------------------
  # DNS
  # ---------------------------------------------------------------------------
  dns_records = {
    apex = {
      name    = var.zone_name
      type    = "A"
      content = "192.0.2.1"
      proxied = true
      comment = "Managed by Terraform"
      tags    = ["managed:terraform"]
    }

    apex_v6 = {
      name    = var.zone_name
      type    = "AAAA"
      content = "2001:db8::1"
      proxied = true
    }

    www = {
      name    = "www.${var.zone_name}"
      type    = "CNAME"
      content = var.zone_name
      proxied = true
      settings = {
        flatten_cname = true
      }
    }

    mail = {
      name     = var.zone_name
      type     = "MX"
      content  = "mx1.${var.zone_name}"
      priority = 10
      ttl      = 3600
    }

    spf = {
      name    = var.zone_name
      type    = "TXT"
      content = "v=spf1 include:_spf.example.net -all"
      ttl     = 3600
    }

    caa = {
      name = var.zone_name
      type = "CAA"
      ttl  = 3600
      data = {
        flags = 0
        tag   = "issue"
        value = "letsencrypt.org"
      }
    }

    sip = {
      name = "_sip._tcp.${var.zone_name}"
      type = "SRV"
      ttl  = 3600
      data = {
        priority = 10
        weight   = 20
        port     = 5060
        target   = "sip.example.net"
      }
    }
  }

  dns_settings = {
    flatten_all_cnames = true
    multi_provider     = false
    ns_ttl             = 86400
    zone_mode          = "standard"

    soa = {
      expire  = 604800
      min_ttl = 1800
      mname   = "ns1.example.net"
      refresh = 10000
      retry   = 2400
      rname   = "hostmaster.example.com"
      ttl     = 3600
    }
  }

  # ---------------------------------------------------------------------------
  # DNSSEC
  # ---------------------------------------------------------------------------
  dnssec_enabled = true

  dnssec = {
    status           = "active"
    dnssec_use_nsec3 = true
  }

  # ---------------------------------------------------------------------------
  # Settings. The five named inputs below are the module defaults, repeated here
  # so the example shows them; zone_settings adds anything else.
  # ---------------------------------------------------------------------------
  ssl_mode                 = "full"
  min_tls_version          = "1.2"
  always_use_https         = "on"
  tls_1_3                  = "on"
  automatic_https_rewrites = "on"

  zone_settings = {
    brotli                   = "on"
    browser_cache_ttl        = 14400
    early_hints              = "on"
    http3                    = "on"
    ipv6                     = "on"
    opportunistic_encryption = "on"
    security_level           = "medium"
    websockets               = "on"
    zero_rtt                 = "on"
  }

  zone_hold = {
    include_subdomains = true
  }

  url_normalization = {
    scope = "incoming"
    type  = "cloudflare"
  }

  managed_transforms = {
    managed_request_headers = {
      add_true_client_ip_headers = true
    }
    managed_response_headers = {
      remove_x_powered_by_header = true
    }
  }

  # ---------------------------------------------------------------------------
  # TLS and certificates
  # ---------------------------------------------------------------------------
  universal_ssl_enabled = true

  total_tls = {
    enabled               = true
    certificate_authority = "google"
  }

  certificate_packs = {
    wildcard = {
      certificate_authority = "lets_encrypt"
      hosts                 = [var.zone_name, "*.${var.zone_name}"]
      validation_method     = "txt"
      validity_days         = 90
      cloudflare_branding   = false
    }
  }

  hostname_tls_settings = {
    api_min_tls = {
      hostname   = "api.${var.zone_name}"
      setting_id = "min_tls_version"
      value      = "1.3"
    }
  }

  # ---------------------------------------------------------------------------
  # Custom hostnames
  # ---------------------------------------------------------------------------
  custom_hostname_fallback_origin = "fallback.${var.zone_name}"

  custom_hostnames = {
    customer_one = {
      hostname = "app.customer-one.example"
      ssl = {
        method                = "http"
        type                  = "dv"
        certificate_authority = "google"
        bundle_method         = "ubiquitous"
        wildcard              = false
        settings = {
          min_tls_version = "1.2"
          http2           = "on"
          tls_1_3         = "on"
          early_hints     = "on"
        }
      }
    }
  }

  regional_hostnames = {
    eu_api = {
      hostname   = "api.${var.zone_name}"
      region_key = "eu"
    }
  }

  # ---------------------------------------------------------------------------
  # Cache
  # ---------------------------------------------------------------------------
  tiered_cache          = "on"
  regional_tiered_cache = "on"
  cache_reserve         = "off"
  argo_smart_routing    = "off"

  cache_variants = {
    jpeg = ["image/webp", "image/avif"]
    png  = ["image/webp"]
  }
}
