using System.Text.Json;
using FutbolLibreHoy;
using Xunit;

public class CalendarClientTests
{
    [Fact]
    public void FormatParity()
    {
        var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
        var sample = File.ReadAllText(Path.Combine(root, "data", "sample-calendar.json"));
        var vectorsJson = File.ReadAllText(Path.Combine(root, "fixtures", "vectors.json"));
        using var vectors = JsonDocument.Parse(vectorsJson);
        var cal = CalendarClient.ParseCalendar(sample);

        foreach (var v in vectors.RootElement.GetProperty("formatLines").EnumerateArray())
        {
            var id = v.GetProperty("id").GetInt32();
            var match = cal.Matches.First(m => m.Id == id);
            Assert.Equal(v.GetProperty("score").GetString(), CalendarClient.FormatScore(match));
            Assert.Equal(v.GetProperty("line").GetString(), CalendarClient.FormatLine(match));
            Assert.Equal(v.GetProperty("live").GetBoolean(), CalendarClient.IsLive(match));
        }
    }

    [Fact]
    public void Filters()
    {
        var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
        var sample = File.ReadAllText(Path.Combine(root, "data", "sample-calendar.json"));
        var cal = CalendarClient.ParseCalendar(sample);
        Assert.Single(CalendarClient.FilterMatches(cal.Matches, "live"));
        Assert.Single(CalendarClient.FilterMatches(cal.Matches, "upcoming"));
        Assert.Single(CalendarClient.FilterMatches(cal.Matches, "finished"));
        Assert.Equal(3, CalendarClient.FilterMatches(cal.Matches, "all").Count);
    }
}
