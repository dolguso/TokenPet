import Foundation

struct DemoUsageProvider: UsageProviding {
    func fetchSummary() async throws -> UsageSummary {
        UsageSummary.demo
    }
}
