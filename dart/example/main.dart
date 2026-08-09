import 'package:futbol_libre_hoy/futbol_libre_hoy.dart';

Future<void> main() async {
  final cal = await fetchCalendar(filter: 'live');
  print('Futbol Libre Hoy - ${cal.count} live');
  for (final m in cal.matches) {
    print('${formatLine(m)} ${m.url}');
  }
  print(defaultBaseUrl);
}
