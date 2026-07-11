"""
Renders a Markdown premarket report into a clean, readable HTML page.

Usage:
    python render_report.py REPORT.md [YYYY-MM-DD]

If the date is omitted, today's date in US Eastern time is used. The
date only controls the page header and the output filename, it does not
touch the Markdown content itself.
"""

import re
import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import markdown

ET = ZoneInfo("America/New_York")
SCRIPT_DIR = Path(__file__).resolve().parent

CSS = """
:root {
    color-scheme: light;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 40px 20px 80px;
    background: #f2f1ee;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
        Helvetica, Arial, sans-serif;
    font-size: 16px;
    line-height: 1.65;
    color: #24292e;
}

.page {
    max-width: 900px;
    margin: 0 auto;
    background: #ffffff;
    border: 1px solid #e5e3de;
    border-radius: 10px;
    padding: 40px 48px;
}

header.report-header {
    border-bottom: 1px solid #e5e3de;
    margin-bottom: 32px;
    padding-bottom: 20px;
}

header.report-header h1 {
    margin: 0 0 6px;
    font-size: 1.7em;
    font-weight: 700;
    letter-spacing: -0.01em;
}

header.report-header .report-date {
    color: #6b7280;
    font-size: 0.95em;
}

h1, h2, h3, h4 {
    font-weight: 700;
    line-height: 1.3;
}

h2 {
    margin-top: 2.2em;
    padding-bottom: 0.3em;
    border-bottom: 1px solid #e5e3de;
    font-size: 1.35em;
}

h3 {
    margin-top: 1.6em;
    font-size: 1.05em;
    color: #4b5563;
}

p {
    margin: 0.9em 0;
}

a {
    color: #1d4ed8;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

blockquote {
    margin: 1.2em 0;
    padding: 0.8em 1.2em;
    border-left: 3px solid #c9c6bd;
    background: #f8f7f4;
    color: #4b5563;
    font-size: 0.95em;
}

blockquote p {
    margin: 0.3em 0;
}

ul, ol {
    padding-left: 1.4em;
}

li {
    margin: 0.3em 0;
}

code {
    background: #f3f2ee;
    border-radius: 4px;
    padding: 0.15em 0.4em;
    font-size: 0.9em;
    font-family: "SFMono-Regular", Consolas, Menlo, monospace;
}

pre {
    background: #f3f2ee;
    border-radius: 6px;
    padding: 14px 16px;
    overflow-x: auto;
}

pre code {
    background: none;
    padding: 0;
}

hr {
    border: none;
    border-top: 1px solid #e5e3de;
    margin: 2.4em 0;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 1.2em 0;
    font-size: 0.94em;
}

th, td {
    border: 1px solid #e5e3de;
    padding: 9px 12px;
    text-align: left;
    vertical-align: top;
}

thead th {
    background: #f3f2ee;
    font-weight: 700;
    color: #1f2937;
}

tbody tr:nth-child(even) {
    background: #fafaf8;
}

footer.report-footer {
    margin-top: 3em;
    padding-top: 20px;
    border-top: 1px solid #e5e3de;
    color: #9ca3af;
    font-size: 0.85em;
    text-align: center;
}
"""

HTML_TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>{css}</style>
</head>
<body>
<div class="page">
<header class="report-header">
<h1>{title}</h1>
<div class="report-date">{date}</div>
</header>
{body}
<footer class="report-footer">
Generated {generated} &middot; Built by Claude &middot; Educational only, not financial advice
</footer>
</div>
</body>
</html>
"""


def extract_title(md_text):
    for line in md_text.splitlines():
        stripped = line.strip()
        if stripped.startswith("# "):
            title = stripped[2:].strip()
            title = re.sub(r"[*_`]", "", title)
            return title
    return "Premarket Report"


def strip_first_h1(md_text):
    lines = md_text.splitlines()
    for i, line in enumerate(lines):
        if line.strip().startswith("# "):
            del lines[i]
            break
    return "\n".join(lines)


def render_html(md_text, date_str, generated_str):
    title = extract_title(md_text)
    body_md = strip_first_h1(md_text)
    body_html = markdown.markdown(
        body_md,
        extensions=["tables", "fenced_code", "sane_lists"],
    )
    return HTML_TEMPLATE.format(
        title=title, css=CSS, date=date_str, body=body_html, generated=generated_str,
    )


def main():
    if len(sys.argv) < 2:
        print("Usage: python render_report.py REPORT.md [YYYY-MM-DD]")
        sys.exit(1)

    md_path = Path(sys.argv[1])
    if not md_path.exists():
        print(f"error: {md_path} not found")
        sys.exit(1)

    if len(sys.argv) >= 3:
        date_str = sys.argv[2]
    else:
        date_str = datetime.now(ET).strftime("%Y-%m-%d")

    md_text = md_path.read_text()
    generated_str = datetime.now(ET).strftime("%Y-%m-%d %I:%M %p ET")

    html = render_html(md_text, date_str, generated_str)

    out_dir = SCRIPT_DIR / "reports"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"premarket_{date_str}.html"
    out_path.write_text(html)

    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
