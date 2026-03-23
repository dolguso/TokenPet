import Foundation

struct UsageSummary: Codable, Equatable {
    let days: [DailyUsage]
    let topModel: String
    let generatedAt: Date

    var today: DailyUsage {
        days.last ?? .empty
    }

    var todayCostText: String {
        String(format: "%.2f", today.costUSD)
    }

    var weekCost: Double {
        days.reduce(0) { $0 + $1.costUSD }
    }

    var weekTokens: Int {
        days.reduce(0) { $0 + $1.totalTokens }
    }

    var averageCost: Double {
        guard !days.isEmpty else { return 0 }
        return weekCost / Double(days.count)
    }

    static let demo = UsageSummary(
        days: DailyUsage.demoWeek,
        topModel: "gpt-5-mini",
        generatedAt: .now
    )
}

struct DailyUsage: Codable, Equatable, Identifiable {
    let date: Date
    let costUSD: Double
    let totalTokens: Int
    let modelBreakdown: [ModelUsage]

    var id: Date { date }

    static let empty = DailyUsage(date: .now, costUSD: 0, totalTokens: 0, modelBreakdown: [])

    static let demoWeek: [DailyUsage] = {
        let calendar = Calendar.current
        let models = ["gpt-5-mini", "gpt-5.4", "gpt-4.1-mini"]

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - 6, to: .now) else { return nil }
            let tokenBase = 180_000 + (offset * 42_000)
            let cost = 0.54 + (Double(offset) * 0.27)

            return DailyUsage(
                date: date,
                costUSD: cost,
                totalTokens: tokenBase,
                modelBreakdown: [
                    ModelUsage(model: models[offset % models.count], costUSD: cost * 0.6, tokens: Int(Double(tokenBase) * 0.58)),
                    ModelUsage(model: models[(offset + 1) % models.count], costUSD: cost * 0.4, tokens: Int(Double(tokenBase) * 0.42)),
                ]
            )
        }
    }()
}

struct ModelUsage: Codable, Equatable, Identifiable {
    let model: String
    let costUSD: Double
    let tokens: Int

    var id: String { model }
}
