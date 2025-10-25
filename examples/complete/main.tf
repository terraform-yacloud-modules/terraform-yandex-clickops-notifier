module "clickops_notifications" {
  source = "../../"

  blank_name = "terraform-yandex-clickops-notifier-ex1"
  labels     = {}

  folder_id = null

  function_log_level            = "DEBUG"
  function_trigger_batch_cutoff = 10
  function_trigger_batch_size   = 1

  audit_trail_management_events_filters = [
    {
      resource_type = "resource-manager.folder"
    }
  ]

  audit_trail_data_events_filter = [
    {
      service       = "apploadbalancer"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "mdb.mysql"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "compute"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "mdb.mongodb"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "lockbox"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "kms"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "iam"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "dns"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "smartwebsecurity"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "mdb.postgresql"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "websql"
      resource_type = "resource-manager.folder"
    },
    {
      service       = "storage"
      resource_type = "resource-manager.folder"
    }
  ]

  # Example: notifications about actions made by user1@example.com or user2@example.com won't be sent
  excluded_subject_names = "user1@example.com,user2@example.com,"

  # Example: notifications about SERVICE_ACCOUNT or FEDERATED_USER_ACCOUNT won't be send. Only YANDEX_PASSPORT_USER_ACCOUNT will delivered
  excluded_subject_types = "SERVICE_ACCOUNT,FEDERATED_USER_ACCOUNT"

  # Example: we do not want to get notifications about kms events
  excluded_event_sources = "kms"

  # Example: we do not want to get notification about "reading" lockbox secrets
  excluded_event_types = "yandex.cloud.audit.lockbox.GetPayload"

  telegram_token = "742XXXXXqs"
  # A list of telegram chat ids. To get the id do the following:
  #   1. Add bot you the Telegram chat
  #   2. Open in browser https://api.telegram.org/bot742XXXXXqs/getUpdates
  #   3. Send something to the chart
  #   4. Get the chat id in your browser
  telegram_chat_ids = "-1111866"
  # A list of CC that will be added to the message. "user1" is a Telegram nickname
  telegram_cc = "user1"

  slack_webhook_url = "https://hooks.slack.com/services/XXX/YYY/ZZZ"
  # A list of CC that will be added to the message. "U000RARC00" is a Slack user ID.
  slack_cc = "<@U000RARC00>"
}
