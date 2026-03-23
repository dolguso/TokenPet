import SwiftUI

struct SettingsView: View {
    @ObservedObject var appModel: TokenPetAppModel

    var body: some View {
        Form {
            Section("Mode") {
                Toggle("Use demo mode", isOn: $appModel.useDemoMode)
                Text("Demo mode keeps the app useful even before the live OpenAI usage endpoint is fully wired.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("OpenAI") {
                SecureField("OpenAI API key", text: $appModel.apiKey)
                Text("The key is stored in macOS Keychain. v1 keeps live mode isolated so the app still works safely in demo mode.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Refresh") {
                Stepper(value: $appModel.refreshIntervalMinutes, in: 5...120, step: 5) {
                    Text("Refresh every \(appModel.refreshIntervalMinutes) minutes")
                }
            }

            Section {
                HStack {
                    Spacer()
                    Button("Save & Refresh") {
                        Task {
                            await appModel.saveSettings()
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(20)
    }
}
