import Foundation

enum MoodEngine {
    static func evaluate(summary: UsageSummary) -> PetMood {
        let baseline = max(summary.averageCost, 0.01)
        let ratio = summary.today.costUSD / baseline

        return switch ratio {
        case ..<0.6:
            PetMood.sleepy
        case ..<1.2:
            PetMood.calm
        case ..<1.8:
            PetMood.active
        default:
            PetMood.overloaded
        }
    }
}
