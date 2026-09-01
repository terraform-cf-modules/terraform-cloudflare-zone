<!-- This file was automatically generated from `README.yaml`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
<p align="center">
  <img width="1000" alt="CloudDrove Banner" src="https://clouddrove.s3.ca-central-1.amazonaws.com/img/clouddrove-github-cover.png" />
</p>
<h1 align="center">
    Terraform Cloudflare Zone
</h1>

<p align="center" style="font-size: 1.2rem;">
    With our comprehensive DevOps toolkit, streamline operations, automate workflows, enhance collaboration and deploy with confidence.
</p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.12.0-green" alt="Terraform">
</a>
<a href="LICENSE">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>
<a href="CHANGELOG.md">
  <img src="https://img.shields.io/badge/Changelog-blue" alt="Changelog">
</a>
<a href="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/tf-checks.yml">
  <img src="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/tf-checks.yml/badge.svg" alt="tf-checks">
</a>
<a href="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/tflint.yml">
  <img src="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/tflint.yml/badge.svg" alt="tf-lint">
</a>
<a href="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/checkov.yml">
  <img src="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/checkov.yml/badge.svg" alt="checkov">
</a>
<a href="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/test.yml">
  <img src="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/actions/workflows/test.yml/badge.svg" alt="test">
</a>

</p>
<hr>


Creates a Cloudflare zone together with its DNS records, DNSSEC, TLS posture, custom hostnames and cache
configuration. The root module takes a domain from "I own this name" to "it resolves and it is secured" in a
single block, and the six submodules underneath it are addressable on their own when you only need one piece.

The problem it solves is that a correct Cloudflare zone is not one resource. It is a zone, a pile of DNS
records, a DNSSEC key, one `cloudflare_zone_setting` per setting, a Universal SSL toggle, certificate packs
and a cache topology, each with its own required ordering and its own set of values the API silently rejects.
This module wires those together, validates the enumerated fields at plan time rather than at apply time, and
exposes the values you actually need afterwards (name servers, the DS record for the registrar, custom
hostname ownership verification tokens, certificate validation records).

**The opinion it encodes is a secure TLS baseline, applied by default and overridable in full.** These five
settings are the only ones the module writes without being asked:

| Setting | Default | Why this default |
|---------|---------|------------------|
| `ssl_mode` | `full` | Encrypts the edge to origin hop. `strict` is stronger but requires a valid certificate on the origin, so it is not safe as a default. |
| `min_tls_version` | `1.2` | TLS 1.0 and 1.1 are deprecated and fail most compliance baselines. |
| `always_use_https` | `on` | Plain HTTP is redirected rather than served. |
| `tls_1_3` | `on` | Faster handshake, forward secrecy on every suite. |
| `automatic_https_rewrites` | `on` | Rewrites insecure subresource references in HTML, so enabling HTTPS does not produce mixed content. |

Every one of those is overridable, and setting any of them to `null` leaves whatever Cloudflare currently has
in place untouched, which is what you want when this module owns DNS but somebody else owns the TLS posture.
Everything else in the module defaults to null or an empty map, so nothing is created that you did not ask for.

Set `create_zone = false` and pass `zone_id` to manage records and settings on a zone somebody else created.
For many zones at once, the `wrappers` directory takes a `defaults` object plus an `items` map and calls the
root module once per entry.

Targets Cloudflare provider v5. Cloudflare regenerated the provider from its OpenAPI spec in v5.0.0 and
renamed most resources, so `cloudflare_record` is now `cloudflare_dns_record`, and the single
`cloudflare_zone_settings_override` resource became one `cloudflare_zone_setting` per setting. Examples
written against provider v4 will not apply here.


## Prerequisites and Providers

This table contains both Prerequisites and Providers:

| Description | Name | Version |
|-------------|------|---------|
| Prerequisite | Terraform | >= 1.12.0 |
| Prerequisite | OpenTofu | >= 1.12.0 |
| Provider | cloudflare | ~> 5.24 |

---


## 🧩 Submodules

Each submodule is separately addressable with the double slash source syntax, so you can take only the piece you need instead of the whole root module.

