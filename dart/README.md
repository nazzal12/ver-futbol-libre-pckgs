# Futbol Libre Hoy (Dart)

Fetch today's fixtures from **[Futbol Libre](https://verfutbollibre.net)**.

```dart
import 'package:futbol_libre_hoy/futbol_libre_hoy.dart';

final cal = await fetchCalendar(filter: 'live');
for (final m in cal.matches) {
  print('${formatLine(m)} ${m.url}');
}
```

Homepage: https://verfutbollibre.net  
Repository: https://github.com/nazzal12/ver-fubtol-libre-pckgs
