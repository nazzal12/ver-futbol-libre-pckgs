library;

import 'dart:convert';
import 'dart:io';

export 'sample_calendar.dart';

const String defaultBaseUrl = 'https://verfutbollibre.net';
const String calendarPath = '/api/v1/calendar';

class Team {
  final int id;
  final String name;
  final String slug;
  const Team({required this.id, required this.name, required this.slug});
}

class Match {
  final int id;
  final String status;
  final String kickoffAt;
  final Team home;
  final Team away;
  final List<int>? score;
  final int? minute;
  final Team tournament;
  final String url;
  const Match({
    required this.id,
    required this.status,
    required this.kickoffAt,
    required this.home,
    required this.away,
    required this.score,
    required this.minute,
    required this.tournament,
    required this.url,
  });
}

class Calendar {
  final String source;
  final String homepage;
  final String date;
  final String filter;
  final int count;
  final List<Match> matches;
  const Calendar({
    required this.source,
    required this.homepage,
    required this.date,
    required this.filter,
    required this.count,
    required this.matches,
  });
}

Team _team(dynamic raw, String fallback) {
  final o = raw is Map ? raw : const {};
  return Team(
    id: (o['id'] as num?)?.toInt() ?? 0,
    name: '${o['name'] ?? fallback}',
    slug: '${o['slug'] ?? ''}',
  );
}

Match normalizeMatch(dynamic raw) {
  final o = raw is Map ? raw : const {};
  List<int>? score;
  final s = o['score'];
  if (s is List && s.length >= 2) {
    score = [(s[0] as num).toInt(), (s[1] as num).toInt()];
  }
  return Match(
    id: (o['id'] as num?)?.toInt() ?? 0,
    status: '${o['status'] ?? ''}',
    kickoffAt: '${o['kickoff_at'] ?? ''}',
    home: _team(o['home'], 'Home'),
    away: _team(o['away'], 'Away'),
    score: score,
    minute: o['minute'] == null ? null : (o['minute'] as num).toInt(),
    tournament: _team(o['tournament'], 'Tournament'),
    url: '${o['url'] ?? defaultBaseUrl}',
  );
}

Calendar parseCalendar(dynamic input) {
  final data = input is String ? jsonDecode(input) : input;
  final o = data is Map ? data : const {};
  final list = (o['matches'] as List?) ?? const [];
  final matches = list.map(normalizeMatch).toList();
  return Calendar(
    source: '${o['source'] ?? 'Futbol Libre'}',
    homepage: '${o['homepage'] ?? defaultBaseUrl}',
    date: '${o['date'] ?? ''}',
    filter: '${o['filter'] ?? 'all'}',
    count: (o['count'] as num?)?.toInt() ?? matches.length,
    matches: matches,
  );
}

String formatScore(Match m) =>
    m.score != null ? '${m.score![0]}-${m.score![1]}' : 'vs';

bool isLive(Match m) => m.status == 'live';

String formatLine(Match m) {
  final score = formatScore(m);
  final pair = '${m.home.name} $score ${m.away.name}';
  if (m.status == 'live') {
    if (m.minute != null) return "${m.minute}' $pair";
    return 'LIVE $pair';
  }
  if (m.status == 'before') return '${m.home.name} vs ${m.away.name}';
  return pair;
}

List<Match> filterMatches(List<Match> matches, String filter) {
  final f = filter.toLowerCase();
  if (f == 'live') return matches.where((m) => m.status == 'live').toList();
  if (f == 'upcoming') return matches.where((m) => m.status == 'before').toList();
  if (f == 'finished') return matches.where((m) => m.status == 'after').toList();
  return List.of(matches);
}

Future<Calendar> fetchCalendar({
  String baseUrl = defaultBaseUrl,
  String? date,
  String? filter,
}) async {
  final params = <String, String>{};
  if (date != null) params['date'] = date;
  if (filter != null && filter != 'all') params['filter'] = filter;
  final uri = Uri.parse('$baseUrl$calendarPath').replace(queryParameters: params.isEmpty ? null : params);
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.acceptLanguageHeader, 'es-ES');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Futbol Libre calendar HTTP ${res.statusCode}');
    }
    return parseCalendar(body);
  } finally {
    client.close(force: true);
  }
}
