# Futbol Libre Hoy (Arcade.dev)

MCP server that lists today's football fixtures and live scores via the published
`futbol-libre-hoy` Python package. Homepage: https://verfutbollibre.net

## Tools

| Tool | Description |
| --- | --- |
| `list_matches` | Text lines of fixtures (+ match URLs) |
| `list_matches_json` | Same data as JSON |

## Local run

```bash
cd arcade
pip install -e .
python server.py stdio
```

Or HTTP:

```bash
python server.py http
```

## Deploy to Arcade Cloud

```bash
pip install arcade-mcp
```

```bash
arcade login
```

```bash
cd arcade
arcade deploy -e server.py
```

Set the listing homepage / about link to https://verfutbollibre.net

## Source

https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
