import SwiftUI

struct PopoverRootView: View {
    @ObservedObject var appModel: TokenPetAppModel
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text(appModel.mood.symbol)
                    .font(.system(size: 42))
                VStack(alignment: .leading, spacing: 4) {
                    Text("TokenPet")
                        .font(.headline)
                    Text(appModel.mood.statusLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            SummaryCardGrid(summary: appModel.summary)

            SparklineView(days: appModel.summary.days)
                .frame(height: 76)

            HStack {
                Button("Refresh") {
                    Task {
                        await appModel.refresh()
                    }
                }
                .keyboardShortcut("r")

                Spacer()

                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }

            if let lastError = appModel.lastError {
                Text(lastError)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(width: 340)
        .sheet(isPresented: $showingSettings) {
            SettingsView(appModel: appModel)
                .frame(width: 420, height: 320)
                .padding(20)
        }
    }
}

private struct SummaryCardGrid: View {
    let summary: UsageSummary

    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                SummaryCard(title: "Today", value: "$\(summary.todayCostText)", caption: "\(summary.today.totalTokens.formatted()) tokens")
                SummaryCard(title: "This Week", value: String(format: "$%.2f", summary.weekCost), caption: "\(summary.weekTokens.formatted()) tokens")
            }
            GridRow {
                SummaryCard(title: "Top Model", value: summary.topModel, caption: "Most active this week")
                SummaryCard(title: "Updated", value: summary.generatedAt.formatted(date: .omitted, time: .shortened), caption: "latest snapshot")
            }
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .lineLimit(1)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
