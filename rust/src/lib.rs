use serde::{Deserialize, Serialize};
use serde_json::Value;

pub const DEFAULT_BASE_URL: &str = "https://verfutbollibre.net";
pub const CALENDAR_PATH: &str = "/api/v1/calendar";

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Team {
    pub id: i64,
    pub name: String,
    pub slug: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Match {
    pub id: i64,
    pub status: String,
    pub kickoff_at: String,
    pub home: Team,
    pub away: Team,
    pub score: Option<(i64, i64)>,
    pub minute: Option<i64>,
    pub tournament: Team,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Calendar {
    pub source: String,
    pub homepage: String,
    pub date: String,
    pub filter: String,
    pub count: usize,
    pub matches: Vec<Match>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TournamentGroup {
    pub tournament: Team,
    pub matches: Vec<Match>,
}

fn as_team(v: &Value, fallback: &str) -> Team {
    Team {
        id: v.get("id").and_then(|x| x.as_i64()).unwrap_or(0),
        name: v
            .get("name")
            .and_then(|x| x.as_str())
            .unwrap_or(fallback)
            .to_string(),
        slug: v
            .get("slug")
            .and_then(|x| x.as_str())
            .unwrap_or("")
            .to_string(),
    }
}

pub fn normalize_match(v: &Value) -> Match {
    let score = v.get("score").and_then(|s| {
        let arr = s.as_array()?;
        if arr.len() < 2 {
            return None;
        }
        Some((arr[0].as_i64()?, arr[1].as_i64()?))
    });
    Match {
        id: v.get("id").and_then(|x| x.as_i64()).unwrap_or(0),
        status: v
            .get("status")
            .and_then(|x| x.as_str())
            .unwrap_or("")
            .to_string(),
        kickoff_at: v
            .get("kickoff_at")
            .and_then(|x| x.as_str())
            .unwrap_or("")
            .to_string(),
        home: as_team(v.get("home").unwrap_or(&Value::Null), "Home"),
        away: as_team(v.get("away").unwrap_or(&Value::Null), "Away"),
        score,
        minute: v.get("minute").and_then(|x| x.as_i64()),
        tournament: as_team(v.get("tournament").unwrap_or(&Value::Null), "Tournament"),
        url: v
            .get("url")
            .and_then(|x| x.as_str())
            .unwrap_or(DEFAULT_BASE_URL)
            .to_string(),
    }
}

pub fn parse_calendar(input: &str) -> Result<Calendar, serde_json::Error> {
    let v: Value = serde_json::from_str(input)?;
    let matches: Vec<Match> = v
        .get("matches")
        .and_then(|m| m.as_array())
        .map(|arr| arr.iter().map(normalize_match).collect())
        .unwrap_or_default();
    let count = v
        .get("count")
        .and_then(|c| c.as_u64())
        .map(|c| c as usize)
        .unwrap_or(matches.len());
    Ok(Calendar {
        source: v
            .get("source")
            .and_then(|x| x.as_str())
            .unwrap_or("Futbol Libre")
            .to_string(),
        homepage: v
            .get("homepage")
            .and_then(|x| x.as_str())
            .unwrap_or(DEFAULT_BASE_URL)
            .to_string(),
        date: v
            .get("date")
            .and_then(|x| x.as_str())
            .unwrap_or("")
            .to_string(),
        filter: v
            .get("filter")
            .and_then(|x| x.as_str())
            .unwrap_or("all")
            .to_string(),
        count,
        matches,
    })
}

pub fn format_score(m: &Match) -> String {
    match m.score {
        Some((h, a)) => format!("{h}-{a}"),
        None => "vs".to_string(),
    }
}

pub fn is_live(m: &Match) -> bool {
    m.status == "live"
}

pub fn format_line(m: &Match) -> String {
    let score = format_score(m);
    let pair = format!("{} {} {}", m.home.name, score, m.away.name);
    if m.status == "live" {
        if let Some(min) = m.minute {
            return format!("{min}' {pair}");
        }
        return format!("LIVE {pair}");
    }
    if m.status == "before" {
        return format!("{} vs {}", m.home.name, m.away.name);
    }
    pair
}

pub fn filter_matches(matches: &[Match], filter: &str) -> Vec<Match> {
    match filter.to_lowercase().as_str() {
        "live" => matches.iter().filter(|m| m.status == "live").cloned().collect(),
        "upcoming" => matches
            .iter()
            .filter(|m| m.status == "before")
            .cloned()
            .collect(),
        "finished" => matches
            .iter()
            .filter(|m| m.status == "after")
            .cloned()
            .collect(),
        _ => matches.to_vec(),
    }
}

pub fn group_by_tournament(matches: &[Match]) -> Vec<TournamentGroup> {
    let mut order = Vec::new();
    let mut map: std::collections::HashMap<i64, TournamentGroup> = std::collections::HashMap::new();
    for m in matches {
        let id = m.tournament.id;
        if !map.contains_key(&id) {
            order.push(id);
            map.insert(
                id,
                TournamentGroup {
                    tournament: m.tournament.clone(),
                    matches: Vec::new(),
                },
            );
        }
        map.get_mut(&id).unwrap().matches.push(m.clone());
    }
    order.into_iter().filter_map(|id| map.remove(&id)).collect()
}

pub fn fetch_calendar(
    base_url: &str,
    date: Option<&str>,
    filter: Option<&str>,
) -> Result<Calendar, Box<dyn std::error::Error>> {
    let mut url = format!("{}{}", base_url.trim_end_matches('/'), CALENDAR_PATH);
    let mut q = Vec::new();
    if let Some(d) = date {
        q.push(format!("date={d}"));
    }
    if let Some(f) = filter {
        if f != "all" {
            q.push(format!("filter={f}"));
        }
    }
    if !q.is_empty() {
        url.push('?');
        url.push_str(&q.join("&"));
    }
    let body = ureq::get(&url)
        .set("Accept", "application/json")
        .set("Accept-Language", "es-ES")
        .call()?
        .into_string()?;
    Ok(parse_calendar(&body)?)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn format_parity() {
        let sample = fs::read_to_string("../data/sample-calendar.json").unwrap();
        let vectors: Value = serde_json::from_str(
            &fs::read_to_string("../fixtures/vectors.json").unwrap(),
        )
        .unwrap();
        let cal = parse_calendar(&sample).unwrap();
        for v in vectors["formatLines"].as_array().unwrap() {
            let id = v["id"].as_i64().unwrap();
            let m = cal.matches.iter().find(|m| m.id == id).unwrap();
            assert_eq!(format_score(m), v["score"].as_str().unwrap());
            assert_eq!(format_line(m), v["line"].as_str().unwrap());
            assert_eq!(is_live(m), v["live"].as_bool().unwrap());
        }
    }
}
