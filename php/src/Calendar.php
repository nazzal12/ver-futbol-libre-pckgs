<?php
declare(strict_types=1);

namespace FutbolLibreHoy;

final class Calendar
{
    public const DEFAULT_BASE_URL = 'https://verfutbollibre.net';
    public const CALENDAR_PATH = '/api/v1/calendar';

    /** @return array<string,mixed> */
    public static function parse(string $json): array
    {
        $data = json_decode($json, true) ?: [];
        $matches = [];
        foreach (($data['matches'] ?? []) as $raw) {
            $matches[] = self::normalizeMatch($raw);
        }
        return [
            'source' => (string)($data['source'] ?? 'Futbol Libre'),
            'homepage' => (string)($data['homepage'] ?? self::DEFAULT_BASE_URL),
            'date' => (string)($data['date'] ?? ''),
            'filter' => (string)($data['filter'] ?? 'all'),
            'count' => isset($data['count']) ? (int)$data['count'] : count($matches),
            'matches' => $matches,
        ];
    }

    /** @param array<string,mixed> $raw */
    public static function normalizeMatch(array $raw): array
    {
        $score = null;
        if (isset($raw['score']) && is_array($raw['score']) && count($raw['score']) >= 2) {
            $score = [(int)$raw['score'][0], (int)$raw['score'][1]];
        }
        $team = static function ($t, string $fallback): array {
            $t = is_array($t) ? $t : [];
            return [
                'id' => (int)($t['id'] ?? 0),
                'name' => (string)($t['name'] ?? $fallback),
                'slug' => (string)($t['slug'] ?? ''),
            ];
        };
        return [
            'id' => (int)($raw['id'] ?? 0),
            'status' => (string)($raw['status'] ?? ''),
            'kickoff_at' => (string)($raw['kickoff_at'] ?? ''),
            'home' => $team($raw['home'] ?? null, 'Home'),
            'away' => $team($raw['away'] ?? null, 'Away'),
            'score' => $score,
            'minute' => array_key_exists('minute', $raw) && $raw['minute'] !== null ? (int)$raw['minute'] : null,
            'tournament' => $team($raw['tournament'] ?? null, 'Tournament'),
            'url' => (string)($raw['url'] ?? self::DEFAULT_BASE_URL),
        ];
    }

    /** @param array<string,mixed> $m */
    public static function formatScore(array $m): string
    {
        if (isset($m['score']) && is_array($m['score'])) {
            return $m['score'][0] . '-' . $m['score'][1];
        }
        return 'vs';
    }

    /** @param array<string,mixed> $m */
    public static function formatLine(array $m): string
    {
        $score = self::formatScore($m);
        $pair = $m['home']['name'] . ' ' . $score . ' ' . $m['away']['name'];
        if (($m['status'] ?? '') === 'live') {
            if ($m['minute'] !== null) {
                return $m['minute'] . "' " . $pair;
            }
            return 'LIVE ' . $pair;
        }
        if (($m['status'] ?? '') === 'before') {
            return $m['home']['name'] . ' vs ' . $m['away']['name'];
        }
        return $pair;
    }

    /** @return array<string,mixed> */
    public static function fetch(?string $date = null, string $filter = 'all', string $base = self::DEFAULT_BASE_URL): array
    {
        $qs = [];
        if ($date) $qs['date'] = $date;
        if ($filter !== 'all') $qs['filter'] = $filter;
        $url = rtrim($base, '/') . self::CALENDAR_PATH;
        if ($qs) $url .= '?' . http_build_query($qs);
        $ctx = stream_context_create([
            'http' => [
                'header' => "Accept: application/json\r\nAccept-Language: es-ES\r\n",
                'timeout' => 30,
            ],
        ]);
        $body = file_get_contents($url, false, $ctx);
        if ($body === false) {
            throw new \RuntimeException('Failed to fetch Futbol Libre calendar');
        }
        return self::parse($body);
    }
}
