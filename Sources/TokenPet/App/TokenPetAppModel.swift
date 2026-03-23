import Foundation
import SwiftUI

@MainActor
final class TokenPetAppModel: ObservableObject {
    static let shared = TokenPetAppModel()

    @Published private(set) var summary: UsageSummary = .demo
    @Published private(set) var mood: PetMood = .calm
    @Published private(set) var statusMessage = "Demo mode active"
    @Published var useDemoMode = true
    @Published var refreshIntervalMinutes = 30
    @Published var apiKey: String = ""
    @Published private(set) var lastError: String?

    private let settingsStore = SettingsStore()
    private let keychainStore = KeychainStore()
    private let usageRepository = UsageRepository()
    var statusSymbol: String {
        mood.symbol
    }

    var statusTint: Color {
        mood.tint
    }

    func bootstrap() async {
        refreshIntervalMinutes = settingsStore.refreshIntervalMinutes
        useDemoMode = settingsStore.useDemoMode

        if let storedKey = try? keychainStore.read(key: .openAIAPIKey) {
            apiKey = storedKey
        }

        if let cachedSummary = try? usageRepository.loadSummary() {
            apply(summary: cachedSummary, source: .cache)
        }

        await refresh()
    }

    func refresh() async {
        let usageProvider = makeProvider()

        do {
            let newSummary = try await usageProvider.fetchSummary()
            try usageRepository.save(summary: newSummary)
            apply(summary: newSummary, source: useDemoMode ? .demo : .live)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            if summary.days.isEmpty {
                let fallback = UsageSummary.demo
                try? usageRepository.save(summary: fallback)
                apply(summary: fallback, source: .demo)
            }
        }
    }

    func saveSettings() async {
        settingsStore.useDemoMode = useDemoMode
        settingsStore.refreshIntervalMinutes = refreshIntervalMinutes

        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            try? keychainStore.delete(key: .openAIAPIKey)
        } else {
            try? keychainStore.write(value: trimmed, key: .openAIAPIKey)
        }

        await refresh()
    }

    private func makeProvider() -> any UsageProviding {
        if useDemoMode {
            DemoUsageProvider()
        } else {
            OpenAIUsageProvider(
                client: OpenAIUsageClient(
                    apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            )
        }
    }

    private func apply(summary: UsageSummary, source: StatusSource) {
        self.summary = summary
        self.mood = MoodEngine.evaluate(summary: summary)
        self.statusMessage = switch source {
        case .demo:
            "Demo mode · today $\(summary.todayCostText)"
        case .live:
            "Live mode · today $\(summary.todayCostText)"
        case .cache:
            "Cached snapshot · today $\(summary.todayCostText)"
        }
    }
}

private enum StatusSource {
    case demo
    case live
    case cache
}
