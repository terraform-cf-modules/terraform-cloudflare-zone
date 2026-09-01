# Applies against a real Cloudflare test account.
# Runs on a schedule and on manual dispatch only, never on pull requests,
# because fork pull requests cannot read organisation secrets.
#
# This suite deliberately attaches to an existing test zone rather than
# registering a new domain, so it needs no registrar side setup.

variables {
  account_id = null # supplied by TF_VAR_account_id
  zone_id    = null # supplied by TF_VAR_zone_id
}

run "apply_and_destroy" {
  command = apply

  variables {
    create_zone = false
    zone_name   = null

    dns_records = {
      terraform_test = {
        name    = "terraform-module-test"
        type    = "TXT"
        content = "terraform-cf-modules zone module integration test"
        ttl     = 300
      }
    }

    # Leave the live zone's own settings alone.
    ssl_mode                 = null
    min_tls_version          = null
    always_use_https         = null
    tls_1_3                  = null
    automatic_https_rewrites = null
  }

  assert {
    condition     = output.enabled == true
    error_message = "Module did not report enabled after apply."
  }

  assert {
    condition     = output.zone_id == var.zone_id
    error_message = "Module did not attach to the zone it was given."
  }

  assert {
    condition     = length(output.dns_record_ids) == 1
    error_message = "Module did not create the test DNS record."
  }
}
