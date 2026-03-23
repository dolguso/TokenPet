import Foundation

struct OpenAIUsageClient: Sendable {
    let apiKey: String

    func fetchRecentSummary() async throws -> UsageSummary {
        let apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw UsageProviderError.missingAPIKey
        }

        throw UsageProviderError.liveAPIUnavailable
    }
}

struct OpenAIUsageProvider: UsageProviding {
    let client: OpenAIUsageClient

    func fetchSummary() async throws -> UsageSummary {
        try await client.fetchRecentSummary()
    }
}
