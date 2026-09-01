# Managing DNS on a zone that already exists.
#
# Two things here are not obvious:
#
# 1. create_zone = false attaches the module to a zone somebody else created,
#    so it only manages records and settings.
# 2. Structured record types (SRV, CAA, LOC, SSHFP, TLSA, DS, NAPTR, CERT,
#    SVCB, HTTPS) do not use content. They use the data object, whose fields
#    differ per record type. Setting content on those types is rejected by the
#    Cloudflare API.

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}

module "this" {
  source = "../../"

  enabled     = true
  create_zone = false
  zone_id     = var.zone_id

  # Leave every zone setting alone: this configuration owns DNS only.
  ssl_mode                 = null
  min_tls_version          = null
  always_use_https         = null
  tls_1_3                  = null
  automatic_https_rewrites = null

  dns_records = {
    # Simple types use content.
    apex = {
      name    = var.zone_name
      type    = "A"
      content = "192.0.2.1"
      proxied = true
    }

    dkim = {
      name    = "selector1._domainkey.${var.zone_name}"
      type    = "TXT"
      content = "v=DKIM1; k=rsa; p=MIIBIjANBg"
      ttl     = 3600
    }

    dmarc = {
      name    = "_dmarc.${var.zone_name}"
      type    = "TXT"
      content = "v=DMARC1; p=reject; rua=mailto:dmarc@${var.zone_name}"
      ttl     = 3600
    }

    # MX and URI records must carry a priority.
    mail_primary = {
      name     = var.zone_name
      type     = "MX"
      content  = "mx1.example.net"
      priority = 10
      ttl      = 3600
    }

    mail_secondary = {
      name     = var.zone_name
      type     = "MX"
      content  = "mx2.example.net"
      priority = 20
      ttl      = 3600
    }

    # Structured types use data.
    caa_letsencrypt = {
      name = var.zone_name
      type = "CAA"
      ttl  = 3600
      data = {
        flags = 0
        tag   = "issue"
        value = "letsencrypt.org"
      }
    }

    caa_iodef = {
      name = var.zone_name
      type = "CAA"
      ttl  = 3600
      data = {
        flags = 0
        tag   = "iodef"
        value = "mailto:security@${var.zone_name}"
      }
    }

    sip_tcp = {
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

    ssh_fingerprint = {
      name = "bastion.${var.zone_name}"
      type = "SSHFP"
      ttl  = 3600
      data = {
        algorithm   = 4
        type        = 2
        fingerprint = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
      }
    }
  }

  # DNSSEC on a zone the module did not create works the same way.
  dnssec_enabled = true
}
