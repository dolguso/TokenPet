import SwiftUI

enum PetMood: String, Codable, CaseIterable {
    case sleepy
    case calm
    case active
    case overloaded

    var symbol: String {
        switch self {
        case .sleepy: "😴"
        case .calm: "🐣"
        case .active: "🐱"
        case .overloaded: "🔥"
        }
    }

    var title: String {
        switch self {
        case .sleepy: "Sleepy"
        case .calm: "Calm"
        case .active: "Active"
        case .overloaded: "Overloaded"
        }
    }

    var tint: Color {
        switch self {
        case .sleepy: .blue
        case .calm: .green
        case .active: .orange
        case .overloaded: .red
        }
    }

    var statusLine: String {
        switch self {
        case .sleepy: "Quiet day. Your token pet is dozing off."
        case .calm: "Steady pace. Healthy usage rhythm today."
        case .active: "Busy day. You are leaning on OpenAI a lot."
        case .overloaded: "Heavy burn. Might be worth checking spend."
        }
    }
}
