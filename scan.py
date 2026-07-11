"""
Premarket data gatherer. Pulls raw market data into packet.json.

This script does ZERO analysis. No conviction calls, no buckets, no
opinions on setups. It only collects numbers and headlines. Every
judgment call (is this a good trade, which bucket does it belong in,
how good is the catalyst) happens later in AI prompts that read
packet.json.

Uses only free, keyless sources: yfinance, feedparser, requests.
"""

import json
import math
import os
import re
import time
from datetime import datetime, timedelta
from html import unescape
from zoneinfo import ZoneInfo

import feedparser
import requests
import yfinance as yf

ET = ZoneInfo("America/New_York")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_FILE = os.path.join(SCRIPT_DIR, ".econ_calendar_cache.json")
CACHE_TTL_SECONDS = 4 * 60 * 60

# yfinance's default HTTP client (curl_cffi) does browser TLS
# impersonation, which some corporate proxies reset. A plain requests
# session works everywhere and yfinance accepts it directly.
SESSION = requests.Session()
SESSION.headers.update({
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    )
})

INSTRUMENTS = {
    "S&P 500": "^GSPC",
    "Dow": "^DJI",
    "Nasdaq": "^IXIC",
    "Russell 2000": "^RUT",
    "VIX": "^VIX",
    "US 10Y": "^TNX",
    "US 3M": "^IRX",
    "WTI Oil": "CL=F",
    "Dollar (DXY)": "DX-Y.NYB",
}

UNIVERSE = [
    "NVDA", "AMD", "AVGO", "SMCI", "MRVL", "TSLA", "AAPL", "MSFT", "META",
    "AMZN", "GOOGL", "NFLX", "DELL", "SNOW", "PLTR", "COIN", "MSTR", "SOFI",
    "RIVN", "NIO", "MARA", "RIOT", "BA", "DIS", "JPM", "BAC", "XOM", "CVX",
    "HOOD", "UBER", "CRWD", "PANW", "CELH", "LULU", "NKE", "CAVA", "DKNG",
    "ARM", "INTC", "MU",
]

UNIVERSE_NAMES = {
    "NVDA": "NVIDIA", "AMD": "Advanced Micro Devices", "AVGO": "Broadcom",
    "SMCI": "Super Micro Computer", "MRVL": "Marvell Technology",
    "TSLA": "Tesla", "AAPL": "Apple", "MSFT": "Microsoft",
    "META": "Meta Platforms", "AMZN": "Amazon", "GOOGL": "Alphabet",
    "NFLX": "Netflix", "DELL": "Dell Technologies", "SNOW": "Snowflake",
    "PLTR": "Palantir Technologies", "COIN": "Coinbase Global",
    "MSTR": "Strategy", "SOFI": "SoFi Technologies",
    "RIVN": "Rivian Automotive", "NIO": "NIO", "MARA": "MARA Holdings",
    "RIOT": "Riot Platforms", "BA": "Boeing", "DIS": "Disney",
    "JPM": "JPMorgan Chase", "BAC": "Bank of America", "XOM": "Exxon Mobil",
    "CVX": "Chevron", "HOOD": "Robinhood Markets", "UBER": "Uber Technologies",
    "CRWD": "CrowdStrike", "PANW": "Palo Alto Networks",
    "CELH": "Celsius Holdings", "LULU": "Lululemon Athletica", "NKE": "Nike",
    "CAVA": "CAVA Group", "DKNG": "DraftKings", "ARM": "Arm Holdings",
    "INTC": "Intel", "MU": "Micron Technology",
}

RSS_FEEDS = {
    "MarketWatch Top": "https://www.marketwatch.com/rss/topstories",
    "MarketWatch RealTime": "https://www.marketwatch.com/rss/realtimeheadlines",
    "CNBC": "https://www.cnbc.com/id/100003114/device/rss/rss.html",
    "Yahoo Finance": "https://finance.yahoo.com/news/rssindex",
    "Google News Markets": (
        "https://news.google.com/rss/search?q=markets+OR+earnings+when:1d"
        "&hl=en-US&gl=US&ceid=US:en"
    ),
}

SPAM_PATTERNS = [
    re.compile(r"price prediction", re.IGNORECASE),
    re.compile(r"\b20\d{2}-20\d{2}\b"),
]

PRIMARY_PUBLISHERS = {
    "bloomberg", "reuters", "cnbc", "marketwatch", "barron's", "barrons",
    "yahoo finance", "wsj", "the wall street journal", "wall street journal",
    "associated press", "ap news", "axios",
}

