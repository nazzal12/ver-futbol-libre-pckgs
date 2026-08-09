# Futbol Libre Hoy (Snap)

CLI snap for today's football fixtures and live scores from the public calendar feed at https://verfutbollibre.net.

## Install (once published)

```bash
sudo snap install futbol-libre-hoy
futbol-libre-hoy --live
```

## Publish via GitHub Actions (preferred)

Workflow: `.github/workflows/snap.yml`

1. Register the snap name once (Ubuntu SSO):

```bash
wsl -d Ubuntu
```

```bash
mkdir -p /tmp/xdg-run
export XDG_RUNTIME_DIR=/tmp/xdg-run
snapcraft login
```

```bash
snapcraft register futbol-libre-hoy
```

2. Export store credentials (do not commit the file):

```bash
snapcraft export-login \
  --snaps=futbol-libre-hoy \
  --acls package_access,package_push,package_release,package_update \
  /tmp/snap-creds.txt
```

3. In GitHub: **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `SNAPCRAFT_STORE_CREDENTIALS`
   - Value: paste the **full contents** of `/tmp/snap-creds.txt`

4. Trigger publish:
   - **Actions → snap → Run workflow** (pick channel: edge / stable / …), or
   - Push a tag: `git tag snap-v1.0.0 && git push origin snap-v1.0.0` (releases to **stable**)

## Local build (optional)

Project layout: repo root has `js/` and `snap/snapcraft.yaml` (`source: js`).

```bash
wsl -d Ubuntu
```

```bash
mkdir -p /tmp/xdg-run
export XDG_RUNTIME_DIR=/tmp/xdg-run
```

```bash
rm -rf /tmp/flh-snap
mkdir -p /tmp/flh-snap
cp -a /mnt/c/Users/nazza/Desktop/futbol_libre/packages/js /tmp/flh-snap/js
mkdir -p /tmp/flh-snap/snap
cp /mnt/c/Users/nazza/Desktop/futbol_libre/packages/snap/snapcraft.yaml /tmp/flh-snap/snap/
```

```bash
cd /tmp/flh-snap
snapcraft pack --destructive-mode
```

## Source & docs

Repository: https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
