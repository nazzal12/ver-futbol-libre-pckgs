# Futbol Libre Hoy (PHP / Packagist)

Matchday CLI and library for **[futbol en vivo hoy](https://verfutbollibre.net)**. It reads the public calendar feed, formats scores, and lists today's fixtures. No API key required.

## Install

```bash
composer require nazzal12/futbol-libre-hoy
```

## CLI

```bash
php vendor/bin/futbol-libre-hoy                     # today's fixtures
php vendor/bin/futbol-libre-hoy --live              # only live matches
php vendor/bin/futbol-libre-hoy --date 2026-08-09   # a specific day
php vendor/bin/futbol-libre-hoy --json              # raw JSON output
```

## Library

```php
<?php
require 'vendor/autoload.php';

use FutbolLibreHoy\Calendar;

$cal = Calendar::fetch(null, 'live');
foreach ($cal['matches'] as $m) {
    echo Calendar::formatLine($m) . ' ' . $m['url'] . PHP_EOL;
}
```

### Methods

| Method | Description |
| --- | --- |
| `Calendar::fetch(?string $date, string $filter, string $base)` | Fetch fixtures for a day |
| `Calendar::parse(string $json)` | Parse a raw JSON response |
| `Calendar::formatLine(array $m)` | One-line `Home 1-0 Away` summary |
| `Calendar::formatScore(array $m)` | Just the score, or `vs` if not started |

## Data source

Reads the public calendar feed at `https://verfutbollibre.net/api/v1/calendar`. See [DISCLAIMER.md](./DISCLAIMER.md).

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
