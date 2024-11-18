import json
import requests
import logging

class Messenger:
  def __init__(
    self,
    messenger_type,
    slack_webhook_url="",
    slack_cc="",
    telegram_token="",
    telegram_chat_id="",
    telegram_cc=""
  ) -> None:

    self.messenger_type = messenger_type
    if messenger_type == "slack":
      self.send = self.__send_slack_message
    elif messenger_type == "telegram":
      self.send = self.__send_telegram_message
    else:
      raise ValueError("Invalid webhook_type, must be ['slack', 'telegram']")

    self.slack_webhook_url = slack_webhook_url
    self.slack_cc = slack_cc.replace(",", "")

    self.telegram_token = telegram_token
    self.telegram_chat_id = telegram_chat_id
    self.telegram_cc = telegram_cc

    if telegram_chat_id != "" and self.telegram_token == "":
      raise ValueError(
        "Telegram token can not be empty if telegram_chat_id is configured")

  def __send_telegram_message(self, data) -> bool:
    if data["subject_type"] == "YANDEX_PASSPORT_USER_ACCOUNT":
      subject_emoji = "👨"
    elif data["subject_type"] == "SERVICE_ACCOUNT":
      subject_emoji = "⚙️"
    elif data["subject_type"] == "FEDERATED_USER_ACCOUNT":
      subject_emoji = "🌐"
    else:
      subject_emoji = "❓"

    # Note: Telegram support only the following tags: b, strong , i, em, u, ins, s, strike, del, a, code, pre
    message = f"""
<ins><strong>🔔 Yandex ClickOps Alert</strong></ins>

<b>🕘 Timestamp:</b> {data["timestamp"]}
<b>{subject_emoji}Subject Name:</b> {data["subject_name"]}
<b>☁️Cloud Name:</b> {data["cloud_name"]}
<b>🗂Folder Name:</b> {data["folder_name"]}
<b>📜Event type:</b> {data["event_type"]}

<b>Event Details:</b>
<pre>{json.dumps(data["details"], indent=2)}</pre>
        """

    if self.telegram_cc != "":
      telegram_cc_formated = ""
      for cc in self.telegram_cc.split(","):
        telegram_cc_formated += f"@{cc}"
      message += f"""\ncc {telegram_cc_formated}"""

    # Telegram bot API URL
    telegram_api_url = f"https://api.telegram.org/bot{self.telegram_token}/sendMessage"

    # Payload for Telegram API
    payload = {
      "chat_id": self.telegram_chat_id,
      "text": message,
      "parse_mode": "HTML",  # Use HTML to format the message
    }

    # Send the message
    response = requests.post(telegram_api_url, json=payload)

    if response.status_code != 200:
      logging.info(f"Telegram payload:\n\n{json.dumps(payload)}")
      logging.error(f"Telegram response content:\n\n{response.content}")
      return False

    return True

  def __send_slack_message(self, data) -> bool:
    if data["subject_type"] == "YANDEX_PASSPORT_USER_ACCOUNT":
      subject_emoji = ":man:"
    elif data["subject_type"] == "SERVICE_ACCOUNT":
      subject_emoji = "️:gear:"
    elif data["subject_type"] == "FEDERATED_USER_ACCOUNT":
      subject_emoji = ":globe_with_meridians:"
    else:
      subject_emoji = ":question:"

    message = {
      "blocks": [
        {"type": "divider"},
        {
          "type": "header",
          "text": {
            "type": "plain_text",
            "text": ":bell: Yandex ClickOps Alert",
            "emoji": True,
          },
        },
        {
          "type": "section",
          "fields": [
            {
              "type": "mrkdwn",
              "text": f"🕘 *Timestamp*\n{data['timestamp']}",
            },
            {
              "type": "mrkdwn",
              "text": f"{subject_emoji} *Subject*\n{data['subject_name']}",
            },
          ],
        },
        {
          "type": "section",
          "fields": [
            {
              "type": "mrkdwn",
              "text": f"☁️ *Cloud Name*\n{data['cloud_name']}",
            },
            {
              "type": "mrkdwn",
              "text": f"🗂 *Folder Name*\n{data['folder_name']}"
            },
          ],
        },
        {
          "type": "section",
          "text":
            {
              "type": "mrkdwn",
              "text": f":scroll: *Event Type*: {data['event_type']}",
            }
        },
        {
          "type": "section",
          "text":
            {
              "type": "mrkdwn",
              "text": f"*Event Details*\n```\n{json.dumps(data['details'], indent=2)}```",
            }

        }
      ]
    }

    if self.slack_cc != "":
      message["blocks"].append(
        {"type": "context", "elements": [{"type": "mrkdwn", "text": f"cc {self.slack_cc}"}]}
      )

    message["blocks"].append(
      {"type": "divider"}
    )

    # Slack Webhook URL (replace with your actual webhook URL)
    slack_webhook_url = self.slack_webhook_url

    # Send the message
    response = requests.post(slack_webhook_url, json=message)

    if response.status_code != 200:
      logging.info(f"Slack payload:\n\n{json.dumps(message)}")
      logging.error(f"Slack response content:\n\n{response.content}")
      return False

    return True