| Submodule | Source | Description |
|-----------|--------|-------------|
| `dns-record` | `terraform-cf-modules/zone/cloudflare//modules/dns-record` | One `cloudflare_dns_record` per entry in a keyed map. Covers the simple types that use `content` and the structured types (SRV, CAA, LOC, SSHFP, TLSA, DS, NAPTR, CERT, SVCB, HTTPS) that use the `data` object instead. |
| `dnssec` | `terraform-cf-modules/zone/cloudflare//modules/dnssec` | `cloudflare_zone_dnssec`. Signs the zone and exposes the DS record, digest, key tag and public key so you can hand them to the registrar. |
| `settings` | `terraform-cf-modules/zone/cloudflare//modules/settings` | `cloudflare_zone_setting` (one per setting ID), plus `cloudflare_zone_dns_settings`, `cloudflare_zone_hold`, `cloudflare_url_normalization_settings` and `cloudflare_managed_transforms`. This is where the secure baseline is written. |
| `ssl` | `terraform-cf-modules/zone/cloudflare//modules/ssl` | `cloudflare_universal_ssl_setting`, `cloudflare_total_tls`, `cloudflare_certificate_pack`, `cloudflare_custom_ssl` and `cloudflare_hostname_tls_setting`. Certificate packs need Advanced Certificate Manager. |
| `custom-hostname` | `terraform-cf-modules/zone/cloudflare//modules/custom-hostname` | SSL for SaaS: `cloudflare_custom_hostname`, `cloudflare_custom_hostname_fallback_origin` and `cloudflare_regional_hostname`. Exposes the per hostname ownership verification tokens your customers have to publish. |
| `cache` | `terraform-cf-modules/zone/cloudflare//modules/cache` | `cloudflare_tiered_cache`, `cloudflare_argo_tiered_caching`, `cloudflare_regional_tiered_cache`, `cloudflare_zone_cache_reserve`, `cloudflare_zone_cache_variants` and `cloudflare_argo_smart_routing`. Argo and Cache Reserve are billed separately. |

---


## 🚀 Usage

### Root module

Creates the zone, points the apex and `www` at an origin, signs the zone, and applies the secure TLS baseline
described above.

```hcl
module "zone" {
  source  = "terraform-cf-modules/zone/cloudflare"
  version = "~> 0.1"

  enabled    = true
  account_id = var.account_id
  zone_name  = "example.com"

  dns_records = {
    apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
    www  = { name = "www.example.com", type = "CNAME", content = "example.com", proxied = true }
    mail = { name = "example.com", type = "MX", content = "mx1.example.net", priority = 10, ttl = 3600 }
    spf  = { name = "example.com", type = "TXT", content = "v=spf1 include:_spf.example.net -all", ttl = 3600 }
  }

  dnssec_enabled = true
}

# Hand this to the registrar to complete the DNSSEC chain of trust.
output "ds_record" {
  value = module.zone.dnssec_ds
}
```

### DNS on a zone somebody else owns

`create_zone = false` attaches the module to an existing zone by ID, so it manages records only. Setting the
five baseline inputs to `null` leaves that zone's current TLS configuration exactly as it is.

```hcl
module "records" {
  source  = "terraform-cf-modules/zone/cloudflare"
  version = "~> 0.1"

  create_zone = false
  zone_id     = var.zone_id

  dns_records = {
    api = { name = "api.example.com", type = "A", content = "192.0.2.2", proxied = true }

    # Structured types use `data`, not `content`. Cloudflare rejects `content` on these.
    caa = {
      name = "example.com"
      type = "CAA"
      data = { flags = 0, tag = "issue", value = "pki.goog" }
    }

    sip = {
      name = "_sip._tcp.example.com"
      type = "SRV"
      data = { priority = 10, weight = 5, port = 5060, target = "sip.example.net" }
    }
  }

  # This configuration owns DNS only. Leave the zone's TLS posture alone.
  ssl_mode                 = null
  min_tls_version          = null
  always_use_https         = null
  tls_1_3                  = null
  automatic_https_rewrites = null
}
```

