# Futbol Libre packages

Open-source clients, apps, and tools that work with **[Futbol Libre](https://verfutbollibre.net)** matchday data.

The public calendar feed lives at `https://verfutbollibre.net/api/v1/calendar`. Most packages in this repo are thin clients for that feed.

## Mobile apps

Install **Futbol Libre +** from [Google Play](https://play.google.com/store/apps/details?id=com.nbk.futbollibre).

The same Android listing is published on Amazon Appstore. Primary storefront:

- [Amazon.com](https://www.amazon.com/gp/product/B0GMPJRPKN)

Other Amazon regions (same product):
[UK](https://www.amazon.co.uk/gp/product/B0GMPJRPKN) ·
[Germany](https://www.amazon.de/gp/product/B0GMPJRPKN) ·
[Italy](https://www.amazon.it/gp/product/B0GMPJRPKN) ·
[France](https://www.amazon.fr/gp/product/B0GMPJRPKN) ·
[Spain](https://www.amazon.es/gp/product/B0GMPJRPKN) ·
[Japan](https://www.amazon.co.jp/gp/product/B0GMPJRPKN) ·
[Canada](https://www.amazon.ca/gp/product/B0GMPJRPKN) ·
[Brazil](https://www.amazon.com.br/gp/product/B0GMPJRPKN) ·
[Mexico](https://www.amazon.com.mx/gp/product/B0GMPJRPKN) ·
[Australia](https://www.amazon.com.au/gp/product/B0GMPJRPKN)

## Browser extensions

Quick matchday access from the toolbar as **Futbol Agenda**:

- [Chrome Web Store](https://chromewebstore.google.com/detail/futbol-agenda/ngppcnhcmhhalgpamllmofocimihgegh)
- [Firefox Add-ons](https://addons.mozilla.org/en-US/firefox/addon/futbol-agenda/)
- [Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons/detail/futbol-agenda/mkaalekaepnmhpcgdblglochklnlhagj)

## Developer packages (Futbol Libre Hoy)

Shared library and CLI ports for today's fixtures. Quick start:

```bash
npx futbol-libre-hoy --live
```

| Ecosystem | Package | Source |
| --- | --- | --- |
| [npm](https://www.npmjs.com/package/futbol-libre-hoy) | `futbol-libre-hoy` | [`js/`](./js) |
| [PyPI](https://pypi.org/project/futbol-libre-hoy/) | `futbol-libre-hoy` | [`python/`](./python) |
| [crates.io](https://crates.io/crates/futbol-libre-hoy) | `futbol-libre-hoy` | [`rust/`](./rust) |
| [RubyGems](https://rubygems.org/gems/futbol-libre-hoy) | `futbol-libre-hoy` | [`ruby/`](./ruby) |
| [Packagist](https://packagist.org/packages/nazzal12/futbol-libre-hoy) | `nazzal12/futbol-libre-hoy` | [`php/`](./php) |
| [pub.dev](https://pub.dev/packages/futbol_libre_hoy) | `futbol_libre_hoy` | [`dart/`](./dart) |
| [NuGet](https://www.nuget.org/packages/FutbolLibreHoy/) | `FutbolLibreHoy` (+ [Tool](https://www.nuget.org/packages/FutbolLibreHoy.Tool/)) | [`dotnet/`](./dotnet) |
| [CocoaPods](https://cocoapods.org/pods/FutbolLibreHoy) | `FutbolLibreHoy` | [`cocoapods/`](./cocoapods) |
| [Docker Hub](https://hub.docker.com/r/iamnazzal/futbol-libre-hoy) | `iamnazzal/futbol-libre-hoy` | [`docker/`](./docker) |
| [Snap Store](https://snapcraft.io/futbol-libre-hoy) | `futbol-libre-hoy` | [`snap/`](./snap) |

Security scan of the npm package: [Socket](https://socket.dev/npm/package/futbol-libre-hoy).

## Agents and docs tooling

| Surface | Link | In this repo |
| --- | --- | --- |
| Agent skill (Smithery) | [ver-futbol-libre-hoy](https://smithery.ai/skills/nazzal5448/ver-futbol-libre-hoy) | [`skill/`](./skill) |
| ClawHub skill | [skill](https://clawhub.ai/nazzal5448/skills/skill) | [`skill/`](./skill) |
| Hugging Face Space | [futbol-libre-hoy](https://huggingface.co/spaces/iamnazzal/futbol-libre-hoy) | [`huggingface/`](./huggingface) |
| Context7 | [site llms.txt](https://context7.com/llmstxt/verfutbollibre_net_llms_txt) | [`context7/`](./context7) |
| Arcade MCP | deploy from [`arcade/`](./arcade) | [`arcade/`](./arcade) |

## Directories and showcases

App and product directories that point back to the site:

- [Product Hunt](https://www.producthunt.com/products/futbol-libre-3)
- [DesignNominees](https://www.designnominees.com/apps/futbol-libre)
- [TheGreatApps](https://www.thegreatapps.com/apps/futbol-libre)
- [ThePopularApps](https://www.thepopularapps.com/apps/futbol-libre)
- [Automatool](https://automatool.app/tools/futbol_libre)
- [SourceForge project](https://sourceforge.net/projects/futbol-libre-en-vivo-hoy/)

## Source mirrors

This tree is mirrored on:

- GitHub: https://github.com/nazzal12/ver-futbol-libre-pckgs
- GitLab: https://gitlab.com/nazzal5448/ver-futbol-libre-pckgs

See [SPEC.md](./SPEC.md) for the shared calendar client contract and [PUBLISHING.md](./PUBLISHING.md) for registry notes.

---

Site: https://verfutbollibre.net
