#!/usr/bin/env node
import {
  DEFAULT_BASE_URL,
  fetchCalendar,
  filterMatches,
  formatLine,
  groupByTournament,
  parseCalendar,
} from '../src/index.js';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

function usage() {
  console.log(`Futbol Libre Hoy - partidos de hoy y en vivo

Usage:
  futbol-libre-hoy [--live|--upcoming|--finished] [--date YYYY-MM-DD] [--json] [--sample]

Examples:
  npx futbol-libre-hoy
  npx futbol-libre-hoy --live
  npx futbol-libre-hoy --date 2026-08-09

Full site: ${DEFAULT_BASE_URL}
`);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.includes('-h') || args.includes('--help')) {
    usage();
    return;
  }

  let filter = 'all';
  let date;
  let asJson = false;
  let sample = false;

  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--live') filter = 'live';
    else if (a === '--upcoming') filter = 'upcoming';
    else if (a === '--finished') filter = 'finished';
    else if (a === '--json') asJson = true;
    else if (a === '--sample') sample = true;
    else if (a === '--date') date = args[++i];
  }

  let calendar;
  if (sample) {
    const here = dirname(fileURLToPath(import.meta.url));
    const samplePath = join(here, '../../data/sample-calendar.json');
    calendar = parseCalendar(readFileSync(samplePath, 'utf8'));
  } else {
    calendar = await fetchCalendar({ date, filter });
  }

  const matches = filterMatches(calendar.matches, filter);
  if (asJson) {
    console.log(JSON.stringify({ ...calendar, filter, count: matches.length, matches }, null, 2));
    return;
  }

  console.log(`Futbol Libre Hoy - ${calendar.date || 'hoy'} (${matches.length})`);
  console.log(`${calendar.homepage || DEFAULT_BASE_URL}\n`);

  if (!matches.length) {
    console.log('No hay partidos para este filtro.');
    console.log(`Ver agenda completa: ${DEFAULT_BASE_URL}`);
    return;
  }

  for (const group of groupByTournament(matches)) {
    console.log(`## ${group.tournament.name}`);
    for (const m of group.matches) {
      console.log(`- ${formatLine(m)}`);
      console.log(`  ${m.url}`);
    }
    console.log('');
  }

  console.log(`Más en Futbol Libre: ${DEFAULT_BASE_URL}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