### A submodule on its own

Each submodule is usable without the root module. This is the shape to reach for when DNS and TLS are owned by
different teams or live in different state files.

```hcl
module "records" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/dns-record"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  records = {
    apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
    www  = { name = "www.example.com", type = "CNAME", content = "example.com", proxied = true }
  }
}

module "tls" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/settings"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  # Keyed by the Cloudflare setting ID, so any setting the API exposes is reachable.
  zone_settings = {
    ssl                      = "strict"
    min_tls_version          = "1.2"
    always_use_https         = "on"
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    browser_cache_ttl        = 14400
  }
}
```

### SSL for SaaS

Serving your customers' own domains from your zone. The fallback origin must be a proxied record inside your
zone, and each custom hostname stays at status `pending` until the customer publishes the ownership
verification token exposed on the output.

```hcl
module "saas" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/custom-hostname"
  version = "~> 0.1"

  enabled = true
  zone_id = var.zone_id

  fallback_origin = "fallback.example.com"

  custom_hostnames = {
    acme = {
      hostname             = "www.acme-customer.com"
      custom_origin_server = "origin.example.com"

      ssl = {
        method                = "txt"
        type                  = "dv"
        certificate_authority = "google"
        bundle_method         = "ubiquitous"
        wildcard              = false

        settings = {
          min_tls_version = "1.2"
          http2           = "on"
          tls_1_3         = "on"
        }
      }
    }
  }
}

# Give each customer their verification token.
output "ownership_verification" {
  value = module.saas.ownership_verification
}
```

### Many zones from one block

```hcl
module "zones" {
  source  = "terraform-cf-modules/zone/cloudflare//wrappers"
  version = "~> 0.1"

  defaults = {
    account_id      = var.account_id
    ssl_mode        = "strict"
    min_tls_version = "1.2"
    dnssec_enabled  = true
  }

  items = {
    example_com = { zone_name = "example.com" }
    example_org = { zone_name = "example.org" }
  }
}
```

---


## 📦 Examples

> ⚠️ **Important:** Avoid using the `main` branch directly, as it may include unstable changes. Always use stable [release versions](https://github.com/terraform-cf-modules/terraform-cloudflare-zone/releases).

Explore real-world usage scenarios and implementation patterns in the [`examples/`](./examples/) directory.

---


## 📥 Inputs and Outputs

Detailed input variables and output values are documented for easier integration and day-to-day usage.

📘 [View full documentation](docs/io.md)

---


## 📝 Changelog

Track module updates, improvements, and breaking changes across versions.

📌 [View Changelog](CHANGELOG.md)

---


## ✨ Contributors

Big thanks to our contributors for elevating our project with their dedication and expertise!

<div align="center">
  <a href="https://github.com/terraform-cf-modules/terraform-cloudflare-zone/graphs/contributors" title="Contributors">
    <img src="https://contrib.rocks/image?repo=terraform-cf-modules/terraform-cloudflare-zone" />
  </a>
</div>

All contributors must follow the [Conventional Commits](https://www.conventionalcommits.org) specification for commit messages.

---


## 🚀 Our Accomplishment

We maintain Terraform modules across AWS, Azure, Google Cloud, DigitalOcean, Hetzner Cloud and Cloudflare 🙌.

- [**Terraform Module Registry**](https://registry.terraform.io/namespaces/terraform-cf-modules): Discover our Cloudflare modules here.
- [**Full module catalog**](https://github.com/clouddrove/toc): Every CloudDrove module and submodule, across every cloud.

---

## Notes

- Do not use the `main` branch for production deployments.
- Always reference a stable version using Git tags or official releases.
- Using tagged versions ensures consistency, stability, and reproducible deployments.

---

## Feedback

Report issues or request features on [GitHub](https://github.com/terraform-cf-modules/terraform-cloudflare-zone/issues), or write to [business@clouddrove.com](mailto:business@clouddrove.com).

## About us

At [CloudDrove](https://clouddrove.com), we build reliable, secure and cost efficient cloud native solutions. Join our [Slack community](https://www.launchpass.com/devops-talks).
