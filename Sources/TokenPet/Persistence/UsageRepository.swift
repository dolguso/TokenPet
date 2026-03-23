import Foundation

final class UsageRepository {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save(summary: UsageSummary) throws {
        let data = try encoder.encode(summary)
        let url = try fileURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    func loadSummary() throws -> UsageSummary {
        let data = try Data(contentsOf: try fileURL())
        return try decoder.decode(UsageSummary.self, from: data)
    }

    private func fileURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base
            .appendingPathComponent("TokenPet", isDirectory: true)
            .appendingPathComponent("usage-summary.json")
    }
}
