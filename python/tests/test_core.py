import json
import unittest
from pathlib import Path

from futbol_libre_hoy import (
    filter_matches,
    format_line,
    format_score,
    group_by_tournament,
    is_live,
    parse_calendar,
)

ROOT = Path(__file__).resolve().parents[2]
SAMPLE = parse_calendar((ROOT / "data" / "sample-calendar.json").read_text(encoding="utf-8"))
VECTORS = json.loads((ROOT / "fixtures" / "vectors.json").read_text(encoding="utf-8"))


class TestCore(unittest.TestCase):
    def test_format_parity(self):
        by_id = {m.id: m for m in SAMPLE.matches}
        for v in VECTORS["formatLines"]:
            m = by_id[v["id"]]
            self.assertEqual(format_score(m), v["score"])
            self.assertEqual(format_line(m), v["line"])
            self.assertEqual(is_live(m), v["live"])

    def test_filters(self):
        self.assertEqual(len(filter_matches(SAMPLE.matches, "live")), 1)
        self.assertEqual(len(filter_matches(SAMPLE.matches, "upcoming")), 1)
        self.assertEqual(len(filter_matches(SAMPLE.matches, "finished")), 1)

    def test_groups(self):
        groups = group_by_tournament(SAMPLE.matches)
        self.assertEqual(groups[0]["tournament"].slug, "copa-demo")
        self.assertEqual(len(groups[0]["matches"]), 2)


if __name__ == "__main__":
    unittest.main()
