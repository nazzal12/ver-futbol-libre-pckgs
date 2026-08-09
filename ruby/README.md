# Futbol Libre Hoy (Ruby)

List today's football fixtures and live scores from the public matchday calendar feed at https://verfutbollibre.net.

A small, dependency-free gem and CLI. It fetches the day's fixtures, formats scores, filters live games, and groups matches by competition. No API key required.

## Install

```bash
gem install futbol-libre-hoy
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

```ruby
require 'futbol_libre_hoy'

cal = FutbolLibreHoy.fetch_calendar(filter: 'live')
cal['matches'].each do |m|
  puts "#{FutbolLibreHoy.format_line(m)} #{m['url']}"
end
```

### Methods

| Method | Description |
| --- | --- |
| `fetch_calendar(date:, filter:, base_url:)` | Fetch fixtures for a day |
| `parse_calendar(input)` | Parse a raw JSON string or hash |
| `format_line(m)` | One-line `Home 1-0 Away` summary |
| `format_score(m)` | Just the score, or `vs` if not started |

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
