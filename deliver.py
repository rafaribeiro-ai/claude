"""
Emails a rendered HTML premarket report via Resend.

Usage:
    python deliver.py reports/premarket_2026-07-11.html

Reads RESEND_API_KEY and EMAIL_TO from a local .env (KEY=VALUE, one per
line). Real environment variables always win over the .env file. If
either key is missing, this exits cleanly with a skip message instead
of sending anything or crashing.
"""

import os
import re
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import requests

ET = ZoneInfo("America/New_York")
SCRIPT_DIR = Path(__file__).resolve().parent
ENV_FILE = SCRIPT_DIR / ".env"
RESEND_URL = "https://api.resend.com/emails"
DEFAULT_FROM = "AI Premarket Analyst <onboarding@resend.dev>"


def load_env_file(path):
    """Tiny KEY=VALUE parser, no extra dependency. Only fills in values
    that aren't already set, so real environment variables always win."""
    if not path.exists():
        return
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def extract_date(html_path):
    match = re.search(r"(\d{4}-\d{2}-\d{2})", html_path.name)
    if match:
        return match.group(1)
    return datetime.now(ET).strftime("%Y-%m-%d")


def main():
    if len(sys.argv) < 2:
        print("Usage: python deliver.py reports/premarket_<date>.html")
        sys.exit(1)

    html_path = Path(sys.argv[1])
    if not html_path.exists():
        print(f"error: {html_path} not found")
        sys.exit(1)

    load_env_file(ENV_FILE)

    api_key = os.environ.get("RESEND_API_KEY", "").strip()
    email_to = os.environ.get("EMAIL_TO", "").strip()
    email_from = os.environ.get("EMAIL_FROM", "").strip() or DEFAULT_FROM

    if not api_key or not email_to:
        print("email skipped, set RESEND_API_KEY + EMAIL_TO")
        sys.exit(0)

    html_content = html_path.read_text()
    date_str = extract_date(html_path)
    subject = f"AI Premarket Report · {date_str}"
    to_list = [addr.strip() for addr in email_to.split(",") if addr.strip()]

    print(f"Sending report to {', '.join(to_list)} via Resend...")

    try:
        response = requests.post(
            RESEND_URL,
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            },
            json={
                "from": email_from,
                "to": to_list,
                "subject": subject,
                "html": html_content,
            },
            timeout=30,
        )
    except requests.RequestException as exc:
        print(f"email failed, network error: {exc}")
        sys.exit(1)

    if response.ok:
        resend_id = response.json().get("id", "unknown")
        print(f"Sent. Resend id: {resend_id}")
    else:
        print(f"email failed, Resend returned {response.status_code}: {response.text}")
        sys.exit(1)


if __name__ == "__main__":
    main()
