module "clickops_notifications" {
  source = "../../"

  blank_name = "terraform-yandex-clickops-notifier-ex1"

  function_log_level            = "DEBUG"
  function_trigger_batch_cutoff = 10
  function_trigger_batch_size   = 1

  # Example: notifications about actions made by user1@example.com or user2@example.com won't be sent
  excluded_subject_names = "user1@example.com,user2@example.com,"

  # Example: notifications about SERVICE_ACCOUNT or FEDERATED_USER_ACCOUNT won't be send. Only YANDEX_PASSPORT_USER_ACCOUNT will delivered
  excluded_subject_types = "SERVICE_ACCOUNT,FEDERATED_USER_ACCOUNT"

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

  audit_trail_data_events_filter = [
    {
      service       = "apploadbalancer"
      resource_type = "resource-manager.folder"
      included_events = [
        "yandex.cloud.audit.apploadbalancer.LoadBalancerHTTPAccessLog",
        "yandex.cloud.audit.apploadbalancer.LoadBalancerTCPAccessLog"
      ]
    },
    {
      service       = "mdb.mysql"
      resource_type = "resource-manager.folder"
      excluded_events = [
        "yandex.cloud.audit.mdb.mysql.RevokeUserPermission",
        "yandex.cloud.audit.mdb.mysql.CreateDatabase",
        "yandex.cloud.audit.mdb.mysql.DeleteDatabase",
        "yandex.cloud.audit.mdb.mysql.DatabaseUserLogout",
        "yandex.cloud.audit.mdb.mysql.DatabaseUserLogin",
        "yandex.cloud.audit.mdb.mysql.CreateUser",
        "yandex.cloud.audit.mdb.mysql.GrantUserPermission",
        "yandex.cloud.audit.mdb.mysql.DeleteUser",
        "yandex.cloud.audit.mdb.mysql.UpdateUser",
        "yandex.cloud.audit.mdb.mysql.DatabaseUserSQLRequest"
      ]
    },
    {
      service         = "compute"
      resource_type   = "resource-manager.folder"
      included_events = ["yandex.cloud.audit.compute.serialssh.ConnectSerialPort"]
    },
    {
      service       = "mdb.mongodb"
      resource_type = "resource-manager.folder"
      excluded_events = [
        "yandex.cloud.audit.mdb.mongodb.DeleteUser",
        "yandex.cloud.audit.mdb.mongodb.GrantUserPermission",
        "yandex.cloud.audit.mdb.mongodb.UpdateUser",
        "yandex.cloud.audit.mdb.mongodb.CreateUser",
        "yandex.cloud.audit.mdb.mongodb.DeleteDatabase",
        "yandex.cloud.audit.mdb.mongodb.RevokeUserPermission",
        "yandex.cloud.audit.mdb.mongodb.CreateDatabase"
      ]
    },
    {
      service         = "lockbox"
      resource_type   = "resource-manager.folder"
      included_events = ["yandex.cloud.audit.lockbox.GetPayload"]
    },
    {
      service       = "kms"
      resource_type = "resource-manager.folder"
      excluded_events = [
        "yandex.cloud.audit.kms.Encrypt",
        "yandex.cloud.audit.kms.asymmetricsignature.AsymmetricSign",
        "yandex.cloud.audit.kms.asymmetricsignature.AsymmetricGetPublicKey",
        "yandex.cloud.audit.kms.asymmetricencryption.AsymmetricDecrypt",
        "yandex.cloud.audit.kms.asymmetricencryption.AsymmetricGetPublicKey",
        "yandex.cloud.audit.kms.Decrypt",
        "yandex.cloud.audit.kms.GenerateDataKey",
        "yandex.cloud.audit.kms.asymmetricsignature.AsymmetricSignHash",
        "yandex.cloud.audit.kms.ReEncrypt"
      ]


    },
    {
      service       = "iam"
      resource_type = "resource-manager.folder"
      excluded_events = [
        "yandex.cloud.audit.iam.CreateIamToken",
        "yandex.cloud.audit.iam.oslogin.GenerateSshCertificate",
        "yandex.cloud.audit.iam.oslogin.CheckSshPolicy",
        "yandex.cloud.audit.iam.RevokeIamToken"
      ]
    },
    {
      service         = "dns"
      resource_type   = "resource-manager.folder"
      included_events = ["yandex.cloud.audit.dns.ProcessDnsQuery"]
    },
    {
      service       = "smartwebsecurity"
      resource_type = "resource-manager.folder"
      included_events = [
        "yandex.cloud.audit.smartwebsecurity.WafMatchedExclusionRule",
        "yandex.cloud.audit.smartwebsecurity.ArlMatchedRequest",
        "yandex.cloud.audit.smartwebsecurity.WafMatchedRule"
      ]
    },
    {
      service       = "mdb.postgresql"
      resource_type = "resource-manager.folder"
      included_events = [
        "yandex.cloud.audit.mdb.postgresql.CreateDatabase",
        "yandex.cloud.audit.mdb.postgresql.DatabaseUserLogout",
        "yandex.cloud.audit.mdb.postgresql.UpdateDatabase",
        "yandex.cloud.audit.mdb.postgresql.DatabaseUserSQLRequest",
        "yandex.cloud.audit.mdb.postgresql.UpdateUser",
        "yandex.cloud.audit.mdb.postgresql.DeleteUser",
        "yandex.cloud.audit.mdb.postgresql.DatabaseUserLogin",
        "yandex.cloud.audit.mdb.postgresql.CreateUser",
        "yandex.cloud.audit.mdb.postgresql.DeleteDatabase",
        "yandex.cloud.audit.mdb.postgresql.RevokeUserPermission",
        "yandex.cloud.audit.mdb.postgresql.GrantUserPermission"
      ]
    },
    {
      service       = "websql"
      resource_type = "resource-manager.folder"
      included_events = [
        "yandex.cloud.audit.websql.GetDatabaseStructure",
        "yandex.cloud.audit.websql.Execute",
        "yandex.cloud.audit.websql.GenerateSql"
      ]
    },
    {
      service       = "storage"
      resource_type = "resource-manager.folder"
      included_events = [
        "yandex.cloud.audit.storage.ObjectCreate",
        "yandex.cloud.audit.storage.ObjectTagsUpdate",
        "yandex.cloud.audit.storage.ObjectUpdate",
        "yandex.cloud.audit.storage.ObjectDelete",
        "yandex.cloud.audit.storage.PresignURLCreate",
        "yandex.cloud.audit.storage.ObjectTagsDelete",
        "yandex.cloud.audit.storage.ObjectAclUpdate"
      ]
    }
  ]
}