# Generic corporate words that must not match a headline on their own,
# because a word like "Applied" or "Advanced" will cross-match totally
# unrelated companies.
COMPANY_STOPWORDS = {
    "the", "inc", "incorporated", "corp", "corporation", "co", "company",
    "holdings", "holding", "technologies", "technology", "group", "digital",
    "applied", "advanced", "strategy", "strategies", "motors", "energy",
    "platforms", "platform", "systems", "international", "global",
    "industries", "industrial", "solutions", "therapeutics",
    "pharmaceuticals", "networks", "labs", "laboratories", "ventures",
    "capital", "partners", "enterprises", "ltd", "llc", "plc", "class",
}

ECON_CALENDAR_URL = "https://nfs.faireconomy.media/ff_calendar_thisweek.json"

GAP_MIN_PCT = 4.0
PRICE_MIN = 3.0
TOP_N_GAPPERS = 12

DAY_RULES = {
    "gap_pct_min": 3.0,
    "price_min": 3.0,
    "market_cap_min": 1_000_000_000,
    "rvol_min": 1.5,
}

SWING_RULES = {
    "gap_pct_min": 8.0,
    "price_min": 3.0,
    "market_cap_min": 800_000_000,
}


def log(msg):
    print(f"[scan] {msg}")


def safe(label, fn, default=None):
    """Run fn(), swallow any error, log it, return default. Nothing
    a single bad ticker or feed does should crash the whole run."""
    try:
        return fn()
    except Exception as exc:
        log(f"  warning: {label} failed ({type(exc).__name__}: {exc})")
        return default


def clean_num(value):
    """Coerce to a plain float, or None if it's missing/NaN/inf."""
    if value is None:
        return None
    try:
        f = float(value)
    except (TypeError, ValueError):
        return None
    if math.isnan(f) or math.isinf(f):
        return None
    return f


def strip_html(text):
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    text = unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def is_spam(title):
    return any(p.search(title) for p in SPAM_PATTERNS)


# ---------------------------------------------------------------------
# 1. Market snapshot
# ---------------------------------------------------------------------

def get_market_snapshot():
    log("Pulling market snapshot (indices, rates, oil, dollar)...")
    snapshot = {}
    df = safe(
        "instrument batch download",
        lambda: yf.download(
            list(INSTRUMENTS.values()), period="5d", interval="1d",
            group_by="ticker", session=SESSION, progress=False, threads=True,
        ),
    )
    for name, symbol in INSTRUMENTS.items():
        entry = {"symbol": symbol, "last": None, "prev_close": None, "change_pct": None}
        try:
            closes = df[symbol]["Close"].dropna()
            last = clean_num(closes.iloc[-1])
            prev = clean_num(closes.iloc[-2])
            entry["last"] = last
            entry["prev_close"] = prev
            if last is not None and prev not in (None, 0):
                entry["change_pct"] = round((last - prev) / prev * 100, 3)
        except Exception as exc:
            log(f"  warning: snapshot for {name} ({symbol}) failed ({exc})")
        snapshot[name] = entry
    return snapshot


# ---------------------------------------------------------------------
# 2/3. Top movers + gap filter
# ---------------------------------------------------------------------

def _mover_from_quote(q):
    price = clean_num(q.get("regularMarketPrice"))
    prev_close = clean_num(q.get("regularMarketPreviousClose"))
    gap_pct = clean_num(q.get("regularMarketChangePercent"))
    if gap_pct is None and price is not None and prev_close not in (None, 0):
        gap_pct = round((price - prev_close) / prev_close * 100, 3)
    return {
        "ticker": q.get("symbol"),
        "name": q.get("shortName") or q.get("longName") or q.get("symbol"),
        "price": price,
        "prev_close": prev_close,
        "gap_pct": gap_pct,
        "market_cap": clean_num(q.get("marketCap")),
        "volume": clean_num(q.get("regularMarketVolume")),
    }


def get_live_movers():
    log("Pulling live top movers (day_gainers, most_actives screeners)...")
    quotes_by_symbol = {}
    for query in ("day_gainers", "most_actives"):
        result = safe(
            f"screen({query})",
            lambda q=query: yf.screen(q, count=50, session=SESSION),
        )
        quotes = (result or {}).get("quotes") or []
        for q in quotes:
            symbol = q.get("symbol")
            if symbol and symbol not in quotes_by_symbol:
                quotes_by_symbol[symbol] = _mover_from_quote(q)
        log(f"  {query}: {len(quotes)} quotes")
    return list(quotes_by_symbol.values())


