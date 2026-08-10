# Futbol Libre Hoy (CocoaPods)

Swift client for today's football fixtures and live scores from **[Futbol Libre](https://verfutbollibre.net)**. Reads the public calendar feed, formats scores, and filters live matches. No API key required.

## Install

```ruby
pod 'FutbolLibreHoy', '~> 1.0'
```

```swift
import FutbolLibreHoy

FutbolLibreHoy.fetchCalendar(filter: "live") { result in
  switch result {
  case .success(let cal):
    for m in cal.matches {
      print(FutbolLibreHoy.formatLine(m), m.url)
    }
  case .failure(let error):
    print(error)
  }
}
```

## API

| API | Description |
| --- | --- |
| `parseCalendar(_:)` | Parse a JSON string or dictionary |
| `fetchCalendar(date:filter:baseURL:completion:)` | Fetch fixtures for a day |
| `filterMatches(_:filter:)` | Filter by `live`, `upcoming`, or `finished` |
| `groupByTournament(_:)` | Group matches by competition |
| `formatLine(_:)` / `formatScore(_:)` / `isLive(_:)` | Display helpers |

## Data source

`https://verfutbollibre.net/api/v1/calendar` - see [DISCLAIMER.md](./DISCLAIMER.md).

## Publish

Use `.github/workflows/cocoapods.yml` (macOS). Requires secret `COCOAPODS_TRUNK_TOKEN`. Tag: `cocoapods-1.0.0`.

## Source

https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
