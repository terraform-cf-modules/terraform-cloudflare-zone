# Plan only. Runs on every pull request, including forks, with no credentials.

mock_provider "cloudflare" {
  override_during = plan
}

variables {
  account_id = "00000000000000000000000000000000"
  zone_name  = "example.com"
}

run "creates_nothing_when_disabled" {
  command = plan

  variables {
    enabled = false

    dns_records = {
      apex = { name = "example.com", type = "A", content = "192.0.2.1" }
    }
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module reported enabled while var.enabled was false."
  }

  assert {
    condition     = length(cloudflare_zone.this) == 0
    error_message = "Module created a zone while var.enabled was false."
  }

  assert {
    condition     = length(output.dns_record_ids) == 0
    error_message = "Module created DNS records while var.enabled was false."
  }

  assert {
    condition     = length(output.zone_settings) == 0
    error_message = "Module created zone settings while var.enabled was false."
  }
}

run "enabled_by_default" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should be enabled by default."
  }

  assert {
    condition     = length(cloudflare_zone.this) == 1
    error_message = "Module should create exactly one zone by default."
  }

  assert {
    condition     = cloudflare_zone.this[0].name == "example.com"
    error_message = "Zone was not created with the requested name."
  }
}

run "applies_the_secure_baseline" {
  command = plan

  assert {
    condition     = length(output.zone_settings) == 5
    error_message = "The secure baseline should manage exactly five zone settings."
  }

  assert {
    condition     = output.zone_settings["min_tls_version"].value == "1.2"
    error_message = "min_tls_version should default to 1.2."
  }

  assert {
    condition     = output.zone_settings["always_use_https"].value == "on"
    error_message = "always_use_https should default to on."
  }

  assert {
    condition     = output.zone_settings["ssl"].value == "full"
    error_message = "ssl should default to full."
  }
}

run "baseline_entries_drop_out_when_set_to_null" {
  command = plan

  variables {
    ssl_mode                 = null
    tls_1_3                  = null
    automatic_https_rewrites = null
  }

  assert {
    condition     = length(output.zone_settings) == 2
    error_message = "Setting a baseline input to null should stop the module managing that setting."
  }
}

run "caller_settings_override_the_baseline" {
  command = plan

  variables {
    zone_settings = {
      ssl               = "strict"
      brotli            = "on"
      browser_cache_ttl = 14400
    }
  }

  assert {
    condition     = output.zone_settings["ssl"].value == "strict"
    error_message = "An entry in zone_settings should override the matching baseline input."
  }

  assert {
    condition     = length(output.zone_settings) == 7
    error_message = "Baseline and caller settings should merge rather than replace one another."
  }

  assert {
    condition     = output.zone_settings["browser_cache_ttl"].value == 14400
    error_message = "A numeric setting value should stay a number rather than being coerced to a string by the merge."
  }
}

run "creates_dns_records" {
  command = plan

  variables {
    dns_records = {
      apex = {
        name    = "example.com"
        type    = "A"
        content = "192.0.2.1"
        proxied = true
      }
      mail = {
        name     = "example.com"
        type     = "MX"
        content  = "mx1.example.net"
        priority = 10
        ttl      = 3600
      }
      caa = {
        name = "example.com"
        type = "CAA"
        ttl  = 3600
        data = {
          flags = 0
          tag   = "issue"
          value = "letsencrypt.org"
        }
      }
    }
  }

  assert {
    condition     = length(output.dns_records) == 3
    error_message = "Expected one DNS record per entry in var.dns_records."
  }

  assert {
    condition     = output.dns_records["apex"].ttl == 1
    error_message = "ttl should default to 1, which means automatic."
  }

  assert {
    condition     = output.dns_records["caa"].data.tag == "issue"
    error_message = "Structured record data was not passed through to the resource."
  }
}

run "dnssec_is_off_by_default" {
  command = plan

  assert {
    condition     = output.dnssec == null
    error_message = "DNSSEC should not be managed unless dnssec_enabled is true."
  }
}

run "dnssec_can_be_enabled" {
  command = plan

  variables {
    dnssec_enabled = true
    dnssec = {
      status           = "active"
      dnssec_use_nsec3 = true
    }
  }

  assert {
    condition     = output.dnssec != null
    error_message = "DNSSEC should be managed when dnssec_enabled is true."
  }

  assert {
    condition     = output.dnssec.dnssec_use_nsec3 == true
    error_message = "DNSSEC options were not passed through to the resource."
  }
}

run "cache_creates_nothing_unless_asked" {
  command = plan

  assert {
    condition     = output.cache.tiered_cache == null
    error_message = "Tiered cache should not be managed unless the input is set."
  }

  assert {
    condition     = output.cache.cache_reserve == null
    error_message = "Cache reserve should not be managed unless the input is set."
  }
}

run "cache_is_managed_when_asked" {
  command = plan

  variables {
    tiered_cache       = "on"
    cache_reserve      = "off"
    argo_smart_routing = "on"
    cache_variants = {
      jpeg = ["image/webp"]
    }
  }

  assert {
    condition     = output.cache.tiered_cache.value == "on"
    error_message = "Tiered cache value was not passed through."
  }

  assert {
    condition     = output.cache.cache_variants.value.jpeg == tolist(["image/webp"])
    error_message = "Cache variants were not passed through."
  }
}

run "attaches_to_an_existing_zone" {
  command = plan

  variables {
    create_zone = false
    zone_name   = null
    zone_id     = "11111111111111111111111111111111"
  }

  assert {
    condition     = length(cloudflare_zone.this) == 0
    error_message = "Module should not create a zone when create_zone is false."
  }

  assert {
    condition     = output.zone_id == "11111111111111111111111111111111"
    error_message = "Module should report the existing zone ID it was given."
  }
}

run "ssl_and_custom_hostnames_are_off_by_default" {
  command = plan

  assert {
    condition     = output.universal_ssl == null
    error_message = "Universal SSL should not be managed unless the input is set."
  }

  assert {
    condition     = length(output.certificate_packs) == 0
    error_message = "No certificate packs should be ordered by default."
  }

  assert {
    condition     = length(output.custom_hostname_ids) == 0
    error_message = "No custom hostnames should be created by default."
  }
}

run "managed_transforms_convert_a_keyed_map_to_the_api_shape" {
  command = plan

  variables {
    managed_transforms = {
      managed_request_headers = {
        add_true_client_ip_headers = true
      }
      managed_response_headers = {
        remove_x_powered_by_header = false
      }
    }
  }

  assert {
    condition     = length(output.managed_transforms.managed_request_headers) == 1
    error_message = "Managed request headers were not converted from the keyed map."
  }

  assert {
    condition = one([
      for header in output.managed_transforms.managed_request_headers :
      header.id
    ]) == "add_true_client_ip_headers"
    error_message = "Managed transform ID was not taken from the map key."
  }
}
