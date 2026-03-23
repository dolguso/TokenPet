import SwiftUI

@main
struct TokenPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appModel = TokenPetAppModel.shared

    var body: some Scene {
        Settings {
            SettingsView(appModel: appModel)
                .frame(width: 420, height: 320)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        .defaultPosition(.center)
        .onChange(of: appModel.statusSymbol) {
            appDelegate.updateStatusItem(symbol: appModel.statusSymbol)
        }
        .onChange(of: appModel.statusTint) {
            appDelegate.updateStatusItem(symbol: appModel.statusSymbol)
        }
    }
}
