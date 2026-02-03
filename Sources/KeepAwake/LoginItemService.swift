import Foundation
import ServiceManagement

// Protocol for the login item service
public protocol LoginItemService: AnyObject {
    /// Whether the app is registered as a login item
    var isRegistered: Bool { get }
    /// Register as a login item
    func register() throws
    /// Unregister as a login item
    func unregister() throws
}

// Thin wrapper around SMAppService
public final class RealLoginItemService: LoginItemService {
    public init() {}

    // SMAppService.Status .registered case (rawValue 1) cannot be referenced by name
    // in this SDK version (C enum prefix stripping issue), so compare rawValue directly
    public var isRegistered: Bool {
        SMAppService.mainApp.status.rawValue == 1
    }

    public func register() throws {
        try SMAppService.mainApp.register()
    }

    public func unregister() throws {
        try SMAppService.mainApp.unregister()
    }
}
