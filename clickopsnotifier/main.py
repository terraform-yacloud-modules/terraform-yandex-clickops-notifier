import os
import logging

from messenger import Messenger
from typing import List

# Set up logging based on environment variable
logging_level = os.getenv("LOGGING_LEVEL", "INFO").upper()
logging.basicConfig(level=logging_level)
logger = logging.getLogger(__name__)


def mask_secret(secret: str, visible_start: int = 5,
                visible_end: int = 5) -> str:
  """
  Masks the middle part of a webhook URL for privacy.
  """
  if len(secret) <= visible_start + visible_end:
    return secret  # Do not mask if the URL is too short
  return f"{secret[:visible_start]}***{secret[-visible_end:]}"


def get_messengers() -> List[Messenger]:
  messengers = []

  logging.info("Configuring Slack messengers...")
  slack_cc = os.environ.get("SLACK_CC", "")
  slack_webhooks = os.environ.get("SLACK_WEBHOOKS", "")
  slack_webhooks = [url.strip() for url in slack_webhooks.split(",") if
                    url.strip()]
  slack_messengers = []
  for slack_webhook in slack_webhooks:
    masked_webhook = mask_secret(slack_webhook)
    try:
      slack_messengers.append(
        Messenger(
          messenger_type="slack",
          slack_webhook_url=slack_webhook,
          slack_cc=slack_cc
        )
      )
      logging.info(f"Slack messenger configured for webhook: {masked_webhook}")
    except Exception as e:
      logging.error(
        f"Failed to configure Slack messenger for webhook {masked_webhook}: {e}")

  slack_messengers_len = len(slack_messengers)
  if slack_messengers_len > 0:
    logging.info(f"{slack_messengers_len} Slack messengers configured.")
  else:
    logging.warning(
      "No Slack messengers were configured. Check your SLACK_WEBHOOKS environment variable.")
  messengers += slack_messengers

  logging.info("Configuring Telegram messengers...")
  telegram_cc = os.environ.get("TELEGRAM_CC", "")
  telegram_token = os.environ.get("TELEGRAM_TOKEN", "")
  telegram_chat_ids = os.environ.get("TELEGRAM_CHAT_IDS", "")
  telegram_chat_ids = [url.strip() for url in telegram_chat_ids.split(",") if
                       url.strip()]
  telegram_messengers = []
  for telegram_chat_id in telegram_chat_ids:
    try:
      telegram_messengers.append(
        Messenger(
          messenger_type="telegram",
          telegram_token=telegram_token,
          telegram_chat_id=telegram_chat_id,
          telegram_cc=telegram_cc
        )
      )
      logging.info(
        f"Telegram messenger configured for chat id: {telegram_chat_id}")
    except Exception as e:
      logging.error(
        f"Failed to configure Telegram messenger for chat id {telegram_chat_id}: {e}")

  telegram_messengers_len = len(telegram_messengers)
  if telegram_messengers_len > 0:
    logging.info(f"{telegram_messengers_len} Telegram messengers configured.")
  else:
    logging.warning(
      "No Telegram messengers were configured. Check your TELEGRAM_TOKEN or TELEGRAM_CHAT_IDS environment variables.")
  messengers += telegram_messengers

  return messengers


def parse_event(event):
  data = {}
  data['timestamp'] = event['event_time']
  data['subject_name'] = event['authentication']['subject_name']
  data['cloud_name'] = event['resource_metadata']['path'][1]['resource_name']
  data['folder_name'] = event['resource_metadata']['path'][2]['resource_name']
  data['subject_id'] = event['authentication']['subject_id']
  data['subject_type'] = event['authentication']['subject_type']
  data['folder_id'] = event['resource_metadata']['path'][1]['resource_id']
  data['details'] = event['details']

  data['event_source'] = event['event_source']
  data['event_type'] = event['event_type']

  return data


def handler(events, context):
  logging.debug(f"Process events: {events}")
  for event_l1 in events["messages"]:
    for event_l2 in event_l1["details"]["messages"]:
      event = event_l2["json_payload"]

      logging.debug(f"Current event: {event}")
      # Parse event details
      parsed_event = parse_event(event)

      # Get exclusions from environment variables (comma-separated lists)
      excluded_subject_names = os.getenv("EXCLUDED_SUBJECT_NAMES", "").split(
        ",")
      excluded_subject_types = os.getenv("EXCLUDED_SUBJECT_TYPES", "").split(
        ",")
      excluded_sources = os.getenv("EXCLUDED_EVENT_SOURCES", "").split(",")
      excluded_types = os.getenv("EXCLUDED_EVENT_TYPES", "").split(",")

      # Apply exclusions
      if parsed_event["subject_name"] in excluded_subject_names:
        logging.debug(f"Event is excluded based on EXCLUDED_SUBJECT_NAMES")
        return
      if parsed_event["subject_type"] in excluded_subject_types:
        logging.debug(f"Event is excluded based on EXCLUDED_SUBJECT_TYPES")
        return
      if parsed_event["event_source"] in excluded_sources:
        logging.debug(f"Event is excluded based on EXCLUDED_EVENT_SOURCES")
        return
      if parsed_event["event_type"] in excluded_types:
        logging.debug(f"Event is excluded based on EXCLUDED_EVENT_TYPES")
        return

      messengers = get_messengers()
      for messenger in messengers:
        result_messenger = messenger.send(
          data=parsed_event
        )
        if not result_messenger:
          logging.error(f'Message NOT sent to webhook "{messenger}".')
