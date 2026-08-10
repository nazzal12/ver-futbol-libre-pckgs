# Publishing - Futbol Libre Hoy

Public repo root = this `packages/` tree.  
Homepage / backlink target: **https://verfutbollibre.net**

Anchor style: see [ANCHORS.md](./ANCHORS.md) - one keyword **or** naked URL per link, never a keyword pile.

## Environment

- **Windows:** npm, Python, Dart, Docker Hub UI steps.
- **WSL Ubuntu (`wsl -d Ubuntu`):** prefer for **cargo**, **snapcraft**, **CocoaPods (`pod`)**, Ruby/PHP if installed there.

```powershell
wsl -d Ubuntu
cd /mnt/c/Users/nazza/Desktop/futbol_libre/packages
```

## Preflight (every time)

```bash
node scripts/vendor-data.mjs
node scripts/gen-fixtures.mjs
node scripts/check-no-leak.mjs
node --test js/test/*.test.js
```

## 1) npm (do this first)

From PowerShell or WSL:

```bash
cd js
npm login
npm whoami
npm publish --access public
```

Live: https://www.npmjs.com/package/futbol-libre-hoy

## 2) PyPI

```bash
cd python
python3 -m build   # or: python -m build
python3 -m twine upload dist/*
```

## 3) crates.io (WSL recommended)

```bash
cd rust
cargo login <token>
cargo test
cargo publish
```

## 4) RubyGems (WSL if Ruby is there)

```bash
cd ruby
gem build futbol-libre-hoy.gemspec
GEM_HOST_API_KEY=<key> gem push futbol-libre-hoy-1.0.0.gem
```

## 5) Packagist

1. Submit https://github.com/nazzal12/ver-futbol-libre-pckgs  
2. Enable GitHub webhook  
3. `git tag v1.0.0 && git push origin v1.0.0`

## 6) pub.dev

```bash
cd dart
dart pub publish --dry-run
dart pub publish
```

## 7) Docker Hub

From packages root (needs Docker Desktop / daemon):

```bash
docker build -f docker/Dockerfile -t iamnazzal/futbol-libre-hoy .
docker login
docker push iamnazzal/futbol-libre-hoy:1.0.0
docker push iamnazzal/futbol-libre-hoy:latest
```

Set Docker Hub description + website to https://verfutbollibre.net

## 8) Snap Store (GitHub Actions)

Preferred path: `.github/workflows/snap.yml` builds with `snapcore/action-build` and publishes with `snapcore/action-publish`.

One-time setup in WSL:

```bash
wsl -d Ubuntu
mkdir -p /tmp/xdg-run
export XDG_RUNTIME_DIR=/tmp/xdg-run
snapcraft login
snapcraft register futbol-libre-hoy
snapcraft export-login \
  --snaps=futbol-libre-hoy \
  --acls package_access,package_push,package_release,package_update \
  /tmp/snap-creds.txt
```

Add GitHub Actions secret **`SNAPCRAFT_STORE_CREDENTIALS`** = full contents of `/tmp/snap-creds.txt`.  
Do **not** commit that file.

Publish:

- Actions → **snap** → **Run workflow** (choose channel), or
- `git tag snap-v1.0.0 && git push origin snap-v1.0.0` (channel: stable)

`snapcraft.yaml` lives at `snap/snapcraft.yaml` with `source: js` (repo root = project root).

## 9) CocoaPods (GitHub Actions / macOS)

Package: `FutbolLibreHoy.podspec` (repo root)  
Sources: `cocoapods/Sources/FutbolLibreHoy/**/*.swift`  
Workflow: `.github/workflows/cocoapods.yml` (macOS; `pod lib lint` + `pod trunk push`)

One-time trunk registration:

```bash
pod trunk register nazzal5448@gmail.com "NBK Devs" --description="Futbol Libre Hoy"
```

Confirm the email, then put the trunk token from `~/.netrc` into GitHub secret **`COCOAPODS_TRUNK_TOKEN`**.

Publish (retag after fixes if `cocoapods-1.0.0` already exists):

```bash
git tag -d cocoapods-1.0.0
git push origin :refs/tags/cocoapods-1.0.0
git tag cocoapods-1.0.0
git push origin cocoapods-1.0.0
```

Or: Actions → **cocoapods** → **Run workflow**.

Do **not** use a plain `v*` tag here (that also triggers Snap).

## 10) Hugging Face Space

Contents: `huggingface/` (`README.md` with `sdk: static`, `index.html`).

Create a **Static** Space, then push files into it:

```bash
pip install -U huggingface_hub
huggingface-cli login
```

```bash
git clone https://huggingface.co/spaces/YOUR_USER/futbol-libre-hoy hf-space
cd hf-space
copy ..\packages\huggingface\* .
git add -A
git commit -m "Futbol Libre Hoy static space"
git push
```

Set Space metadata homepage / about link to https://verfutbollibre.net  
Expected URL: `https://huggingface.co/spaces/YOUR_USER/futbol-libre-hoy`

Note: `/api/v1/calendar` must send CORS (`Access-Control-Allow-Origin`) for the browser demo to load.

## 11) Smithery / ClawHub

Point marketplace at `skill/` (`SKILL.md`). Homepage = https://verfutbollibre.net

## 12) Context7

Register `https://verfutbollibre.net/llms.txt` with title **Futbol Libre**.

## Tracking

| Platform | Status | Live URL | Links to site? |
| --- | --- | --- | --- |
| npm | ready | | yes |
| PyPI | ready | | yes |
| crates.io | ready | | yes |
| RubyGems | ready | | yes |
| Packagist | ready | | yes |
| pub.dev | ready | | yes |
| Docker Hub | ready | | yes |
| HuggingFace | ready | | yes |
| Smithery | ready | | yes |
| Context7 | ready | | yes |
| GitHub | pending push | https://github.com/nazzal12/ver-futbol-libre-pckgs | yes |
