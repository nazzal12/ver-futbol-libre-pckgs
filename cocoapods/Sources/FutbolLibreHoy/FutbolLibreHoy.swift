import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum FutbolLibreHoy {
    public static let defaultBaseURL = "https://verfutbollibre.net"
    public static let calendarPath = "/api/v1/calendar"

    public struct Team: Equatable, Sendable {
        public let id: Int
        public let name: String
        public let slug: String

        public init(id: Int, name: String, slug: String) {
            self.id = id
            self.name = name
            self.slug = slug
        }
    }

    public struct Match: Equatable, Sendable {
        public let id: Int
        public let status: String
        public let kickoffAt: String
        public let home: Team
        public let away: Team
        public let score: (Int, Int)?
        public let minute: Int?
        public let tournament: Team
        public let url: String

        public init(
            id: Int,
            status: String,
            kickoffAt: String,
            home: Team,
            away: Team,
            score: (Int, Int)?,
            minute: Int?,
            tournament: Team,
            url: String
        ) {
            self.id = id
            self.status = status
            self.kickoffAt = kickoffAt
            self.home = home
            self.away = away
            self.score = score
            self.minute = minute
            self.tournament = tournament
            self.url = url
        }

        public static func == (lhs: Match, rhs: Match) -> Bool {
            lhs.id == rhs.id
                && lhs.status == rhs.status
                && lhs.kickoffAt == rhs.kickoffAt
                && lhs.home == rhs.home
                && lhs.away == rhs.away
                && lhs.score?.0 == rhs.score?.0
                && lhs.score?.1 == rhs.score?.1
                && lhs.minute == rhs.minute
                && lhs.tournament == rhs.tournament
                && lhs.url == rhs.url
        }
    }

    public struct Calendar: Equatable, Sendable {
        public let source: String
        public let homepage: String
        public let date: String
        public let filter: String
        public let count: Int
        public let matches: [Match]

        public init(
            source: String,
            homepage: String,
            date: String,
            filter: String,
            count: Int,
            matches: [Match]
        ) {
            self.source = source
            self.homepage = homepage
            self.date = date
            self.filter = filter
            self.count = count
            self.matches = matches
        }
    }

    public struct TournamentGroup: Equatable, Sendable {
        public let tournament: Team
        public let matches: [Match]

        public init(tournament: Team, matches: [Match]) {
            self.tournament = tournament
            self.matches = matches
        }
    }

    public enum Error: Swift.Error, LocalizedError {
        case invalidJSON
        case httpStatus(Int)

        public var errorDescription: String? {
            switch self {
            case .invalidJSON: return "Invalid Futbol Libre calendar JSON"
            case .httpStatus(let code): return "Futbol Libre calendar HTTP \(code)"
            }
        }
    }

    private static func asTeam(_ raw: Any?, fallback: String) -> Team {
        let o = raw as? [String: Any] ?? [:]
        return Team(
            id: intValue(o["id"]) ?? 0,
            name: stringValue(o["name"]) ?? fallback,
            slug: stringValue(o["slug"]) ?? ""
        )
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return nil
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        if let s = value as? String { return Int(s) }
        return nil
    }

    public static func normalizeMatch(_ raw: Any) -> Match {
        let o = raw as? [String: Any] ?? [:]
        var score: (Int, Int)?
        if let arr = o["score"] as? [Any], arr.count >= 2,
           let h = intValue(arr[0]), let a = intValue(arr[1]) {
            score = (h, a)
        }
        return Match(
            id: intValue(o["id"]) ?? 0,
            status: stringValue(o["status"]) ?? "",
            kickoffAt: stringValue(o["kickoff_at"]) ?? "",
            home: asTeam(o["home"], fallback: "Home"),
            away: asTeam(o["away"], fallback: "Away"),
            score: score,
            minute: o["minute"] == nil || o["minute"] is NSNull ? nil : intValue(o["minute"]),
            tournament: asTeam(o["tournament"], fallback: "Tournament"),
            url: stringValue(o["url"]) ?? defaultBaseURL
        )
    }

    public static func parseCalendar(_ input: Any) throws -> Calendar {
        let data: [String: Any]
        if let s = input as? String {
            guard let bytes = s.data(using: .utf8),
                  let obj = try JSONSerialization.jsonObject(with: bytes) as? [String: Any]
            else { throw Error.invalidJSON }
            data = obj
        } else if let obj = input as? [String: Any] {
            data = obj
        } else {
            throw Error.invalidJSON
        }

        let list = data["matches"] as? [Any] ?? []
        let matches = list.map(normalizeMatch)
        let count = intValue(data["count"]) ?? matches.count
        return Calendar(
            source: stringValue(data["source"]) ?? "Futbol Libre",
            homepage: stringValue(data["homepage"]) ?? defaultBaseURL,
            date: stringValue(data["date"]) ?? "",
            filter: stringValue(data["filter"]) ?? "all",
            count: count,
            matches: matches
        )
    }

    public static func formatScore(_ match: Match) -> String {
        if let score = match.score {
            return "\(score.0)-\(score.1)"
        }
        return "vs"
    }

    public static func isLive(_ match: Match) -> Bool {
        match.status == "live"
    }

    public static func formatLine(_ match: Match) -> String {
        let score = formatScore(match)
        let pair = "\(match.home.name) \(score) \(match.away.name)"
        if match.status == "live" {
            if let minute = match.minute {
                return "\(minute)' \(pair)"
            }
            return "LIVE \(pair)"
        }
        if match.status == "before" {
            return "\(match.home.name) vs \(match.away.name)"
        }
        return pair
    }

    public static func filterMatches(_ matches: [Match], filter: String) -> [Match] {
        switch filter.lowercased() {
        case "live":
            return matches.filter { $0.status == "live" }
        case "upcoming":
            return matches.filter { $0.status == "before" }
        case "finished":
            return matches.filter { $0.status == "after" }
        default:
            return matches
        }
    }

    public static func groupByTournament(_ matches: [Match]) -> [TournamentGroup] {
        var order: [Int] = []
        var buckets: [Int: [Match]] = [:]
        var tournaments: [Int: Team] = [:]
        for m in matches {
            let id = m.tournament.id
            if buckets[id] == nil {
                order.append(id)
                tournaments[id] = m.tournament
                buckets[id] = []
            }
            buckets[id, default: []].append(m)
        }
        return order.compactMap { id in
            guard let tournament = tournaments[id], let list = buckets[id] else { return nil }
            return TournamentGroup(tournament: tournament, matches: list)
        }
    }

    public static func fetchCalendar(
        date: String? = nil,
        filter: String? = nil,
        baseURL: String = defaultBaseURL,
        completion: @escaping (Result<Calendar, Swift.Error>) -> Void
    ) {
        let trimmed = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        guard var components = URLComponents(string: trimmed + calendarPath) else {
            completion(.failure(Error.invalidJSON))
            return
        }
        var items: [URLQueryItem] = []
        if let date, !date.isEmpty { items.append(URLQueryItem(name: "date", value: date)) }
        if let filter, !filter.isEmpty, filter != "all" {
            items.append(URLQueryItem(name: "filter", value: filter))
        }
        if !items.isEmpty { components.queryItems = items }
        guard let url = components.url else {
            completion(.failure(Error.invalidJSON))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("es-ES", forHTTPHeaderField: "Accept-Language")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(code), let data else {
                completion(.failure(Error.httpStatus(code)))
                return
            }
            do {
                let obj = try JSONSerialization.jsonObject(with: data)
                completion(.success(try parseCalendar(obj)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
