module "iam_account" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-iam.git//modules/iam-account?ref=v1.0.0"

  name        = var.blank_name
  description = ""
  folder_id   = local.folder_id

  folder_roles = [
    "admin",
    "logging.writer",
  ]
  cloud_roles              = []
  enable_static_access_key = true
  enable_api_key           = false
  enable_account_key       = false
}

module "kms_key" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-kms.git?ref=v1.0.0"

  name        = var.blank_name
  description = ""
  folder_id   = local.folder_id
  labels      = var.labels

  default_algorithm = "AES_256"
  rotation_period   = "4380h"
}

module "lockbox" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-lockbox.git?ref=rc/1.16.0"

  name        = var.blank_name
  description = ""
  folder_id   = local.folder_id
  labels      = var.labels

  entries = local.lockbox_secrets

  deletion_protection = false
}

module "audit_trails_logging_group" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-logging-group.git?ref=v1.0.0"

  name        = format("%s-audit-trails", var.blank_name)
  description = "Log group for Yandex Audit"
  folder_id   = local.folder_id
  labels      = var.labels

  retention_period = "3600s"
}

module "audit_trails" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-audit-trails.git?ref=v2.0.0"

  name        = var.blank_name
  description = "Log group for Yandex Audit"
  folder_id   = local.folder_id
  labels      = var.labels

  service_account_id               = module.iam_account.id
  logging_destination_log_group_id = module.audit_trails_logging_group.id

  management_events_filters = var.audit_trail_management_events_filters
  data_events_filter        = var.audit_trail_data_events_filter

  depends_on = [
    module.iam_account,
    module.audit_trails_logging_group
  ]
}

module "function_logging_group" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-logging-group.git?ref=v1.0.0"

  name        = format("%s-function", var.blank_name)
  description = "Log group for Yandex Audit"
  folder_id   = local.folder_id
  labels      = var.labels

  retention_period = "3600s"
}

data "archive_file" "clickopsnotifier_zip" {
  type        = "zip"
  source_dir  = "${path.module}/clickopsnotifier"
  output_path = "${path.module}/clickopsnotifier.zip"
}

module "function" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-function.git?ref=rc/1.1.0"

  function_name        = var.blank_name
  public_function      = false
  function_description = "A clickops notifier function by terraform-yacloud-modules that sends notifications to Slack or Telegram on audit events"
  user_hash            = data.archive_file.clickopsnotifier_zip.output_md5
  runtime              = "python312"
  entrypoint           = "main.handler"
  memory               = "128"
  execution_timeout    = 60
  service_account_id   = module.iam_account.id
  tags                 = []
  zip_filename         = data.archive_file.clickopsnotifier_zip.output_path

  log_options = {
    log_group_id = module.function_logging_group.id
    min_level    = null
  }

  secrets = local.function_secrets

  env_vars = {
    EXCLUDED_SUBJECT_NAMES = var.excluded_subject_names
    EXCLUDED_SUBJECT_TYPES = var.excluded_subject_types
    EXCLUDED_EVENT_SOURCES = var.excluded_event_sources
    EXCLUDED_EVENT_TYPES   = var.excluded_event_types
    LOGGING_LEVEL          = var.function_log_level
    TELEGRAM_CHAT_IDS      = var.telegram_chat_ids
    TELEGRAM_CC            = var.telegram_cc
    SLACK_CC               = var.slack_cc
  }

  depends_on = [
    module.iam_account
  ]
}

resource "yandex_function_trigger" "audit_trigger" {
  name        = var.blank_name
  description = "Trigger to invoke clickopsnotifier function"

  logging {
    batch_cutoff = var.function_trigger_batch_cutoff
    batch_size   = var.function_trigger_batch_size
    group_id     = module.audit_trails_logging_group.id
  }

  function {
    id                 = module.function.id
    service_account_id = module.iam_account.id
  }

  depends_on = [
    module.function
  ]
}
