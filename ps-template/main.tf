# ---------------------------------------------------------------------------------------------------------------------
# Locals to create the policies
# ---------------------------------------------------------------------------------------------------------------------

locals {
  file = "${var.name}.json"
  policy_sentry_template = {
    "mode" : "crud",
    "read" : var.read_access_level,
    "write" : var.write_access_level,
    "list" : var.list_access_level,
    "tagging" : var.tagging_access_level
    "permissions-management" : var.permissions_management_access_level,
    "wildcard-only" : {
      "single-actions" : var.wildcard_only_single_actions,
      "service-read" : var.wildcard_only_read_service,
      "service-write" : var.wildcard_only_write_service,
      "service-list" : var.wildcard_only_list_service,
      "service-tagging" : var.wildcard_only_tagging_service,
      "service-permissions-management" : var.wildcard_only_permissions_management_service,
    }
  }
  rendered_template = jsonencode(local.policy_sentry_template)
  decoded_template  = jsondecode(jsonencode(local.policy_sentry_template))
  options           = var.minimize ? "--output-base64 --minimize 0" : "--output-base64"
}

resource "local_file" "template" {
  filename =  "template.json"
  content = local.rendered_template
}

# external data sources only support a simple json response of keyed strings
# { "key1": "string1", "key2": "string2", ..., "keyN": "stringN" }
#
# i modified policy_sentry to work around this limitation
# the --output-base64 option will output the policy as follows
# { "base64": policy-as-base64-encoded-string }

data "external" "policy" {
  program = [ "policy_sentry", "write-policy", local.options, "--input-file", local_file.template.filename ]
}

