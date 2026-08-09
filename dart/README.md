# Futbol Libre Hoy (Dart)

Fetch today's football fixtures and live scores with **[Ver Futbol Libre](https://verfutbollibre.net)** matchday data. A small, dependency-free client for the public calendar feed. No API key required.

## Install

```yaml
dependencies:
  futbol_libre_hoy: ^1.0.0
```

## Usage

```dart
import 'package:futbol_libre_hoy/futbol_libre_hoy.dart';

Future<void> main() async {
  final cal = await fetchCalendar(filter: 'live');
  for (final m in cal.matches) {
    print('${formatLine(m)} ${m.url}');
  }
}
```

Fetch a specific day:

```dart
final day = await fetchCalendar(date: '2026-08-09');
final live = filterMatches(day.matches, 'live');
```

## API

| Function | Description |
| --- | --- |
| `fetchCalendar({baseUrl, date, filter})` | Fetch fixtures for a day |
| `parseCalendar(input)` | Parse a raw JSON string or map |
| `filterMatches(matches, filter)` | Filter by `live`, `upcoming`, or `finished` |
| `formatLine(m)` | One-line `Home 1-0 Away` summary |
| `formatScore(m)` | Just the score, or `vs` if not started |
| `isLive(m)` | Whether a match is in play |

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
