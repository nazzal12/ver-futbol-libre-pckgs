# Futbol Libre Hoy (Python)

List today's football fixtures and live scores from **[Futbol Libre](https://verfutbollibre.net)**.

```bash
pip install futbol-libre-hoy
futbol-libre-hoy
futbol-libre-hoy --live
```

```python
from futbol_libre_hoy import fetch_calendar, format_line

cal = fetch_calendar(filter="live")
for m in cal.matches:
    print(format_line(m), m.url)
```

Homepage: https://verfutbollibre.net  
Repo: https://github.com/nazzal12/ver-fubtol-libre-pckgs
