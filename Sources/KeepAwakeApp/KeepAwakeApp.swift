import SwiftUI
import KeepAwakeLib

// App entry point; menu bar only, no main window
@main
struct KeepAwakeApp: App {
    @StateObject var manager = CaffeinateManager()
    @StateObject var loginItemManager = LoginItemManager()
    @StateObject var localizationManager = LocalizationManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(manager: manager, loginItemManager: loginItemManager, localizationManager: localizationManager)
        } label: {
            // Toggle icon based on whether caffeinate is running
            Image(systemName: manager.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
    }
}
