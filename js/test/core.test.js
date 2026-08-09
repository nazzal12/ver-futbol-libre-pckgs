import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import assert from 'node:assert/strict';
import {
  filterMatches,
  formatLine,
  formatScore,
  groupByTournament,
  isLive,
  parseCalendar,
} from '../src/index.js';

const root = join(dirname(fileURLToPath(import.meta.url)), '../..');
const sample = parseCalendar(readFileSync(join(root, 'data/sample-calendar.json'), 'utf8'));
const vectors = JSON.parse(readFileSync(join(root, 'fixtures/vectors.json'), 'utf8'));

test('parseCalendar loads sample', () => {
  assert.equal(sample.source, 'Futbol Libre');
  assert.equal(sample.matches.length, 3);
});

test('formatScore / formatLine / isLive parity', () => {
  for (const v of vectors.formatLines) {
    const match = sample.matches.find((m) => m.id === v.id);
    assert.ok(match, `missing match ${v.id}`);
    assert.equal(formatScore(match), v.score);
    assert.equal(formatLine(match), v.line);
    assert.equal(isLive(match), v.live);
  }
});

test('filterMatches', () => {
  assert.equal(filterMatches(sample.matches, 'live').length, 1);
  assert.equal(filterMatches(sample.matches, 'upcoming').length, 1);
  assert.equal(filterMatches(sample.matches, 'finished').length, 1);
  assert.equal(filterMatches(sample.matches, 'all').length, 3);
});

test('groupByTournament order', () => {
  const groups = groupByTournament(sample.matches);
  assert.equal(groups.length, 2);
  assert.equal(groups[0].tournament.slug, 'copa-demo');
  assert.equal(groups[0].matches.length, 2);
  assert.equal(groups[1].tournament.slug, 'liga-ejemplo');
});
