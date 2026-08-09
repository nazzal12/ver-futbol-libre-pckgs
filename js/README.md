# Futbol Libre Hoy

List today's football fixtures and live scores from **[Futbol Libre](https://verfutbollibre.net)**.

```bash
npx futbol-libre-hoy
npx futbol-libre-hoy --live
npx futbol-libre-hoy --date 2026-08-09 --json
```

```js
import { fetchCalendar, formatLine } from 'futbol-libre-hoy';

const cal = await fetchCalendar({ filter: 'live' });
for (const m of cal.matches) {
  console.log(formatLine(m), m.url);
}
```

Public feed: `/api/v1/calendar` on the site above.

Source: https://github.com/nazzal12/ver-fubtol-libre-pckgs
