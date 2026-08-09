# Futbol Libre Hoy (Rust)

CLI and library for today's football fixtures and live scores. Try **[futbol libre en vivo](https://verfutbollibre.net)** match listings straight from the terminal.

It reads the public matchday calendar feed, formats scores, filters live games, and groups fixtures by competition. No API key required.

## Install

```bash
cargo install futbol-libre-hoy
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

```rust
use futbol_libre_hoy::{fetch_calendar, format_line, DEFAULT_BASE_URL};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // fetch_calendar(base_url, date, filter)
    let cal = fetch_calendar(DEFAULT_BASE_URL, None, Some("live"))?;
    for m in &cal.matches {
        println!("{} {}", format_line(m), m.url);
    }
    Ok(())
}
```

Other helpers: `parse_calendar`, `filter_matches`, `group_by_tournament`, `format_score`, `is_live`.

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-fubtol-libre-pckgs

## License

MIT (c) NBK Devs
