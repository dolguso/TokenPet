import Foundation

protocol UsageProviding: Sendable {
    func fetchSummary() async throws -> UsageSummary
}

enum UsageProviderError: LocalizedError {
    case missingAPIKey
    case liveAPIUnavailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "OpenAI API key is missing."
        case .liveAPIUnavailable:
            "Live OpenAI usage fetch is not wired yet. Use demo mode for now."
        case .invalidResponse:
            "OpenAI usage response could not be parsed."
        }
    }
}
