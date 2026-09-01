# Architecture

This module owns a Cloudflare **zone** and everything that hangs off it: DNS records, DNSSEC, zone settings,
certificates, custom hostnames and cache behaviour.

The root module is the common path. It creates the zone, publishes its records and applies a secure baseline in
one block. Each submodule under `modules/` is usable on its own against a zone the module did not create.

```
root (cloudflare_zone)
 ├── modules/dns-record       records in the zone
 ├── modules/dnssec           signing for the zone
 ├── modules/settings         zone settings, DNS settings, hold, normalization, managed transforms
 ├── modules/ssl              universal SSL, total TLS, certificate packs, custom certificates, hostname TLS
 ├── modules/custom-hostname  SSL for SaaS hostnames, fallback origin, regional hostnames
 └── modules/cache            tiered cache, cache reserve, cache variants, argo smart routing
```

## Resource map

| Terraform resource | Cloudflare object | Created by |
|--------------------|-------------------|------------|
| `cloudflare_zone` | Zone | root |
| `cloudflare_dns_record` | DNS record | `modules/dns-record` |
| `cloudflare_zone_dnssec` | DNSSEC configuration | `modules/dnssec` |
| `cloudflare_zone_setting` | One zone setting | `modules/settings` |
| `cloudflare_zone_dns_settings` | Zone level DNS settings | `modules/settings` |
| `cloudflare_zone_hold` | Zone hold | `modules/settings` |
| `cloudflare_url_normalization_settings` | URL normalization | `modules/settings` |
| `cloudflare_managed_transforms` | Managed header transforms | `modules/settings` |
| `cloudflare_universal_ssl_setting` | Universal SSL | `modules/ssl` |
| `cloudflare_total_tls` | Total TLS | `modules/ssl` |
| `cloudflare_certificate_pack` | Advanced certificate pack | `modules/ssl` |
| `cloudflare_custom_ssl` | Uploaded certificate | `modules/ssl` |
| `cloudflare_hostname_tls_setting` | Per hostname TLS override | `modules/ssl` |
| `cloudflare_custom_hostname` | SSL for SaaS hostname | `modules/custom-hostname` |
| `cloudflare_custom_hostname_fallback_origin` | Fallback origin | `modules/custom-hostname` |
| `cloudflare_regional_hostname` | Regional Services hostname | `modules/custom-hostname` |
| `cloudflare_tiered_cache` | Smart Tiered Cache | `modules/cache` |
| `cloudflare_argo_tiered_caching` | Argo Tiered Caching | `modules/cache` |
| `cloudflare_regional_tiered_cache` | Regional Tiered Cache | `modules/cache` |
| `cloudflare_zone_cache_reserve` | Cache Reserve | `modules/cache` |
| `cloudflare_zone_cache_variants` | Cache variants | `modules/cache` |
| `cloudflare_argo_smart_routing` | Argo Smart Routing | `modules/cache` |

## Scope

The module is **zone scoped**, with one account scoped input.

- `account_id` anchors zone creation. A zone must be created inside an account, so `account_id` is required
  when `create_zone` is `true`.
- `zone_id` anchors everything else. It is required when `create_zone` is `false`.

Both cases converge on `local.zone_id`, so the submodules never care which one applies:

```hcl
zone_id = var.create_zone ? one(cloudflare_zone.this[*].id) : var.zone_id
```

## Ordering and dependencies

There is no `depends_on` anywhere in this module. Every ordering constraint is expressed as a value reference,
which the provider turns into an implicit dependency:

- Every submodule receives `local.zone_id`, which is the created zone's ID when the module creates the zone.
  That reference alone orders the whole graph behind `cloudflare_zone.this`.
- The custom hostname fallback origin depends on a proxied DNS record existing in the zone. Both live in the
  same module call in `examples/ssl-for-saas`, and Cloudflare validates the origin asynchronously rather than at
  apply time, so no explicit ordering is needed.

Two orderings Terraform cannot express, because they happen outside Terraform:

- **DNSSEC.** `cloudflare_zone_dnssec` applies immediately, but the zone is not actually signed until the DS
  record from `output.dnssec_ds` is published at the registrar. That is a manual or registrar API step.
- **Certificate packs and custom hostnames.** Both apply immediately in a `pending_validation` state and are
  only issued once the validation records from `output.certificate_pack_validation_records` or
  `output.custom_hostname_ownership_verification` are published. A fresh apply will therefore report success
  while the certificate is still pending.

## Known provider quirks

**`cloudflare_zone_setting` is generic in v5.** Provider v4 had one large `cloudflare_zone_settings_override`
resource with a typed attribute per setting. v5 replaced it with one resource instance per setting, addressed by
`setting_id`, whose `value` is `dynamic`. That is why `var.zone_settings` here is untyped: a setting value can be
a string (`"full"`), a number (`14400`) or an object depending on which setting it is, and a typed map would
force them all to the same type. The module iterates the map's keys rather than the map itself so that `for_each`
stays a `map(string)` while the values keep their individual types.

**The setting ID list is not in the provider schema.** The v5 schema exposes no enum for `setting_id`, so the
module validates only the ID's shape (lower snake case) rather than membership of a fixed list. A wrong ID is
rejected by the API at apply time, not at plan time.

**`cloudflare_zone.account` is an object, not a string.** It is written `account = { id = var.account_id }`, not
`account_id = ...`. Several other v5 resources moved to nested objects in the same way.

**`cloudflare_zone` exports deprecated attributes.** `plan` and `permissions` are marked deprecated by the
provider, so any output that returns the whole zone object, including this module's `zone` output, produces a
`Deprecated value used` warning on every plan. The warning is harmless and cannot be suppressed without dropping
attributes from the output.

**Sensitive maps cannot drive `for_each`.** `var.custom_certificates` and `var.custom_hostnames` are marked
sensitive because they can carry a TLS private key, and Terraform refuses a sensitive value as a `for_each`
argument since the instance keys would leak into resource addresses. The keys themselves are plain identifiers,
so both submodules iterate `nonsensitive(toset(keys(...)))` and look each entry up by key.

**Smart Tiered Cache and Argo Tiered Caching are separate resources.** `cloudflare_tiered_cache` and
`cloudflare_argo_tiered_caching` are distinct API surfaces with identical schemas. Setting both to `on` for the
same zone is almost never what you want.

**`cloudflare_dns_record` splits simple and structured types.** `A`, `AAAA`, `CNAME`, `TXT`, `MX` and `NS` set
`content`. `SRV`, `CAA`, `LOC`, `SSHFP`, `TLSA`, `DS`, `NAPTR`, `CERT`, `SVCB` and `HTTPS` set the `data` object
instead, whose meaningful fields differ per type. `ttl` is required and `1` means automatic.