def get_fallback_universe_movers():
    log("Live screeners came up short, falling back to static universe...")
    movers = []
    df = safe(
        "universe batch download",
        lambda: yf.download(
            UNIVERSE, period="5d", interval="1d", group_by="ticker",
            session=SESSION, progress=False, threads=True,
        ),
    )
    for ticker in UNIVERSE:
        try:
            closes = df[ticker]["Close"].dropna()
            volumes = df[ticker]["Volume"].dropna()
            price = clean_num(closes.iloc[-1])
            prev_close = clean_num(closes.iloc[-2])
            if price is None or prev_close in (None, 0):
                continue
            gap_pct = round((price - prev_close) / prev_close * 100, 3)
        except Exception as exc:
            log(f"  warning: fallback price data for {ticker} failed ({exc})")
            continue

        market_cap = None
        fi = safe(f"fast_info({ticker})", lambda t=ticker: yf.Ticker(t, session=SESSION).fast_info)
        if fi:
            market_cap = clean_num(fi.get("marketCap"))

        movers.append({
            "ticker": ticker,
            "name": UNIVERSE_NAMES.get(ticker, ticker),
            "price": price,
            "prev_close": prev_close,
            "gap_pct": gap_pct,
            "market_cap": market_cap,
            "volume": clean_num(volumes.iloc[-1]) if len(volumes) else None,
        })
    return movers


def filter_gappers(movers):
    kept = [
        m for m in movers
        if m.get("gap_pct") is not None
        and abs(m["gap_pct"]) >= GAP_MIN_PCT
        and m.get("price") is not None
        and m["price"] >= PRICE_MIN
    ]
    kept.sort(key=lambda m: abs(m["gap_pct"]), reverse=True)
    return kept[:TOP_N_GAPPERS]


# ---------------------------------------------------------------------
# 4. Market-wide news
# ---------------------------------------------------------------------

def get_market_news():
    log("Fetching market-wide RSS news...")
    entries = []
    for source_name, url in RSS_FEEDS.items():
        parsed = safe(f"feed({source_name})", lambda u=url: feedparser.parse(u))
        feed_entries = getattr(parsed, "entries", []) if parsed else []
        for e in feed_entries:
            title = strip_html(getattr(e, "title", "") or "")
            if not title or is_spam(title):
                continue
            summary = strip_html(getattr(e, "summary", "") or getattr(e, "description", "") or "")
            publisher = source_name
            src = getattr(e, "source", None)
            if src is not None and getattr(src, "title", None):
                publisher = src.title
            entries.append({
                "title": title,
                "summary": summary,
                "link": getattr(e, "link", None),
                "published": getattr(e, "published", None),
                "source": publisher,
                "feed": source_name,
            })
        log(f"  {source_name}: {len(feed_entries)} entries")

    # Dedupe by title, keep first occurrence.
    seen = set()
    deduped = []
    for e in entries:
        key = e["title"].lower().strip()
        if key in seen:
            continue
        seen.add(key)
        deduped.append(e)
    return deduped


# ---------------------------------------------------------------------
# 5. Economic calendar (cached, defensive)
# ---------------------------------------------------------------------

