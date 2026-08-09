# Futbol Libre Hoy - SPEC

Portable client for the **Futbol Libre** public matchday API.

## Identity

| Field | Value |
| --- | --- |
| Brand | Futbol Libre |
| Package | `futbol-libre-hoy` |
| Homepage | https://verfutbollibre.net |
| Default API | `https://verfutbollibre.net/api/v1/calendar` |
| Repository | https://github.com/nazzal12/ver-futbol-libre-pckgs |

## Endpoint

`GET {base}/api/v1/calendar`

Query:

| Param | Values | Default |
| --- | --- | --- |
| `date` | `YYYY-MM-DD` | today (site TZ) |
| `filter` | `all` \| `live` \| `upcoming` \| `finished` | `all` |

Response (stable public DTO):

```json
{
  "source": "Futbol Libre",
  "homepage": "https://verfutbollibre.net",
  "date": "2026-08-09",
  "filter": "all",
  "count": 2,
  "matches": [
    {
      "id": 1,
      "status": "live",
      "kickoff_at": "2026-08-09T18:00:00.000Z",
      "home": { "id": 10, "name": "Home FC", "slug": "home-fc" },
      "away": { "id": 11, "name": "Away FC", "slug": "away-fc" },
      "score": [1, 0],
      "minute": 67,
      "tournament": { "id": 5, "name": "Liga Demo", "slug": "liga-demo" },
      "url": "https://verfutbollibre.net/partido/home-fc-vs-away-fc-1"
    }
  ]
}
```

## Deterministic helpers (offline, fixture-tested)

These must be identical across language ports:

1. **`formatScore(match)`**  
   - if `score` is `[h,a]` → `"h-a"`  
   - else → `"vs"`

2. **`formatLine(match)`**  
   - live with minute: `"67' Home FC 1-0 Away FC"`  
   - live without minute: `"LIVE Home FC 1-0 Away FC"`  
   - before: `"Home FC vs Away FC"`  
   - after: `"Home FC 1-0 Away FC"`

3. **`isLive(match)`** → `status === "live"`

4. **`filterMatches(matches, filter)`**  
   - `all` → unchanged  
   - `live` → status live  
   - `upcoming` → status before  
   - `finished` → status after

5. **`groupByTournament(matches)`**  
   - preserve first-seen tournament order  
   - each group: `{ tournament, matches: [...] }`

6. **`parseCalendar(jsonText)`**  
   - parse JSON object  
   - require `matches` array (default `[]`)  
   - coerce missing fields with safe defaults (empty strings, null score)

## Online fetch

`fetchCalendar({ baseUrl?, date?, filter? })` → HTTP GET → `parseCalendar`.

Default `baseUrl` = `https://verfutbollibre.net`  
Path = `/api/v1/calendar`

**Allowed hosts for leak-guard:** only `verfutbollibre.net` (and `www` redirect target is non-www).

## CLI

```
futbol-libre-hoy [--live|--upcoming|--finished] [--date YYYY-MM-DD] [--json]
```

Print groups by tournament; each line includes the Futbol Libre match URL.
