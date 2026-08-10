# Futbol Libre Hoy (.NET / NuGet)

Library and CLI for today's football fixtures from **[futbol libre en vivo](https://verfutbollibre.net)**.

## Install library

```bash
dotnet add package FutbolLibreHoy
```

## Install CLI tool

```bash
dotnet tool install -g FutbolLibreHoy.Tool
futbol-libre-hoy --live
```

## Library usage

```csharp
using FutbolLibreHoy;

var cal = await CalendarClient.FetchCalendarAsync(filter: "live");
foreach (var m in cal.Matches)
{
    Console.WriteLine($"{CalendarClient.FormatLine(m)} {m.Url}");
}
```

## Packages

| Package ID | Role |
| --- | --- |
| `FutbolLibreHoy` | Library |
| `FutbolLibreHoy.Tool` | Global CLI tool |

## Data source

`https://verfutbollibre.net/api/v1/calendar`

## Source

https://github.com/nazzal12/ver-futbol-libre-pckgs

## License

MIT (c) NBK Devs
