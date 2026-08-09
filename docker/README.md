# Futbol Libre Hoy (Docker)

Containerized CLI that lists today's football fixtures and live scores from the public calendar feed at https://verfutbollibre.net. No API key required.

## Run

```bash
docker run --rm nazzal12/futbol-libre-hoy            # today's fixtures
docker run --rm nazzal12/futbol-libre-hoy --live     # only live matches
docker run --rm nazzal12/futbol-libre-hoy --json     # raw JSON output
```

## Build locally

From the repository root:

```bash
docker build -f docker/Dockerfile -t nazzal12/futbol-libre-hoy .
docker run --rm nazzal12/futbol-libre-hoy --live
```

## Data source

Reads `https://verfutbollibre.net/api/v1/calendar`. See the repository for the DISCLAIMER.

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
