#!/usr/bin/env python3
"""Arcade MCP server wrapping Futbol Libre Hoy matchday tools."""

from __future__ import annotations

import json
import sys
from typing import Annotated, Optional

from arcade_mcp_server import MCPApp
from futbol_libre_hoy import (
    DEFAULT_BASE_URL,
    fetch_calendar,
    filter_matches,
    format_line,
)

app = MCPApp(
    name="futbol_libre_hoy",
    version="1.0.0",
    description="Today's football fixtures and live scores from Futbol Libre",
)


@app.tool
def list_matches(
    filter: Annotated[
        str,
        "Match filter: all, live, upcoming, or finished",
    ] = "all",
    date: Annotated[
        Optional[str],
        "Optional day as YYYY-MM-DD (Europe/Madrid calendar). Omit for today.",
    ] = None,
) -> str:
    """List football fixtures from Futbol Libre's public matchday calendar.

    Returns one line per match plus the match page URL. Full site:
    https://verfutbollibre.net
    """
    f = (filter or "all").lower().strip()
    if f not in {"all", "live", "upcoming", "finished"}:
        f = "all"

    cal = fetch_calendar(date=date, filter=f if f != "all" else "all")
    matches = filter_matches(cal.matches, f) if f != "all" else list(cal.matches)

    if not matches:
        return (
            f"No matches for filter={f} date={cal.date or date or 'today'}. "
            f"See {DEFAULT_BASE_URL}"
        )

    lines = [f"Futbol Libre Hoy - {cal.date} ({len(matches)})"]
    for m in matches:
        lines.append(f"{format_line(m)} | {m.url}")
    lines.append(f"Homepage: {DEFAULT_BASE_URL}")
    return "\n".join(lines)


@app.tool
def list_matches_json(
    filter: Annotated[
        str,
        "Match filter: all, live, upcoming, or finished",
    ] = "all",
    date: Annotated[
        Optional[str],
        "Optional day as YYYY-MM-DD. Omit for today.",
    ] = None,
) -> str:
    """Return Futbol Libre calendar matches as JSON (id, teams, score, url)."""
    f = (filter or "all").lower().strip()
    if f not in {"all", "live", "upcoming", "finished"}:
        f = "all"

    cal = fetch_calendar(date=date, filter=f if f != "all" else "all")
    matches = filter_matches(cal.matches, f) if f != "all" else list(cal.matches)
    payload = {
        "source": cal.source,
        "homepage": DEFAULT_BASE_URL,
        "date": cal.date,
        "filter": f,
        "count": len(matches),
        "matches": [
            {
                "id": m.id,
                "status": m.status,
                "kickoff_at": m.kickoff_at,
                "home": m.home.name,
                "away": m.away.name,
                "score": list(m.score) if m.score else None,
                "minute": m.minute,
                "tournament": m.tournament.name,
                "url": m.url,
                "line": format_line(m),
            }
            for m in matches
        ],
    }
    return json.dumps(payload, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    transport = sys.argv[1] if len(sys.argv) > 1 else "stdio"
    app.run(transport=transport, host="127.0.0.1", port=8000)
