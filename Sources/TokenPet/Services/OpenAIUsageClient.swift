import Foundation

struct OpenAIUsageClient: Sendable {
    let apiKey: String
    private let baseURL = URL(string: "https://api.openai.com/v1/organization")!

    func fetchRecentSummary() async throws -> UsageSummary {
        let apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw UsageProviderError.missingAPIKey
        }

        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else {
            throw UsageProviderError.invalidResponse
        }

        async let usageBuckets = fetchUsageBuckets(apiKey: apiKey, startDate: startDate)
        async let costBuckets = fetchCostBuckets(apiKey: apiKey, startDate: startDate)

        let (usageResponse, costResponse) = try await (usageBuckets, costBuckets)
        let summary = mergeSummary(usageBuckets: usageResponse.data, costBuckets: costResponse.data, now: now)

        guard !summary.days.isEmpty else {
            throw UsageProviderError.invalidResponse
        }

        return summary
    }

    private func fetchUsageBuckets(apiKey: String, startDate: Date) async throws -> UsageBucketsResponse {
        let url = try buildURL(path: "usage/completions", startDate: startDate)
        let data = try await performRequest(url: url, apiKey: apiKey)
        return try JSONDecoder.openAIDecoder.decode(UsageBucketsResponse.self, from: data)
    }

    private func fetchCostBuckets(apiKey: String, startDate: Date) async throws -> CostBucketsResponse {
        let url = try buildURL(path: "costs", startDate: startDate)
        let data = try await performRequest(url: url, apiKey: apiKey)
        return try JSONDecoder.openAIDecoder.decode(CostBucketsResponse.self, from: data)
    }

    private func buildURL(path: String, startDate: Date) throws -> URL {
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw UsageProviderError.invalidResponse
        }

        components.queryItems = [
            URLQueryItem(name: "start_time", value: String(Int(startDate.timeIntervalSince1970))),
            URLQueryItem(name: "bucket_width", value: "1d"),
            URLQueryItem(name: "limit", value: "7"),
        ]

        guard let url = components.url else {
            throw UsageProviderError.invalidResponse
        }

        return url
    }

    private func performRequest(url: URL, apiKey: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageProviderError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw OpenAIUsageClientError.adminKeyRequired
            }
            throw OpenAIUsageClientError.requestFailed(statusCode: httpResponse.statusCode)
        }

        return data
    }

    private func mergeSummary(usageBuckets: [UsageBucket], costBuckets: [CostBucket], now: Date) -> UsageSummary {
        let groupedCosts = Dictionary(uniqueKeysWithValues: costBuckets.map { ($0.startDateKey, $0.totalCostUSD) })

        let days = usageBuckets.map { bucket in
            let modelBreakdown = bucket.results
                .filter { $0.totalTokens > 0 }
                .map {
                    ModelUsage(model: $0.model ?? "unknown", costUSD: 0, tokens: $0.totalTokens)
                }
                .sorted { $0.tokens > $1.tokens }

            return DailyUsage(
                date: bucket.startDate,
                costUSD: groupedCosts[bucket.startDateKey] ?? 0,
                totalTokens: bucket.results.reduce(0) { $0 + $1.totalTokens },
                modelBreakdown: modelBreakdown
            )
        }
        .sorted { $0.date < $1.date }

        let topModel = days
            .flatMap(\.modelBreakdown)
            .reduce(into: [String: Int]()) { partialResult, modelUsage in
                partialResult[modelUsage.model, default: 0] += modelUsage.tokens
            }
            .max { $0.value < $1.value }?
            .key ?? "unknown"

        return UsageSummary(days: days, topModel: topModel, generatedAt: now)
    }
}

struct OpenAIUsageProvider: UsageProviding {
    let client: OpenAIUsageClient

    func fetchSummary() async throws -> UsageSummary {
        try await client.fetchRecentSummary()
    }
}

private enum OpenAIUsageClientError: LocalizedError {
    case adminKeyRequired
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .adminKeyRequired:
            "Live mode requires an OpenAI admin-capable API key for organization usage endpoints."
        case let .requestFailed(statusCode):
            "OpenAI usage request failed with status code \(statusCode)."
        }
    }
}

private struct UsageBucketsResponse: Decodable {
    let data: [UsageBucket]
}

private struct UsageBucket: Decodable {
    let startTime: TimeInterval
    let results: [UsageResult]

    var startDate: Date {
        Date(timeIntervalSince1970: startTime)
    }

    var startDateKey: String {
        DateFormatter.openAIBucketDay.string(from: startDate)
    }

    private enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case results
    }
}

private struct UsageResult: Decodable {
    let model: String?
    let inputTokens: Int
    let outputTokens: Int
    let inputCachedTokens: Int

    var totalTokens: Int {
        inputTokens + outputTokens + inputCachedTokens
    }

    private enum CodingKeys: String, CodingKey {
        case model
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case inputCachedTokens = "input_cached_tokens"
    }
}

private struct CostBucketsResponse: Decodable {
    let data: [CostBucket]
}

private struct CostBucket: Decodable {
    let startTime: TimeInterval
    let results: [CostResult]

    var startDate: Date {
        Date(timeIntervalSince1970: startTime)
    }

    var startDateKey: String {
        DateFormatter.openAIBucketDay.string(from: startDate)
    }

    var totalCostUSD: Double {
        results.reduce(0) { $0 + $1.amount.value }
    }

    private enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case results
        case result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decode(TimeInterval.self, forKey: .startTime)

        if let results = try container.decodeIfPresent([CostResult].self, forKey: .results) {
            self.results = results
        } else if let result = try container.decodeIfPresent([CostResult].self, forKey: .result) {
            self.results = result
        } else if let single = try container.decodeIfPresent(CostResult.self, forKey: .result) {
            self.results = [single]
        } else {
            self.results = []
        }
    }
}

private struct CostResult: Decodable {
    let amount: CostAmount
}

private struct CostAmount: Decodable {
    let value: Double
    let currency: String?
}

private extension JSONDecoder {
    static var openAIDecoder: JSONDecoder {
        JSONDecoder()
    }
}

private extension DateFormatter {
    static let openAIBucketDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
