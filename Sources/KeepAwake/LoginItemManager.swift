import Foundation

// Business class that manages the login item state
public final class LoginItemManager: ObservableObject {
    /// Whether the app is set to launch at login
    @Published public var isEnabled: Bool = false

    /// Login item service (supports dependency injection)
    private let service: LoginItemService

    public init(service: LoginItemService = RealLoginItemService()) {
        self.service = service
        self.isEnabled = service.isRegistered
    }

    /// Set the login item state; isEnabled remains unchanged on failure
    public func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
            isEnabled = enabled
        } catch {
            // Operation failed (e.g. app is not signed); isEnabled retains its current value
        }
    }
}
