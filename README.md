<p align="center">
  <img width="1000" alt="CloudDrove Banner" src="https://clouddrove.s3.ca-central-1.amazonaws.com/img/clouddrove-github-cover.png" />
</p>

<h1 align="center">Terraform Cloudflare Zone</h1>
<p align="center"><em>Zones, DNS records, DNSSEC, TLS settings, custom hostnames, and cache configuration.</em></p>

<p align="center">
  <a href="https://www.terraform.io"><img src="https://img.shields.io/badge/terraform-%3E%3D%201.10-844FBA?logo=terraform&logoColor=white" alt="Terraform" /></a>
  <a href="https://opentofu.org"><img src="https://img.shields.io/badge/opentofu-%3E%3D%201.9-FFDA18?logo=opentofu&logoColor=black" alt="OpenTofu" /></a>
  <a href="https://registry.terraform.io/providers/cloudflare/cloudflare/latest"><img src="https://img.shields.io/badge/provider-cloudflare%20~%3E%205.24-F38020?logo=cloudflare&logoColor=white" alt="Cloudflare Provider" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License" /></a>
</p>

---

Creates a Cloudflare zone together with its DNS records, DNSSEC, TLS posture, custom hostnames and cache
configuration.

The root module is the common path: it gets you from "I own this domain" to "it resolves and it is secured" in
one block. It applies a secure baseline by default, and every default is overridable.

| Baseline setting | Default | Override with |
|------------------|---------|---------------|
| `ssl` | `full` | `ssl_mode` |
| `min_tls_version` | `1.2` | `min_tls_version` |
| `always_use_https` | `on` | `always_use_https` |
| `tls_1_3` | `on` | `tls_1_3` |
| `automatic_https_rewrites` | `on` | `automatic_https_rewrites` |

Set any of those to `null` and the module stops managing that setting, leaving whatever Cloudflare currently
has. Anything else goes in `zone_settings`, which is keyed by the Cloudflare setting ID.

Registry address: `terraform-cf-modules/zone/cloudflare`.

---

## Usage

### Create a zone

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
    spf  = { name = "example.com", type = "TXT", content = "v=spf1 -all", ttl = 3600 }
    mail = { name = "example.com", type = "MX", content = "mx1.example.net", priority = 10, ttl = 3600 }
  }

  dnssec_enabled = true
}

output "name_servers" {
  value = module.zone.name_servers
}

output "ds_record" {
  value = module.zone.dnssec_ds
}
```

Set the name servers from `name_servers` at your registrar, then publish `dnssec_ds` there to complete DNSSEC.

### Manage an existing zone

```hcl
module "records" {
  source  = "terraform-cf-modules/zone/cloudflare"
  version = "~> 0.1"

  create_zone = false
  zone_id     = var.zone_id

  dns_records = {
    api = { name = "api.example.com", type = "A", content = "192.0.2.2", proxied = true }
  }

  # Own DNS only; leave the zone's existing settings alone.
  ssl_mode                 = null
  min_tls_version          = null
  always_use_https         = null
  tls_1_3                  = null
  automatic_https_rewrites = null
}
```

### Many zones at once

```hcl
module "zones" {
  source = "terraform-cf-modules/zone/cloudflare//wrappers"

  defaults = {
    account_id      = var.account_id
    ssl_mode        = "strict"
    min_tls_version = "1.2"
    dnssec_enabled  = true
  }

  items = {
    example_com = { zone_name = "example.com" }
    example_org = { zone_name = "example.org" }
    legacy      = { zone_name = "legacy.example", enabled = false }
  }
}
```

---

## Submodules

Each one works on its own against any zone, whether or not this module created it.

| Submodule | Manages |
|-----------|---------|
| [`dns-record`](modules/dns-record) | `cloudflare_dns_record` for every record type, simple and structured |
| [`dnssec`](modules/dnssec) | `cloudflare_zone_dnssec` |
| [`settings`](modules/settings) | `cloudflare_zone_setting`, `cloudflare_zone_dns_settings`, `cloudflare_zone_hold`, `cloudflare_url_normalization_settings`, `cloudflare_managed_transforms` |
| [`ssl`](modules/ssl) | `cloudflare_universal_ssl_setting`, `cloudflare_total_tls`, `cloudflare_certificate_pack`, `cloudflare_custom_ssl`, `cloudflare_hostname_tls_setting` |
| [`custom-hostname`](modules/custom-hostname) | `cloudflare_custom_hostname`, `cloudflare_custom_hostname_fallback_origin`, `cloudflare_regional_hostname` |
| [`cache`](modules/cache) | `cloudflare_tiered_cache`, `cloudflare_argo_tiered_caching`, `cloudflare_regional_tiered_cache`, `cloudflare_zone_cache_reserve`, `cloudflare_zone_cache_variants`, `cloudflare_argo_smart_routing` |

```hcl
module "cache" {
  source  = "terraform-cf-modules/zone/cloudflare//modules/cache"
  version = "~> 0.1"

