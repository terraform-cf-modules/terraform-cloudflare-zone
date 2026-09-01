# Input validation. Plan only, no credentials.

mock_provider "cloudflare" {
  override_during = plan
}

variables {
  account_id = "00000000000000000000000000000000"
  zone_name  = "example.com"
}

run "rejects_malformed_account_id" {
  command = plan

  variables {
    account_id = "not-a-valid-account-id"
  }

  expect_failures = [var.account_id]
}

run "rejects_malformed_zone_id" {
  command = plan

  variables {
    create_zone = false
    zone_name   = null
    zone_id     = "TOO-SHORT"
  }

  expect_failures = [var.zone_id]
}

run "requires_account_id_when_creating_a_zone" {
  command = plan

  variables {
    account_id = null
  }

  expect_failures = [var.account_id]
}

run "requires_zone_id_when_not_creating_a_zone" {
  command = plan

  variables {
    create_zone = false
    zone_name   = null
    zone_id     = null
  }

  expect_failures = [var.zone_id]
}

run "requires_zone_name_when_creating_a_zone" {
  command = plan

  variables {
    zone_name = null
  }

  expect_failures = [var.zone_name]
}

run "rejects_malformed_zone_name" {
  command = plan

  variables {
    zone_name = "not a domain"
  }

  expect_failures = [var.zone_name]
}

run "rejects_unknown_zone_type" {
  command = plan

  variables {
    zone_type = "hybrid"
  }

  expect_failures = [var.zone_type]
}

run "rejects_unknown_ssl_mode" {
  command = plan

  variables {
    ssl_mode = "very_strict"
  }

  expect_failures = [var.ssl_mode]
}

run "rejects_unknown_min_tls_version" {
  command = plan

  variables {
    min_tls_version = "1.4"
  }

  expect_failures = [var.min_tls_version]
}

run "rejects_unknown_always_use_https" {
  command = plan

  variables {
    always_use_https = "yes"
  }

  expect_failures = [var.always_use_https]
}

run "rejects_unknown_tls_1_3" {
  command = plan

  variables {
    tls_1_3 = "maybe"
  }

  expect_failures = [var.tls_1_3]
}

run "rejects_unknown_automatic_https_rewrites" {
  command = plan

  variables {
    automatic_https_rewrites = "sometimes"
  }

  expect_failures = [var.automatic_https_rewrites]
}

run "rejects_malformed_zone_setting_id" {
  command = plan

  variables {
    zone_settings = {
      "Always-Use-HTTPS" = "on"
    }
  }

  expect_failures = [var.zone_settings]
}

run "rejects_unknown_dnssec_status" {
  command = plan

  variables {
    dnssec_enabled = true
    dnssec = {
      status = "paused"
    }
  }

  expect_failures = [var.dnssec]
}

run "rejects_unknown_url_normalization_scope" {
  command = plan

  variables {
    url_normalization = {
      scope = "outgoing"
      type  = "cloudflare"
    }
  }

  expect_failures = [var.url_normalization]
}

run "rejects_unknown_url_normalization_type" {
  command = plan

  variables {
    url_normalization = {
      scope = "incoming"
      type  = "rfc1738"
    }
  }

  expect_failures = [var.url_normalization]
}

run "rejects_unknown_total_tls_certificate_authority" {
  command = plan

  variables {
    total_tls = {
      enabled               = true
      certificate_authority = "digicert"
    }
  }

  expect_failures = [var.total_tls]
}

run "rejects_unknown_cache_values" {
  command = plan

  variables {
    tiered_cache = "enabled"
  }

  expect_failures = [var.tiered_cache]
}

run "rejects_unknown_argo_smart_routing_value" {
  command = plan

  variables {
    argo_smart_routing = "fast"
  }

  expect_failures = [var.argo_smart_routing]
}

run "rejects_unknown_cache_reserve_value" {
  command = plan

  variables {
    cache_reserve = "r2"
  }

  expect_failures = [var.cache_reserve]
}

run "rejects_unknown_regional_tiered_cache_value" {
  command = plan

  variables {
    regional_tiered_cache = "eu"
  }

  expect_failures = [var.regional_tiered_cache]
}

run "rejects_unknown_argo_tiered_caching_value" {
  command = plan

  variables {
    argo_tiered_caching = "argo"
  }

  expect_failures = [var.argo_tiered_caching]
}

# ---------------------------------------------------------------------------
# Submodule validations. expect_failures only sees checkable objects in the
# module under test, so each run swaps the module under test to the submodule
# that owns the validation.
# ---------------------------------------------------------------------------

run "rejects_unknown_dns_record_type" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      bad = { name = "example.com", type = "ALIAS", content = "example.net" }
    }
  }

  expect_failures = [var.records]
}

run "rejects_out_of_range_dns_record_ttl" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      bad = { name = "example.com", type = "A", content = "192.0.2.1", ttl = 10 }
    }
  }

  expect_failures = [var.records]
}

