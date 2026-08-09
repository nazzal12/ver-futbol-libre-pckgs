from __future__ import annotations

import argparse
import json
import sys

from . import (
    DEFAULT_BASE_URL,
    fetch_calendar,
    filter_matches,
    format_line,
    group_by_tournament,
    parse_calendar,
    sample_path,
)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Futbol Libre Hoy — partidos de hoy y en vivo")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--live", action="store_true")
    g.add_argument("--upcoming", action="store_true")
    g.add_argument("--finished", action="store_true")
    p.add_argument("--date")
    p.add_argument("--json", action="store_true")
    p.add_argument("--sample", action="store_true", help="Use bundled sample data (offline)")
    args = p.parse_args(argv)

    filt = "all"
    if args.live:
        filt = "live"
    elif args.upcoming:
        filt = "upcoming"
    elif args.finished:
        filt = "finished"

    if args.sample:
        calendar = parse_calendar(sample_path().read_text(encoding="utf-8"))
    else:
        calendar = fetch_calendar(date=args.date, filter=filt)

    matches = filter_matches(calendar.matches, filt)
    if args.json:
        print(
            json.dumps(
                {
                    "source": calendar.source,
                    "homepage": calendar.homepage,
                    "date": calendar.date,
                    "filter": filt,
                    "count": len(matches),
                    "matches": [m.__dict__ for m in matches],
                },
                ensure_ascii=False,
                indent=2,
                default=lambda o: o.__dict__ if hasattr(o, "__dict__") else str(o),
            )
        )
        return 0

    print(f"Futbol Libre Hoy — {calendar.date or 'hoy'} ({len(matches)})")
    print(f"{calendar.homepage or DEFAULT_BASE_URL}\n")
    if not matches:
        print("No hay partidos para este filtro.")
        print(f"Ver agenda completa: {DEFAULT_BASE_URL}")
        return 0

    for group in group_by_tournament(matches):
        print(f"## {group['tournament'].name}")
        for m in group["matches"]:
            print(f"- {format_line(m)}")
            print(f"  {m.url}")
        print()
    print(f"Más en Futbol Libre: {DEFAULT_BASE_URL}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
