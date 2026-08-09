"""Futbol Libre Hoy — public matchday client for https://verfutbollibre.net"""

from __future__ import annotations

import json
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, List, Optional, Sequence, Tuple

DEFAULT_BASE_URL = "https://verfutbollibre.net"
CALENDAR_PATH = "/api/v1/calendar"

__all__ = [
    "DEFAULT_BASE_URL",
    "CALENDAR_PATH",
    "Team",
    "Match",
    "Calendar",
    "parse_calendar",
    "format_score",
    "format_line",
    "is_live",
    "filter_matches",
    "group_by_tournament",
    "fetch_calendar",
]


@dataclass(frozen=True)
class Team:
    id: int
    name: str
    slug: str


@dataclass(frozen=True)
class Match:
    id: int
    status: str
    kickoff_at: str
    home: Team
    away: Team
    score: Optional[Tuple[int, int]]
    minute: Optional[int]
    tournament: Team
    url: str


@dataclass(frozen=True)
class Calendar:
    source: str
    homepage: str
    date: str
    filter: str
    count: int
    matches: List[Match]


def _team(raw: Any, fallback: str) -> Team:
    o = raw if isinstance(raw, dict) else {}
    return Team(
        id=int(o.get("id") or 0),
        name=str(o.get("name") or fallback),
        slug=str(o.get("slug") or ""),
    )


def normalize_match(raw: Any) -> Match:
    o = raw if isinstance(raw, dict) else {}
    score = None
    s = o.get("score")
    if isinstance(s, (list, tuple)) and len(s) >= 2:
        try:
            score = (int(s[0]), int(s[1]))
        except (TypeError, ValueError):
            score = None
    minute = o.get("minute")
    return Match(
        id=int(o.get("id") or 0),
        status=str(o.get("status") or ""),
        kickoff_at=str(o.get("kickoff_at") or ""),
        home=_team(o.get("home"), "Home"),
        away=_team(o.get("away"), "Away"),
        score=score,
        minute=None if minute in (None, "") else int(minute),
        tournament=_team(o.get("tournament"), "Tournament"),
        url=str(o.get("url") or DEFAULT_BASE_URL),
    )


def parse_calendar(input_data: Any) -> Calendar:
    data = json.loads(input_data) if isinstance(input_data, str) else input_data
    o = data if isinstance(data, dict) else {}
    matches = [normalize_match(m) for m in (o.get("matches") or [])]
    count = o.get("count")
    return Calendar(
        source=str(o.get("source") or "Futbol Libre"),
        homepage=str(o.get("homepage") or DEFAULT_BASE_URL),
        date=str(o.get("date") or ""),
        filter=str(o.get("filter") or "all"),
        count=int(count) if count is not None else len(matches),
        matches=matches,
    )


def format_score(match: Match) -> str:
    if match.score is not None:
        return f"{match.score[0]}-{match.score[1]}"
    return "vs"


def is_live(match: Match) -> bool:
    return match.status == "live"


def format_line(match: Match) -> str:
    score = format_score(match)
    pair = f"{match.home.name} {score} {match.away.name}"
    if match.status == "live":
        if match.minute is not None:
            return f"{match.minute}' {pair}"
        return f"LIVE {pair}"
    if match.status == "before":
        return f"{match.home.name} vs {match.away.name}"
    return pair


def filter_matches(matches: Sequence[Match], filt: str) -> List[Match]:
    f = (filt or "all").lower()
    if f == "live":
        return [m for m in matches if m.status == "live"]
    if f == "upcoming":
        return [m for m in matches if m.status == "before"]
    if f == "finished":
        return [m for m in matches if m.status == "after"]
    return list(matches)


def group_by_tournament(matches: Iterable[Match]) -> List[dict]:
    order: List[int] = []
    groups: dict[int, dict] = {}
    for m in matches:
        tid = m.tournament.id
        if tid not in groups:
            order.append(tid)
            groups[tid] = {"tournament": m.tournament, "matches": []}
        groups[tid]["matches"].append(m)
    return [groups[i] for i in order]


def fetch_calendar(
    *,
    base_url: str = DEFAULT_BASE_URL,
    date: Optional[str] = None,
    filter: Optional[str] = None,
) -> Calendar:
    base = base_url.rstrip("/")
    params = {}
    if date:
        params["date"] = date
    if filter and filter != "all":
        params["filter"] = filter
    qs = urllib.parse.urlencode(params)
    url = f"{base}{CALENDAR_PATH}" + (f"?{qs}" if qs else "")
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "Accept-Language": "es-ES"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        text = resp.read().decode("utf-8")
    return parse_calendar(text)


def sample_path() -> Path:
    return Path(__file__).resolve().parent / "data" / "sample-calendar.json"
