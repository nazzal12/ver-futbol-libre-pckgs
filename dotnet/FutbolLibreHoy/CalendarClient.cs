using System.Text.Json;

namespace FutbolLibreHoy;

public static class CalendarClient
{
    public const string DefaultBaseUrl = "https://verfutbollibre.net";
    public const string CalendarPath = "/api/v1/calendar";

    public static Team AsTeam(JsonElement el, string fallback)
    {
        if (el.ValueKind != JsonValueKind.Object)
        {
            return new Team(0, fallback, "");
        }

        return new Team(
            el.TryGetProperty("id", out var id) && id.TryGetInt64(out var iid) ? (int)iid : 0,
            el.TryGetProperty("name", out var name) && name.ValueKind == JsonValueKind.String
                ? name.GetString() ?? fallback
                : fallback,
            el.TryGetProperty("slug", out var slug) && slug.ValueKind == JsonValueKind.String
                ? slug.GetString() ?? ""
                : ""
        );
    }

    public static Match NormalizeMatch(JsonElement el)
    {
        (int, int)? score = null;
        if (el.TryGetProperty("score", out var scoreEl) && scoreEl.ValueKind == JsonValueKind.Array && scoreEl.GetArrayLength() >= 2)
        {
            if (scoreEl[0].TryGetInt32(out var h) && scoreEl[1].TryGetInt32(out var a))
            {
                score = (h, a);
            }
        }

        int? minute = null;
        if (el.TryGetProperty("minute", out var minuteEl) && minuteEl.ValueKind == JsonValueKind.Number && minuteEl.TryGetInt32(out var m))
        {
            minute = m;
        }

        return new Match(
            el.TryGetProperty("id", out var id) && id.TryGetInt64(out var iid) ? (int)iid : 0,
            el.TryGetProperty("status", out var status) && status.ValueKind == JsonValueKind.String ? status.GetString() ?? "" : "",
            el.TryGetProperty("kickoff_at", out var kick) && kick.ValueKind == JsonValueKind.String ? kick.GetString() ?? "" : "",
            AsTeam(el.TryGetProperty("home", out var home) ? home : default, "Home"),
            AsTeam(el.TryGetProperty("away", out var away) ? away : default, "Away"),
            score,
            minute,
            AsTeam(el.TryGetProperty("tournament", out var tourney) ? tourney : default, "Tournament"),
            el.TryGetProperty("url", out var url) && url.ValueKind == JsonValueKind.String
                ? url.GetString() ?? DefaultBaseUrl
                : DefaultBaseUrl
        );
    }

    public static Calendar ParseCalendar(string json)
    {
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;
        var matches = new List<Match>();
        if (root.TryGetProperty("matches", out var arr) && arr.ValueKind == JsonValueKind.Array)
        {
            foreach (var item in arr.EnumerateArray())
            {
                matches.Add(NormalizeMatch(item));
            }
        }

        var count = root.TryGetProperty("count", out var countEl) && countEl.TryGetInt32(out var c)
            ? c
            : matches.Count;

        return new Calendar(
            root.TryGetProperty("source", out var source) && source.ValueKind == JsonValueKind.String
                ? source.GetString() ?? "Futbol Libre"
                : "Futbol Libre",
            root.TryGetProperty("homepage", out var homepage) && homepage.ValueKind == JsonValueKind.String
                ? homepage.GetString() ?? DefaultBaseUrl
                : DefaultBaseUrl,
            root.TryGetProperty("date", out var date) && date.ValueKind == JsonValueKind.String
                ? date.GetString() ?? ""
                : "",
            root.TryGetProperty("filter", out var filter) && filter.ValueKind == JsonValueKind.String
                ? filter.GetString() ?? "all"
                : "all",
            count,
            matches
        );
    }

    public static string FormatScore(Match match) =>
        match.Score is { } s ? $"{s.Item1}-{s.Item2}" : "vs";

    public static bool IsLive(Match match) => match.Status == "live";

    public static string FormatLine(Match match)
    {
        var score = FormatScore(match);
        var pair = $"{match.Home.Name} {score} {match.Away.Name}";
        if (match.Status == "live")
        {
            if (match.Minute is int minute)
            {
                return $"{minute}' {pair}";
            }

            return $"LIVE {pair}";
        }

        if (match.Status == "before")
        {
            return $"{match.Home.Name} vs {match.Away.Name}";
        }

        return pair;
    }

    public static IReadOnlyList<Match> FilterMatches(IEnumerable<Match> matches, string filter)
    {
        return filter.ToLowerInvariant() switch
        {
            "live" => matches.Where(m => m.Status == "live").ToList(),
            "upcoming" => matches.Where(m => m.Status == "before").ToList(),
            "finished" => matches.Where(m => m.Status == "after").ToList(),
            _ => matches.ToList(),
        };
    }

    public static async Task<Calendar> FetchCalendarAsync(
        string? date = null,
        string? filter = null,
        string baseUrl = DefaultBaseUrl,
        HttpClient? http = null,
        CancellationToken cancellationToken = default)
    {
        var ownClient = http is null;
        http ??= new HttpClient();
        try
        {
            var qs = new List<string>();
            if (!string.IsNullOrWhiteSpace(date))
            {
                qs.Add($"date={Uri.EscapeDataString(date)}");
            }

            if (!string.IsNullOrWhiteSpace(filter) && !string.Equals(filter, "all", StringComparison.OrdinalIgnoreCase))
            {
                qs.Add($"filter={Uri.EscapeDataString(filter)}");
            }

            var url = $"{baseUrl.TrimEnd('/')}{CalendarPath}";
            if (qs.Count > 0)
            {
                url += "?" + string.Join("&", qs);
            }

            using var req = new HttpRequestMessage(HttpMethod.Get, url);
            req.Headers.Accept.ParseAdd("application/json");
            req.Headers.AcceptLanguage.ParseAdd("es-ES");
            using var res = await http.SendAsync(req, cancellationToken).ConfigureAwait(false);
            res.EnsureSuccessStatusCode();
            var body = await res.Content.ReadAsStringAsync(cancellationToken).ConfigureAwait(false);
            return ParseCalendar(body);
        }
        finally
        {
            if (ownClient)
            {
                http.Dispose();
            }
        }
    }
}

public sealed record Team(int Id, string Name, string Slug);

public sealed record Match(
    int Id,
    string Status,
    string KickoffAt,
    Team Home,
    Team Away,
    (int, int)? Score,
    int? Minute,
    Team Tournament,
    string Url);

public sealed record Calendar(
    string Source,
    string Homepage,
    string Date,
    string Filter,
    int Count,
    IReadOnlyList<Match> Matches);