def _load_calendar_cache():
    try:
        with open(CACHE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return None


def _save_calendar_cache(raw_events):
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump({"fetched_at": datetime.now(ET).isoformat(), "events": raw_events}, f)
    except Exception as exc:
        log(f"  warning: could not write econ calendar cache ({exc})")


def _fetch_calendar_raw():
    cache = _load_calendar_cache()
    if cache:
        fetched_at = datetime.fromisoformat(cache["fetched_at"])
        age = (datetime.now(ET) - fetched_at).total_seconds()
        if age < CACHE_TTL_SECONDS:
            return cache["events"], None, cache["fetched_at"]

    try:
        resp = requests.get(ECON_CALENDAR_URL, timeout=15, headers={"User-Agent": SESSION.headers["User-Agent"]})
        resp.raise_for_status()
        events = resp.json()
        _save_calendar_cache(events)
        return events, None, datetime.now(ET).isoformat()
    except Exception as exc:
        if cache:
            return cache["events"], f"live fetch failed ({exc}), using cache from {cache['fetched_at']}", cache["fetched_at"]
        return [], f"live fetch failed ({exc}) and no cache available", None


def get_econ_calendar():
    log("Fetching economic calendar (ForexFactory this-week feed)...")
    try:
        raw_events, note, fetched_at = _fetch_calendar_raw()
        now_et = datetime.now(ET)
        today_date = now_et.date()
        tomorrow_date = today_date + timedelta(days=1)

        today_events, tomorrow_events = [], []
        for ev in raw_events:
            if ev.get("country") != "USD" or ev.get("impact") != "High":
                continue
            try:
                dt = datetime.fromisoformat(ev["date"]).astimezone(ET)
            except Exception:
                continue
            item = {
                "time_et": dt.strftime("%-I:%M %p ET"),
                "title": ev.get("title"),
                "forecast": ev.get("forecast") or None,
                "previous": ev.get("previous") or None,
            }
            if dt.date() == today_date:
                today_events.append((dt, item))
            elif dt.date() == tomorrow_date:
                tomorrow_events.append((dt, item))

        today_events.sort(key=lambda x: x[0])
        tomorrow_events.sort(key=lambda x: x[0])

        return {
            "source": ECON_CALENDAR_URL,
            "filter": "USD country, High impact only (covers data prints and Fed events like FOMC/Powell)",
            "today_date": today_date.isoformat(),
            "tomorrow_date": tomorrow_date.isoformat(),
            "today": [item for _, item in today_events],
            "tomorrow": [item for _, item in tomorrow_events],
            "note": note or "",
        }
    except Exception as exc:
        log(f"  warning: econ calendar fully failed ({exc})")
        return {
            "source": ECON_CALENDAR_URL,
            "filter": "USD country, High impact only",
            "today_date": None,
            "tomorrow_date": None,
            "today": [],
            "tomorrow": [],
            "note": f"error: {exc}",
        }


# ---------------------------------------------------------------------
# 6. Per-gapper enrichment
# ---------------------------------------------------------------------

def _company_tokens(name):
    words = re.findall(r"[A-Za-z][A-Za-z0-9.'-]*", name or "")
    return [w for w in words if len(w) >= 4 and w.lower() not in COMPANY_STOPWORDS]


def _headline_matches_ticker(title, ticker, tokens):
    if len(ticker) >= 3 and re.search(rf"\b{re.escape(ticker)}\b", title):
        return True
    for tok in tokens:
        if re.search(rf"\b{re.escape(tok)}\b", title, re.IGNORECASE):
            return True
    return False


def _publisher_rank(publisher):
    return 0 if (publisher or "").strip().lower() in PRIMARY_PUBLISHERS else 1


def get_catalyst(ticker, company_name, rss_entries):
    tokens = _company_tokens(company_name)
    candidates = []

    yf_news = safe(f"news({ticker})", lambda: yf.Ticker(ticker, session=SESSION).news, default=[])
    for item in (yf_news or []):
        content = item.get("content", {}) if isinstance(item, dict) else {}
        title = strip_html(content.get("title", ""))
        if not title or is_spam(title):
            continue
        if not _headline_matches_ticker(title, ticker, tokens):
            continue
        candidates.append({
            "headline": title,
            "source": (content.get("provider") or {}).get("displayName") or "Yahoo Finance",
            "url": (content.get("canonicalUrl") or {}).get("url"),
            "published": content.get("pubDate"),
        })

    for e in rss_entries:
        if not _headline_matches_ticker(e["title"], ticker, tokens):
            continue
        candidates.append({
            "headline": e["title"],
            "source": e["source"],
            "url": e["link"],
            "published": e["published"],
        })

    if not candidates:
        return {"catalyst_found": False, "catalyst_headline": None, "catalyst_source": None, "catalyst_url": None, "catalyst_headlines": []}

    candidates.sort(key=lambda c: _publisher_rank(c["source"]))
    top = candidates[0]
    seen_titles = set()
    extra = []
    for c in candidates:
        key = c["headline"].lower()
        if key in seen_titles:
            continue
        seen_titles.add(key)
        extra.append(c["headline"])
        if len(extra) >= 3:
            break

    return {
        "catalyst_found": True,
        "catalyst_headline": top["headline"],
        "catalyst_source": top["source"],
        "catalyst_url": top["url"],
        "catalyst_headlines": extra,
    }


def get_intraday_levels(ticker):
    hist = safe(
        f"intraday({ticker})",
        lambda: yf.Ticker(ticker, session=SESSION).history(period="2d", interval="5m", prepost=True),
    )
    result = {"vwap": None, "hod": None, "lod": None, "premarket_high": None, "premarket_volume": None}
    if hist is None or hist.empty:
        return result
    try:
        hist = hist.tz_convert(ET)
        today = datetime.now(ET).date()
        today_rows = hist[hist.index.date == today]
        if today_rows.empty:
            return result

        typical = (today_rows["High"] + today_rows["Low"] + today_rows["Close"]) / 3
        vol = today_rows["Volume"]
        if vol.sum() > 0:
            result["vwap"] = round(float((typical * vol).sum() / vol.sum()), 4)
        result["hod"] = clean_num(today_rows["High"].max())
        result["lod"] = clean_num(today_rows["Low"].min())

        premarket = today_rows[today_rows.index.time < datetime.strptime("09:30", "%H:%M").time()]
        if not premarket.empty:
            result["premarket_high"] = clean_num(premarket["High"].max())
            result["premarket_volume"] = clean_num(premarket["Volume"].sum())
    except Exception as exc:
        log(f"  warning: intraday level math for {ticker} failed ({exc})")
    return result


def get_daily_metrics(ticker):
    hist = safe(
        f"daily({ticker})",
        lambda: yf.Ticker(ticker, session=SESSION).history(period="1y", interval="1d", prepost=False),
    )
    result = {
        "sma_200": None, "prior_day_high": None, "prior_close": None,
        "today_open": None, "avg_volume_20d": None, "today_volume_so_far": None,
    }
    if hist is None or hist.empty:
        return result
    try:
        hist = hist.tz_convert(ET) if hist.index.tz else hist.tz_localize(ET)
        today = datetime.now(ET).date()
        today_mask = hist.index.date == today
        completed = hist[~today_mask]
        today_rows = hist[today_mask]

        if not completed.empty:
            tail200 = completed["Close"].dropna().tail(200)
            if len(tail200):
                result["sma_200"] = round(float(tail200.mean()), 4)
            last_completed = completed.iloc[-1]
            result["prior_day_high"] = clean_num(last_completed["High"])
            result["prior_close"] = clean_num(last_completed["Close"])
            tail20vol = completed["Volume"].dropna().tail(20)
            if len(tail20vol):
                result["avg_volume_20d"] = round(float(tail20vol.mean()), 2)

        if not today_rows.empty:
            today_bar = today_rows.iloc[-1]
            result["today_open"] = clean_num(today_bar["Open"])
            result["today_volume_so_far"] = clean_num(today_bar["Volume"])
    except Exception as exc:
        log(f"  warning: daily metrics for {ticker} failed ({exc})")
    return result


def get_next_earnings_date(ticker):
    cal = safe(f"calendar({ticker})", lambda: yf.Ticker(ticker, session=SESSION).calendar, default={})
    dates = (cal or {}).get("Earnings Date") or []
    if not dates:
        return None
    return str(dates[0])


def enrich_gapper(mover, rss_entries, index, total):
    ticker = mover["ticker"]
    log(f"  enriching {ticker} ({index}/{total})...")

    catalyst = get_catalyst(ticker, mover.get("name"), rss_entries)
    levels = get_intraday_levels(ticker)
    daily = get_daily_metrics(ticker)
    next_earnings = get_next_earnings_date(ticker)

    # yfinance reports roughly zero volume during premarket for most
    # tickers (Yahoo just doesn't populate it reliably pre-9:30am), so
    # this RVOL is full trading day volume so far over the 20-day
    # average volume. It is a keyless stand-in, not true premarket
    # RVOL. A real premarket RVOL needs a premarket-aware feed like
    # Alpaca.
    rvol = None
    vol_so_far = daily.get("today_volume_so_far") or mover.get("volume")
    if vol_so_far is not None and daily.get("avg_volume_20d"):
        rvol = round(vol_so_far / daily["avg_volume_20d"], 3)

    price = mover.get("price")
    gap_pct = mover.get("gap_pct")
    market_cap = mover.get("market_cap")
    prior_high = daily.get("prior_day_high")
    today_open = daily.get("today_open")
    sma_200 = daily.get("sma_200")

    day_eligible = bool(
        gap_pct is not None and gap_pct > DAY_RULES["gap_pct_min"]
        and price is not None and price > DAY_RULES["price_min"]
        and market_cap is not None and market_cap > DAY_RULES["market_cap_min"]
        and rvol is not None and rvol > DAY_RULES["rvol_min"]
        and prior_high is not None and price > prior_high
    )

    swing_eligible = bool(
        gap_pct is not None and gap_pct >= SWING_RULES["gap_pct_min"]
        and price is not None and price > SWING_RULES["price_min"]
        and today_open is not None and prior_high is not None and today_open > prior_high
        and today_open is not None and sma_200 is not None and today_open > sma_200
        and market_cap is not None and market_cap >= SWING_RULES["market_cap_min"]
        and catalyst["catalyst_found"]
    )

    return {
        **mover,
        **catalyst,
        **levels,
        **daily,
        "rvol": rvol,
        "next_earnings_date": next_earnings,
        "day_eligible": day_eligible,
        "swing_eligible": swing_eligible,
    }


# ---------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------

def build_trading_day_note():
    now_et = datetime.now(ET)
    weekday = now_et.strftime("%A")
    note = f"Scan run {weekday}, {now_et.strftime('%Y-%m-%d %I:%M %p')} ET."
    if now_et.weekday() >= 5:
        note += " Markets are closed today (weekend), so this data reflects the last session."
    return note


def build_criteria_notes():
    return {
        "day_trading": (
            "Trend Join Long. Premarket: gap > 3%, price > $3, market cap > $1B, "
            "premarket RVOL > 1.5, price breaking above yesterday's high. "
            "Intraday window 10:00am to 3:30pm ET, trigger above premarket high "
            "and prior high-of-day, stop 1% below premarket high or LOD "
            "(whichever is lower) as 1R, scale 1/3 at +1R and 1/3 at +2R, trail "
            "the last 1/3 on the 21-EMA, flat by 3:51pm."
        ),
        "swing": (
            "Premarket: gap >= 8%, price > $3, open above yesterday's high, "
            "open above the 200-day SMA, market cap >= $800M, and a real "
            "catalyst (earnings on the gap day, or news with no earnings). "
            "Entry and exit management is still being built, so these are "
            "starter ideas only, no stops or targets attached."
        ),
    }


def main():
    started = time.time()
    log("Starting premarket scan...")

    market_snapshot = get_market_snapshot()

    live_movers = get_live_movers()
    if len(live_movers) < 5:
        movers = get_fallback_universe_movers()
        candidate_source = "static_universe_fallback"
    else:
        movers = live_movers
        candidate_source = "live_screener"

    log(f"Candidate source: {candidate_source} ({len(movers)} raw candidates)")

    gappers = filter_gappers(movers)
    log(f"Gap filter kept {len(gappers)} gappers (>= {GAP_MIN_PCT}% gap, >= ${PRICE_MIN} price)")

    market_news = get_market_news()
    econ_calendar = get_econ_calendar()

    log(f"Enriching {len(gappers)} gappers with catalysts, levels, and eligibility flags...")
    enriched = [
        enrich_gapper(m, market_news, i + 1, len(gappers))
        for i, m in enumerate(gappers)
    ]

    packet = {
        "generated_at": datetime.now(ET).isoformat(),
        "candidate_source": candidate_source,
        "trading_day_note": build_trading_day_note(),
        "scan_params": {
            "gap_min_pct": GAP_MIN_PCT,
            "price_min": PRICE_MIN,
            "top_n_gappers": TOP_N_GAPPERS,
            "universe_size": len(UNIVERSE),
            "rss_feeds": list(RSS_FEEDS.keys()),
            "econ_calendar_source": ECON_CALENDAR_URL,
            "econ_calendar_cache_ttl_hours": CACHE_TTL_SECONDS / 3600,
        },
        "criteria": build_criteria_notes(),
        "market_snapshot": market_snapshot,
        "econ_calendar": econ_calendar,
        "gappers": enriched,
        "market_news": market_news[:20],
        "gaps_to_fill": [
            "Market-wide earnings calendar is not included, only each gapper's "
            "own next earnings date. A full earnings calendar needs a separate feed.",
            "Intraday levels (VWAP, HOD, LOD, premarket high) come from Yahoo's "
            "5-minute bars, which can lag or gap out during thin premarket trading.",
            "RVOL here is today's volume so far over the 20-day average volume, "
            "not true premarket RVOL, because yfinance does not reliably report "
            "premarket volume. A real premarket RVOL needs a premarket-aware feed "
            "like Alpaca.",
        ],
    }

    out_path = os.path.join(SCRIPT_DIR, "packet.json")
    with open(out_path, "w") as f:
        json.dump(packet, f, indent=2, default=str)

    elapsed = round(time.time() - started, 1)
    log(f"Done in {elapsed}s. Wrote {out_path} with {len(enriched)} gappers.")


if __name__ == "__main__":
    main()
