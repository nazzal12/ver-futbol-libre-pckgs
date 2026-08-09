import 'dart:convert';
import 'dart:io';
import 'package:futbol_libre_hoy/futbol_libre_hoy.dart';
import 'package:test/test.dart';

void main() {
  final root = Directory.current.path.endsWith('dart')
      ? Directory('..')
      : Directory('.');
  final sample = parseCalendar(
    File('${root.path}/data/sample-calendar.json').readAsStringSync(),
  );
  final vectors = jsonDecode(
    File('${root.path}/fixtures/vectors.json').readAsStringSync(),
  ) as Map;

  test('format parity', () {
    final byId = {for (final m in sample.matches) m.id: m};
    for (final v in vectors['formatLines'] as List) {
      final m = byId[v['id'] as int]!;
      expect(formatScore(m), v['score']);
      expect(formatLine(m), v['line']);
      expect(isLive(m), v['live']);
    }
  });

  test('filters', () {
    expect(filterMatches(sample.matches, 'live').length, 1);
    expect(filterMatches(sample.matches, 'upcoming').length, 1);
    expect(filterMatches(sample.matches, 'finished').length, 1);
  });
}
