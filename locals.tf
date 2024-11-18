locals {
  folder_id = coalesce(var.folder_id, data.yandex_client_config.client.folder_id)

  function_secrets_slack = var.slack_webhook_url == null || var.slack_webhook_url == "" ? [] : [{
    id                   = module.lockbox.id
    version_id           = module.lockbox.version_id
    key                  = "slack_webhook_url"
    environment_variable = "SLACK_WEBHOOKS"
  }]
  function_secrets_telegram = var.telegram_token == null || var.telegram_token == "" ? [] : [{
    id                   = module.lockbox.id
    version_id           = module.lockbox.version_id
    key                  = "telegram_token"
    environment_variable = "TELEGRAM_TOKEN"
  }]
  function_secrets = concat(local.function_secrets_slack, local.function_secrets_telegram)

  lockbox_secrets_slack    = var.slack_webhook_url == null || var.slack_webhook_url == "" ? {} : { "slack_webhook_url" : var.slack_webhook_url }
  lockbox_secrets_telegram = var.telegram_token == null || var.telegram_token == "" ? {} : { "telegram_token" : var.telegram_token }
  lockbox_secrets          = merge(local.lockbox_secrets_slack, local.lockbox_secrets_telegram)
}
