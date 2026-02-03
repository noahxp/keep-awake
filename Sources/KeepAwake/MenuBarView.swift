import SwiftUI

// Menu bar dropdown view
public struct MenuBarView: View {
    @ObservedObject public var manager: CaffeinateManager
    @ObservedObject public var loginItemManager: LoginItemManager
    @ObservedObject public var localizationManager: LocalizationManager

    // Public initializer for use by external modules
    public init(manager: CaffeinateManager, loginItemManager: LoginItemManager, localizationManager: LocalizationManager) {
        self.manager = manager
        self.loginItemManager = loginItemManager
        self.localizationManager = localizationManager
    }

    public var body: some View {
        // Duration option buttons (checkmark shown for the currently active option)
        ForEach(Duration.options, id: \.seconds) { option in
            Button(action: { manager.start(seconds: option.seconds) }) {
                Label(localizationManager.string(for: option.key),
                      systemImage: manager.currentSeconds == option.seconds ? "checkmark" : "")
            }
        }

        Divider()

        // Language switching submenu
        Menu(localizationManager.string(for: .language)) {
            ForEach(Language.allCases, id: \.self) { lang in
                Button(action: { localizationManager.setLanguage(lang) }) {
                    Label(lang.displayName, systemImage: lang == localizationManager.currentLanguage ? "checkmark" : "")
                }
            }
        }

        // Launch at login toggle
        Toggle(localizationManager.string(for: .autoLaunch), isOn: Binding(
            get: { loginItemManager.isEnabled },
            set: { loginItemManager.setEnabled($0) }
        ))

        // Quit option
        Button(localizationManager.string(for: .quit)) {
            manager.stop()
            NSApplication.shared.terminate(nil)
        }
    }
}
