# Futbol Libre Hoy

List today's football fixtures and live scores from **[Futbol Libre](https://verfutbollibre.net)** right in your terminal or app.

`futbol-libre-hoy` is a small, dependency-free client and CLI for the public matchday calendar feed. It fetches the day's fixtures, formats scores, filters live games, and groups matches by competition.

## Install

```bash
npm install futbol-libre-hoy
# or run without installing
npx futbol-libre-hoy
```

## CLI

```bash
npx futbol-libre-hoy                     # today's fixtures
npx futbol-libre-hoy --live              # only live matches
npx futbol-libre-hoy --date 2026-08-09   # a specific day (YYYY-MM-DD)
npx futbol-libre-hoy --json              # raw JSON output
```

| Flag | Description |
| --- | --- |
| `--live` | Show only matches currently in play |
| `--date <YYYY-MM-DD>` | Fetch fixtures for a specific day |
| `--json` | Print the raw calendar response as JSON |
| `--help` | Show usage |

## Library

```js
import {
  fetchCalendar,
  filterMatches,
  groupByTournament,
  formatLine,
  formatScore,
  isLive,
} from 'futbol-libre-hoy';

// Fetch live matches
const cal = await fetchCalendar({ filter: 'live' });
for (const m of cal.matches) {
  console.log(formatLine(m), m.url);
}

// Group a day's fixtures by competition
const day = await fetchCalendar({ date: '2026-08-09' });
const byComp = groupByTournament(day.matches);
```

### API

| Export | Signature | Description |
| --- | --- | --- |
| `fetchCalendar` | `(opts?) => Promise<CalendarResponse>` | Fetch fixtures. Options: `{ date?, filter?, baseUrl? }` |
| `filterMatches` | `(matches, filter) => Match[]` | Filter by `live`, `upcoming`, or `finished` |
| `groupByTournament` | `(matches) => Group[]` | Group matches by competition, in feed order |
| `formatLine` | `(match) => string` | One-line `Home 1 - 0 Away` summary |
| `formatScore` | `(match) => string` | Just the score, or kickoff time if not started |
| `isLive` | `(match) => boolean` | Whether a match is in play |

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. No API key required. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT © NBK Devs
