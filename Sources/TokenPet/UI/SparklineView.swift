import SwiftUI

struct SparklineView: View {
    let days: [DailyUsage]

    var body: some View {
        GeometryReader { proxy in
            let maxCost = max(days.map(\.costUSD).max() ?? 1, 1)
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.08))

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(days) { day in
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor.gradient)
                                .frame(height: max(10, CGFloat(day.costUSD / maxCost) * (height - 18)))
                        }
                        .frame(width: max((width / CGFloat(max(days.count, 1))) - 6, 12))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
        }
    }
}
