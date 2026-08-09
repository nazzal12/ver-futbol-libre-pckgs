import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');

/** Forbidden patterns — private backends, secrets, unrelated hosts. */
const FORBIDDEN = [
  /football-api\.nazzalkausar12\.workers\.dev/i,
  /futbol-libre-api\.nazzalkausar12\.workers\.dev/i,
  /nazzalkausar12\.workers\.dev/i,
  /multiball\.forzafootball\.net/i,
  /api[_-]?key\s*[:=]\s*['"][^'"]+['"]/i,
  /Bearer\s+[A-Za-z0-9\-._~+/]+=*/,
  /SNAPCRAFT_STORE_CREDENTIALS\s*=\s*\S+/,
  /COCOAPODS_TRUNK_TOKEN\s*=\s*\S+/,
  /ghp_[A-Za-z0-9]{20,}/,
  /npm_[A-Za-z0-9]{20,}/,
];

const SKIP_DIR_NAMES = new Set([
  '.git',
  'node_modules',
  'target',
  'dist',
  'build',
  '.dart_tool',
  '__pycache__',
  '.pytest_cache',
  'vendor',
]);

const SKIP_FILES = new Set(['check-no-leak.mjs']);

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    if (SKIP_DIR_NAMES.has(name)) continue;
    const p = join(dir, name);
    const st = statSync(p);
    if (st.isDirectory()) {
      if (name === 'bin' && relative(root, dir).startsWith('dotnet')) continue;
      walk(p, out);
    } else if (/\.(md|js|mjs|ts|py|rs|dart|php|rb|swift|json|yml|yaml|toml|cs|txt|html)$/i.test(name)) {
      if (!SKIP_FILES.has(name)) out.push(p);
    }
  }
  return out;
}

let failed = false;
for (const file of walk(root)) {
  const text = readFileSync(file, 'utf8');
  for (const re of FORBIDDEN) {
    if (re.test(text)) {
      console.error(`LEAK: ${relative(root, file)} matches ${re}`);
      failed = true;
    }
  }
}

if (failed) {
  console.error('check-no-leak failed');
  process.exit(1);
}
console.log('check-no-leak: ok');