run "rejects_a_dns_record_with_neither_content_nor_data" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      bad = { name = "example.com", type = "A" }
    }
  }

  expect_failures = [var.records]
}

run "rejects_an_mx_record_without_priority" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      bad = { name = "example.com", type = "MX", content = "mx1.example.net" }
    }
  }

  expect_failures = [var.records]
}

run "rejects_a_proxied_txt_record" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      bad = { name = "example.com", type = "TXT", content = "hello", proxied = true }
    }
  }

  expect_failures = [var.records]
}

run "accepts_a_valid_record_set" {
  command = plan

  module {
    source = "./modules/dns-record"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    records = {
      apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
      srv = {
        name = "_sip._tcp.example.com"
        type = "SRV"
        ttl  = 3600
        data = { priority = 10, weight = 20, port = 5060, target = "sip.example.net" }
      }
    }
  }

  assert {
    condition     = length(cloudflare_dns_record.this) == 2
    error_message = "A valid record set should produce one resource per entry."
  }
}

run "rejects_unknown_certificate_pack_validity_days" {
  command = plan

  module {
    source = "./modules/ssl"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    certificate_packs = {
      bad = {
        certificate_authority = "google"
        hosts                 = ["example.com"]
        validation_method     = "txt"
        validity_days         = 180
      }
    }
  }

  expect_failures = [var.certificate_packs]
}

run "rejects_unknown_certificate_pack_authority" {
  command = plan

  module {
    source = "./modules/ssl"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    certificate_packs = {
      bad = {
        certificate_authority = "digicert"
        hosts                 = ["example.com"]
        validation_method     = "txt"
        validity_days         = 90
      }
    }
  }

  expect_failures = [var.certificate_packs]
}

run "rejects_unknown_hostname_tls_setting_id" {
  command = plan

  module {
    source = "./modules/ssl"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    hostname_tls_settings = {
      bad = {
        hostname   = "api.example.com"
        setting_id = "tls_1_3"
        value      = "on"
      }
    }
  }

  expect_failures = [var.hostname_tls_settings]
}

run "rejects_a_bad_min_tls_version_on_a_hostname" {
  command = plan

  module {
    source = "./modules/ssl"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    hostname_tls_settings = {
      bad = {
        hostname   = "api.example.com"
        setting_id = "min_tls_version"
        value      = "1.4"
      }
    }
  }

  expect_failures = [var.hostname_tls_settings]
}

run "rejects_unknown_custom_certificate_bundle_method" {
  command = plan

  module {
    source = "./modules/ssl"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    custom_certificates = {
      bad = {
        certificate   = "-----BEGIN CERTIFICATE-----"
        private_key   = "-----BEGIN PRIVATE KEY-----"
        bundle_method = "shortest"
      }
    }
  }

  expect_failures = [var.custom_certificates]
}

run "rejects_unknown_custom_hostname_validation_method" {
  command = plan

  module {
    source = "./modules/custom-hostname"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    custom_hostnames = {
      bad = {
        hostname = "app.customer.example"
        ssl = {
          method = "dns"
        }
      }
    }
  }

  expect_failures = [var.custom_hostnames]
}

run "rejects_unknown_custom_hostname_certificate_authority" {
  command = plan

  module {
    source = "./modules/custom-hostname"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    custom_hostnames = {
      bad = {
        hostname = "app.customer.example"
        ssl = {
          certificate_authority = "sectigo"
        }
      }
    }
  }

  expect_failures = [var.custom_hostnames]
}

run "rejects_a_malformed_region_key" {
  command = plan

  module {
    source = "./modules/custom-hostname"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    regional_hostnames = {
      bad = {
        hostname   = "api.example.com"
        region_key = "EU West"
      }
    }
  }

  expect_failures = [var.regional_hostnames]
}

run "rejects_unknown_dns_settings_zone_mode" {
  command = plan

  module {
    source = "./modules/settings"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    dns_settings = {
      zone_mode = "proxy_only"
    }
  }

  expect_failures = [var.dns_settings]
}

run "rejects_unknown_nameserver_type" {
  command = plan

  module {
    source = "./modules/settings"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    dns_settings = {
      nameservers = {
        type = "custom.something"
      }
    }
  }

  expect_failures = [var.dns_settings]
}

run "rejects_a_malformed_setting_id_in_the_settings_submodule" {
  command = plan

  module {
    source = "./modules/settings"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    zone_settings = {
      "SSL" = "full"
    }
  }

  expect_failures = [var.zone_settings]
}

run "rejects_unknown_dnssec_status_in_the_dnssec_submodule" {
  command = plan

  module {
    source = "./modules/dnssec"
  }

  variables {
    zone_id = "00000000000000000000000000000000"
    status  = "paused"
  }

  expect_failures = [var.status]
}

run "rejects_unknown_cache_value_in_the_cache_submodule" {
  command = plan

  module {
    source = "./modules/cache"
  }

  variables {
    zone_id      = "00000000000000000000000000000000"
    tiered_cache = "enabled"
  }

  expect_failures = [var.tiered_cache]
}
