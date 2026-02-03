import Foundation
import KeepAwakeLib

// Test mock for LoginItemService
final class MockLoginItemService: LoginItemService {
    // Recorded fields
    var registerCalled = false
    var unregisterCalled = false

    // Control fields
    var mockIsRegistered: Bool = false
    var shouldThrowOnRegister: Error?
    var shouldThrowOnUnregister: Error?

    var isRegistered: Bool { mockIsRegistered }

    func register() throws {
        if let error = shouldThrowOnRegister { throw error }
        registerCalled = true
        mockIsRegistered = true
    }

    func unregister() throws {
        if let error = shouldThrowOnUnregister { throw error }
        unregisterCalled = true
        mockIsRegistered = false
    }
}
