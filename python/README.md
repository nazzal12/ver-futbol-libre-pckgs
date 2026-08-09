# Futbol Libre Hoy (Python)

List today's football fixtures and live scores from the public matchday calendar feed at https://verfutbollibre.net.

`futbol-libre-hoy` is a small, dependency-free client and CLI. It fetches the day's fixtures, formats scores, filters live games, and groups matches by competition.

## Install

```bash
pip install futbol-libre-hoy
```

## CLI

```bash
futbol-libre-hoy                     # today's fixtures
futbol-libre-hoy --live              # only live matches
futbol-libre-hoy --date 2026-08-09   # a specific day (YYYY-MM-DD)
futbol-libre-hoy --json              # raw JSON output
```

| Flag | Description |
| --- | --- |
| `--live` | Show only matches currently in play |
| `--date <YYYY-MM-DD>` | Fetch fixtures for a specific day |
| `--json` | Print the raw calendar response as JSON |
| `--help` | Show usage |

## Library

```python
from futbol_libre_hoy import (
    fetch_calendar,
    filter_matches,
    group_by_tournament,
    format_line,
    format_score,
    is_live,
)

# Fetch live matches
cal = fetch_calendar(filter="live")
for m in cal.matches:
    print(format_line(m), m.url)

# Group a day's fixtures by competition
day = fetch_calendar(date="2026-08-09")
by_comp = group_by_tournament(day.matches)
```

### API

| Function | Description |
| --- | --- |
| `fetch_calendar(date=None, filter=None, base_url=None)` | Fetch fixtures for a day |
| `filter_matches(matches, filter)` | Filter by `live`, `upcoming`, or `finished` |
| `group_by_tournament(matches)` | Group matches by competition, in feed order |
| `format_line(match)` | One-line `Home 1 - 0 Away` summary |
| `format_score(match)` | Just the score, or kickoff time if not started |
| `is_live(match)` | Whether a match is in play |

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. No API key required. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
