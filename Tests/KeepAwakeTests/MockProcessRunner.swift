import Foundation
import KeepAwakeLib

// Test mock for ProcessRunner; records all calls and allows manual callback triggering
final class MockProcessRunner: ProcessRunner {
    // Recorded fields
    var recordedExecutableURL: URL?
    var recordedArguments: [String]?
    var terminateCalled = false
    var runCalled = false

    // Control fields
    var shouldThrowOnRun: Error?
    var mockIsRunning = false

    // Protocol-required properties
    var executableURL: URL? {
        get { recordedExecutableURL }
        set { recordedExecutableURL = newValue }
    }

    var arguments: [String]? {
        get { recordedArguments }
        set { recordedArguments = newValue }
    }

    var terminationHandler: ((ProcessRunner) -> Void)?

    func run() throws {
        if let error = shouldThrowOnRun {
            throw error
        }
        runCalled = true
        mockIsRunning = true
    }

    func terminate() {
        terminateCalled = true
        mockIsRunning = false
    }

    var isRunning: Bool {
        mockIsRunning
    }

    /// Manually invoke terminationHandler to simulate caffeinate auto-exit on timer expiry
    func simulateTermination() {
        mockIsRunning = false
        terminationHandler?(self)
    }
}
