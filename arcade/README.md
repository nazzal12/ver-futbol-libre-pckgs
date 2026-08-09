# Arcade.dev - Futbol Libre Hoy

Wrap the published `futbol-libre-hoy` Python package as an Arcade tool:

```bash
pip install arcade-mcp futbol-libre-hoy
arcade login
# implement server.py with MCPApp calling fetch_calendar / format_line
arcade deploy -e server.py
```

Homepage field: https://verfutbollibre.net
