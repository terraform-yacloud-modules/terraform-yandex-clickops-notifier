################################################################################
# yandex cloud
################################################################################
variable "folder_id" {
  description = "Folder ID"
  type        = string
  default     = null
}

################################################################################
# Naming
################################################################################
variable "blank_name" {
  description = "Blank name which will be used for all resources"
  type        = string
  default     = "clickops"
}

variable "labels" {
  description = "A set of labels"
  type        = map(string)
  default     = {}
}

################################################################################
# Others
################################################################################
variable "audit_trail_management_events_filters" {
  description = "Structure describing filtering process for management events"
  type = list(object({
    resource_id : optional(string)
    resource_type : string
  }))
  default = [
    {
      resource_type = "resource-manager.folder"
    }
  ]
}

variable "audit_trail_data_events_filter" {
  description = "Structure describing filtering process for the service-specific data events"
  type = list(object({
    service : string
    resource_id : optional(string)
    resource_type : string
    included_events : optional(list(string))
    excluded_events : optional(list(string))
  }))
  default = [
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
}


variable "function_trigger_batch_cutoff" {
  description = "Batch Duration in seconds for Yandex Cloud Functions Trigger"
  type        = number
  default     = 10
}

variable "function_trigger_batch_size" {
  description = "Batch Size for Yandex Cloud Functions Trigger"
  type        = number
  default     = 10
}

variable "function_log_level" {
  description = "The default logging level for clickopsnotifier function"
  type        = string
  default     = "INFO"
}

variable "telegram_token" {
  description = "List of subject names that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = "-"
  sensitive   = true
}

variable "telegram_chat_ids" {
  description = <<EOT
  List of Telegram chat IDs that will be used for notifications.
Ensure the provided `telegram_token` has access to the specified chat IDs.
EOT
  type        = string
  default     = "-"
}

variable "telegram_cc" {
  description = <<EOT
  List of Telegram usernames to be added as CC to the notification message.
  Provide this as a string separated by comma representing Telegram usernames (e.g., `user1, user2`).
EOT
  type        = string
  default     = "-"
}

variable "slack_webhook_url" {
  description = "List of subject names that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = "-"
  sensitive   = true
}

variable "slack_cc" {
  description = <<EOT
  List of Slack usernames to be added as CC to the notification message.
  Provide this as a string separated by comma representing slack username ids (e.g., `<@U0422RZRC77>", <@U042211RC00>"`).
EOT
  type        = string
  default     = "-"
}

variable "excluded_subject_names" {
  description = "List of subject names that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = null
}

variable "excluded_subject_types" {
  description = "List of subject types that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = null
}

variable "excluded_event_sources" {
  description = "List of event sources that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = null
}

variable "excluded_event_types" {
  description = "List of event types that won't raise notifications. Format: a comma-separated string."
  type        = string
  default     = null
}
