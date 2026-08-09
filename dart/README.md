# Futbol Libre Hoy (Dart)

Fetch today's fixtures with **[Ver Futbol Libre](https://verfutbollibre.net)** matchday data.

```dart
import 'package:futbol_libre_hoy/futbol_libre_hoy.dart';

final cal = await fetchCalendar(filter: 'live');
for (final m in cal.matches) {
  print('${formatLine(m)} ${m.url}');
}
```

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs
