# Futbol Libre Hoy (agent skill)

Portable `SKILL.md` for listing today's fixtures via the published `futbol-libre-hoy` packages.

Homepage: https://verfutbollibre.net

## Files

| File | Role |
| --- | --- |
| `SKILL.md` | Skill instructions + YAML front matter |
| `LICENSE` | MIT |
| `DISCLAIMER.md` | Data/use disclaimer |

## Publish to ClawHub

```bash
npm i -g clawhub
```

```bash
clawhub login
```

```bash
cd /path/to/packages
clawhub skill publish ./skill --slug futbol-libre-hoy --name "Futbol Libre Hoy" --version 1.0.0
```

## Publish to Smithery

1. Open https://smithery.ai (sign in with GitHub).
2. Create / import a skill pointing at this repo folder: `skill/`
3. Set homepage to https://verfutbollibre.net

## Source

https://github.com/nazzal12/ver-futbol-libre-pckgs
