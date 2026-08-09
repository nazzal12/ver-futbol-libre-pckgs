use futbol_libre_hoy::{
    fetch_calendar, filter_matches, format_line, group_by_tournament, parse_calendar,
    DEFAULT_BASE_URL,
};
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let mut filter = "all".to_string();
    let mut date: Option<String> = None;
    let mut sample = false;
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--live" => filter = "live".into(),
            "--upcoming" => filter = "upcoming".into(),
            "--finished" => filter = "finished".into(),
            "--sample" => sample = true,
            "--date" => {
                i += 1;
                date = args.get(i).cloned();
            }
            "-h" | "--help" => {
                println!("Futbol Libre Hoy\nUsage: futbol-libre-hoy [--live] [--date YYYY-MM-DD] [--sample]\n{DEFAULT_BASE_URL}");
                return;
            }
            _ => {}
        }
        i += 1;
    }

    let calendar = if sample {
        let text = fs::read_to_string("data/sample-calendar.json")
            .or_else(|_| fs::read_to_string("../data/sample-calendar.json"))
            .expect("sample calendar");
        parse_calendar(&text).expect("parse")
    } else {
        fetch_calendar(DEFAULT_BASE_URL, date.as_deref(), Some(&filter)).expect("fetch")
    };

    let matches = filter_matches(&calendar.matches, &filter);
    println!(
        "Futbol Libre Hoy - {} ({})",
        if calendar.date.is_empty() {
            "hoy"
        } else {
            &calendar.date
        },
        matches.len()
    );
    println!("{}\n", calendar.homepage);
    for g in group_by_tournament(&matches) {
        println!("## {}", g.tournament.name);
        for m in &g.matches {
            println!("- {}", format_line(m));
            println!("  {}", m.url);
        }
        println!();
    }
    println!("Más en Futbol Libre: {DEFAULT_BASE_URL}");
}
