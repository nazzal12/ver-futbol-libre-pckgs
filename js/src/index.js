/** Default Futbol Libre site origin (public calendar lives here). */
export const DEFAULT_BASE_URL = 'https://verfutbollibre.net';

export const CALENDAR_PATH = '/api/v1/calendar';

/**
 * @typedef {{ id: number, name: string, slug: string }} TeamRef
 * @typedef {{ id: number, name: string, slug: string }} TournamentRef
 * @typedef {{
 *   id: number,
 *   status: string,
 *   kickoff_at: string,
 *   home: TeamRef,
 *   away: TeamRef,
 *   score: [number, number] | null,
 *   minute: number | null,
 *   tournament: TournamentRef,
 *   url: string,
 * }} Match
 * @typedef {{
 *   source: string,
 *   homepage: string,
 *   date: string,
 *   filter: string,
 *   count: number,
 *   matches: Match[],
 * }} Calendar
 */

function asTeam(raw, fallback) {
  const o = raw && typeof raw === 'object' ? raw : {};
  return {
    id: Number(o.id) || 0,
    name: String(o.name ?? fallback),
    slug: String(o.slug ?? ''),
  };
}

/** @param {unknown} raw */
export function normalizeMatch(raw) {
  const o = raw && typeof raw === 'object' ? /** @type {Record<string, unknown>} */ (raw) : {};
  let score = null;
  if (Array.isArray(o.score) && o.score.length >= 2) {
    const h = Number(o.score[0]);
    const a = Number(o.score[1]);
    if (Number.isFinite(h) && Number.isFinite(a)) score = /** @type {[number, number]} */ ([h, a]);
  }
  return {
    id: Number(o.id) || 0,
    status: String(o.status ?? ''),
    kickoff_at: String(o.kickoff_at ?? ''),
    home: asTeam(o.home, 'Home'),
    away: asTeam(o.away, 'Away'),
    score,
    minute: o.minute == null || o.minute === '' ? null : Number(o.minute),
    tournament: asTeam(o.tournament, 'Tournament'),
    url: String(o.url ?? DEFAULT_BASE_URL),
  };
}

/** @param {string | object} input */
export function parseCalendar(input) {
  const data = typeof input === 'string' ? JSON.parse(input) : input;
  const o = data && typeof data === 'object' ? data : {};
  const matches = Array.isArray(o.matches) ? o.matches.map(normalizeMatch) : [];
  return {
    source: String(o.source ?? 'Futbol Libre'),
    homepage: String(o.homepage ?? DEFAULT_BASE_URL),
    date: String(o.date ?? ''),
    filter: String(o.filter ?? 'all'),
    count: Number.isFinite(Number(o.count)) ? Number(o.count) : matches.length,
    matches,
  };
}

/** @param {Match} match */
export function formatScore(match) {
  if (match.score && match.score.length >= 2) {
    return `${match.score[0]}-${match.score[1]}`;
  }
  return 'vs';
}

/** @param {Match} match */
export function isLive(match) {
  return match.status === 'live';
}

/** @param {Match} match */
export function formatLine(match) {
  const score = formatScore(match);
  const pair = `${match.home.name} ${score} ${match.away.name}`;
  if (match.status === 'live') {
    if (match.minute != null && Number.isFinite(match.minute)) {
      return `${match.minute}' ${pair}`;
    }
    return `LIVE ${pair}`;
  }
  if (match.status === 'before') {
    return `${match.home.name} vs ${match.away.name}`;
  }
  return pair;
}

/**
 * @param {Match[]} matches
 * @param {string} filter
 */
export function filterMatches(matches, filter) {
  const f = (filter || 'all').toLowerCase();
  if (f === 'live') return matches.filter((m) => m.status === 'live');
  if (f === 'upcoming') return matches.filter((m) => m.status === 'before');
  if (f === 'finished') return matches.filter((m) => m.status === 'after');
  return matches.slice();
}

/** @param {Match[]} matches */
export function groupByTournament(matches) {
  /** @type {Map<number, { tournament: TournamentRef, matches: Match[] }>} */
  const map = new Map();
  for (const m of matches) {
    const id = m.tournament.id;
    let g = map.get(id);
    if (!g) {
      g = { tournament: m.tournament, matches: [] };
      map.set(id, g);
    }
    g.matches.push(m);
  }
  return [...map.values()];
}

/**
 * @param {{
 *   baseUrl?: string,
 *   date?: string,
 *   filter?: string,
 *   fetchImpl?: typeof fetch,
 * }} [opts]
 */
export async function fetchCalendar(opts = {}) {
  const base = (opts.baseUrl || DEFAULT_BASE_URL).replace(/\/$/, '');
  const params = new URLSearchParams();
  if (opts.date) params.set('date', opts.date);
  if (opts.filter && opts.filter !== 'all') params.set('filter', opts.filter);
  const qs = params.toString();
  const url = `${base}${CALENDAR_PATH}${qs ? `?${qs}` : ''}`;
  const fetchImpl = opts.fetchImpl || globalThis.fetch;
  if (!fetchImpl) throw new Error('fetch is not available');
  const res = await fetchImpl(url, {
    headers: { Accept: 'application/json', 'Accept-Language': 'es-ES' },
  });
  if (!res.ok) throw new Error(`Futbol Libre calendar HTTP ${res.status}`);
  const text = await res.text();
  return parseCalendar(text);
}

export default {
  DEFAULT_BASE_URL,
  CALENDAR_PATH,
  parseCalendar,
  normalizeMatch,
  formatScore,
  formatLine,
  isLive,
  filterMatches,
  groupByTournament,
  fetchCalendar,
};