  zone_id      = var.zone_id
  tiered_cache = "on"
}
```

---

## Examples

| Example | What it shows |
|---------|---------------|
| [`examples/basic`](examples/basic) | Minimum viable zone: apex, www and the secure baseline |
| [`examples/complete`](examples/complete) | Every optional feature turned on |
| [`examples/dns-records`](examples/dns-records) | Structured record types (`CAA`, `SRV`, `SSHFP`) on an existing zone |
| [`examples/ssl-for-saas`](examples/ssl-for-saas) | Custom hostnames, fallback origin and customer domain validation |

---

## DNS records

`dns_records` is a map keyed by a stable identifier. The key is only a state address, so it does not have to
match the record name, but renaming a key destroys and recreates the record.

Simple types set `content`:

```hcl
apex = { name = "example.com", type = "A", content = "192.0.2.1", proxied = true }
```

Structured types set `data` instead, whose fields differ per record type:

```hcl
caa = {
  name = "example.com"
  type = "CAA"
  ttl  = 3600
  data = { flags = 0, tag = "issue", value = "letsencrypt.org" }
}

sip = {
  name = "_sip._tcp.example.com"
  type = "SRV"
  ttl  = 3600
  data = { priority = 10, weight = 20, port = 5060, target = "sip.example.net" }
}
```

Rules the module enforces at plan time:

- `type` must be one of the 21 types the provider supports.
- `ttl` is `1` for automatic, or between 30 and 86400.
- Every record sets either `content` or `data`.
- `MX` and `URI` records set `priority`.
- Only `A`, `AAAA` and `CNAME` records can be proxied.

---

## Zone settings

Provider v5 replaced the single `cloudflare_zone_settings_override` resource with one `cloudflare_zone_setting`
per setting, whose `value` is dynamic. `zone_settings` therefore takes raw values of whatever type the setting
wants:

```hcl
zone_settings = {
  brotli            = "on"
  browser_cache_ttl = 14400
  security_level    = "medium"
}
```

Entries here override the five named baseline inputs. Setting IDs are validated for shape only, because
Cloudflare adds settings without a provider release; an unknown ID is rejected by the API at apply time. See the
[zone settings API reference](https://developers.cloudflare.com/api/resources/zones/subresources/settings/).

---

## Things that finish outside Terraform

Three features apply cleanly and then wait on something Terraform cannot do:

| Feature | What still has to happen |
|---------|--------------------------|
| DNSSEC | Publish `dnssec_ds` at the registrar |
| Certificate packs | Publish `certificate_pack_validation_records` |
| Custom hostnames | The customer publishes `custom_hostname_ownership_verification` in their own DNS |

A successful apply on any of these means "ordered", not "issued".

---

## Repository layout

```
terraform.tf          provider and version requirements
main.tf               zone plus the submodule calls
variables.tf          root module inputs
outputs.tf            root module outputs
locals.tf             enabled switch, zone_id resolution, settings merge
modules/<name>/       composable building blocks, same file layout
examples/             basic, complete, dns-records, ssl-for-saas
wrappers/             for_each wrapper for many zones
tests/                native terraform test files
docs/architecture.md  resource map, ordering, provider quirks
```

---

## Local development

```bash
pre-commit install

make fmt        # terraform fmt -recursive
make validate   # init and validate every directory
make lint       # tflint
make docs       # regenerate the terraform-docs blocks
make test       # mocked terraform test, no credentials needed
make security   # trivy, checkov, gitleaks
make ci         # all of the above
```

`make test` runs against `mock_provider`, so it needs no Cloudflare credentials. The live tests in
`tests/integration.tftest.hcl` run only on schedule and manual dispatch, and they attach to an existing test
zone rather than registering a domain.

---

## CI

Most workflows call the shared, actively maintained
[clouddrove/github-shared-workflows](https://github.com/clouddrove/github-shared-workflows) at `@v2`, so the
standard changes in one place for every repository.

| Workflow | Source | Purpose |
|----------|--------|---------|
| `tf-checks` | shared | init and validate every example |
| `tflint` | shared | lint |
| `checkov` | shared | policy scan |
| `gitleaks` | shared | secret scan |
| `pr_checks` | shared | Conventional Commit pull request title |
| `auto_assignee` | shared | reviewer assignment |
| `automerge` | shared | auto merge on green |
| `stale_pr` | shared | stale handling |
| `readme` | shared | rebuild README from README.yaml |
| `tag-release` | shared | tag and changelog on merge |
| `opentofu` | local | OpenTofu compatibility |
| `test` | local | `terraform test` with mocked provider |
| `integration` | local | live apply against a test account, scheduled only |

### Required organisation secrets

| Secret | Used by |
|--------|---------|
| `GITHUB` | `tflint`, `tag-release`, `auto_assignee`, `automerge`, `readme` |
| `SLACK_WEBHOOK_TERRAFORM` | `readme` |
| `CLOUDFLARE_API_TOKEN` | `integration` |
| `CLOUDFLARE_TEST_ACCOUNT_ID` | `integration` |
| `CLOUDFLARE_TEST_ZONE_ID` | `integration` |

---

## Inputs and outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

---

## License

Apache 2.0. See [LICENSE](LICENSE).

Maintained by [CloudDrove](https://clouddrove.com) and [Cloud Wizz](https://github.com/cloud-wizz).
