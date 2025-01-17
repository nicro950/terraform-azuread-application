data "azuread_service_principal" "main" {
  count        = length(local.api_names)
  display_name = local.api_names[count.index]
}

resource "azuread_application" "main" {
  name                       = var.name
  homepage                   = coalesce(var.homepage, local.homepage)
  identifier_uris            = local.identifier_uris
  reply_urls                 = var.reply_urls
  available_to_other_tenants = var.available_to_other_tenants
  public_client              = local.public_client
  oauth2_allow_implicit_flow = var.oauth2_allow_implicit_flow
  group_membership_claims    = var.group_membership_claims
  type                       = local.type

  dynamic "required_resource_access" {
    for_each = local.required_resource_access

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  dynamic "app_role" {
    for_each = local.app_roles

    content {
      allowed_member_types = app_role.value.member_types
      display_name         = app_role.value.name
      description          = app_role.value.description
      value                = coalesce(app_role.value.value, app_role.value.name)
      is_enabled           = app_role.value.enabled
    }
  }
}
