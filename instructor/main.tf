locals {
  participants_path = "${path.module}/participants.yaml"

  # participants.yaml is a plain YAML list of names:
  #   - grace.hopper
  #   - ada.lovelace
  participants = toset(yamldecode(file(local.participants_path)))
}

module "participants" {
  source = "./modules/participants"

  participants       = local.participants
  account_identifier = "${var.organization_name}-${var.account_name}"

  prefix                   = var.prefix
  warehouse_size           = var.warehouse_size
  participant_email_domain = var.participant_email_domain
}
