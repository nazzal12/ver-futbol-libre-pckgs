import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { formatLine, formatScore, isLive, parseCalendar } from '../js/src/index.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const sample = parseCalendar(readFileSync(join(root, 'data/sample-calendar.json'), 'utf8'));

const vectors = {
  generatedBy: 'futbol-libre-hoy/js',
  formatLines: sample.matches.map((m) => ({
    id: m.id,
    score: formatScore(m),
    line: formatLine(m),
    live: isLive(m),
  })),
  filters: {
    live: sample.matches.filter((m) => m.status === 'live').map((m) => m.id),
    upcoming: sample.matches.filter((m) => m.status === 'before').map((m) => m.id),
    finished: sample.matches.filter((m) => m.status === 'after').map((m) => m.id),
  },
  groups: [
    { slug: 'copa-demo', ids: [1001, 1002] },
    { slug: 'liga-ejemplo', ids: [1003] },
  ],
};

writeFileSync(join(root, 'fixtures/vectors.json'), JSON.stringify(vectors, null, 2) + '\n');
console.log('Wrote fixtures/vectors.json');
