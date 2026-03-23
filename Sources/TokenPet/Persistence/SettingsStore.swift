import Foundation

final class SettingsStore {
    private enum Keys {
        static let useDemoMode = "useDemoMode"
        static let refreshIntervalMinutes = "refreshIntervalMinutes"
    }

    private let defaults = UserDefaults.standard

    var useDemoMode: Bool {
        get {
            if defaults.object(forKey: Keys.useDemoMode) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.useDemoMode)
        }
        set {
            defaults.set(newValue, forKey: Keys.useDemoMode)
        }
    }

    var refreshIntervalMinutes: Int {
        get {
            let value = defaults.integer(forKey: Keys.refreshIntervalMinutes)
            return value == 0 ? 30 : value
        }
        set {
            defaults.set(newValue, forKey: Keys.refreshIntervalMinutes)
        }
    }
}
