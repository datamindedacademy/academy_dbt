module "participant" {
  for_each = local.participants
  source   = "./participant"

  name         = each.key
  identifier   = each.value
  email_domain = var.participant_email_domain
  shared       = local.shared
}

