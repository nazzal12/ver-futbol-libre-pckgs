using System.Text.Json;
using FutbolLibreHoy;

static void PrintHelp()
{
    Console.WriteLine("""
        Futbol Libre Hoy - partidos de hoy y en vivo

        Usage:
          futbol-libre-hoy [--live|--upcoming|--finished] [--date YYYY-MM-DD] [--json]

        Full site: https://verfutbollibre.net
        """);
}

var filter = "all";
string? date = null;
var json = false;

for (var i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--help" or "-h":
            PrintHelp();
            return 0;
        case "--live":
            filter = "live";
            break;
        case "--upcoming":
            filter = "upcoming";
            break;
        case "--finished":
            filter = "finished";
            break;
        case "--json":
            json = true;
            break;
        case "--date" when i + 1 < args.Length:
            date = args[++i];
            break;
        default:
            Console.Error.WriteLine($"Unknown argument: {args[i]}");
            PrintHelp();
            return 1;
    }
}

try
{
    var cal = await CalendarClient.FetchCalendarAsync(date, filter == "all" ? null : filter);
    var matches = CalendarClient.FilterMatches(cal.Matches, filter);
    if (json)
    {
        var payload = new
        {
            source = cal.Source,
            homepage = CalendarClient.DefaultBaseUrl,
            date = cal.Date,
            filter,
            count = matches.Count,
            matches = matches.Select(m => new
            {
                m.Id,
                m.Status,
                kickoff_at = m.KickoffAt,
                home = m.Home.Name,
                away = m.Away.Name,
                score = m.Score is { } s ? new[] { s.Item1, s.Item2 } : null,
                m.Minute,
                tournament = m.Tournament.Name,
                m.Url,
                line = CalendarClient.FormatLine(m),
            }),
        };
        Console.WriteLine(JsonSerializer.Serialize(payload, new JsonSerializerOptions { WriteIndented = true }));
        return 0;
    }

    Console.WriteLine($"Futbol Libre Hoy - {cal.Date} ({matches.Count})");
    foreach (var m in matches)
    {
        Console.WriteLine($"{CalendarClient.FormatLine(m)} {m.Url}");
    }

    return 0;
}
catch (Exception ex)
{
    Console.Error.WriteLine(ex.Message);
    Console.Error.WriteLine(CalendarClient.DefaultBaseUrl);
    return 1;
}
