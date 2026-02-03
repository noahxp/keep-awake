import Foundation

// Core business class that manages the caffeinate process lifecycle
public final class CaffeinateManager: ObservableObject {
    /// Whether caffeinate is currently running
    @Published public var isRunning: Bool = false
    /// Duration in seconds of the currently active session (nil when not running)
    @Published public var currentSeconds: Int? = nil

    /// The currently running process
    private var currentProcess: ProcessRunner?

    /// Factory closure for creating new ProcessRunner instances (supports dependency injection)
    private let processFactory: () -> ProcessRunner

    public init(processFactory: @escaping () -> ProcessRunner = { RealProcessRunner() }) {
        self.processFactory = processFactory
    }

    /// Start caffeinate with the specified duration in seconds
    public func start(seconds: Int) {
        // Stop the previous instance if one is already running
        stop()

        let process = processFactory()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-s", "-t", String(seconds)]

        // caffeinate auto-exits when the timer expires; update state via terminationHandler
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.currentSeconds = nil
                self?.currentProcess = nil
            }
        }

        do {
            try process.run()
            currentProcess = process
            isRunning = true
            currentSeconds = seconds
        } catch {
            // Keep isRunning = false on launch failure
            isRunning = false
        }
    }

    /// Terminate the current caffeinate process
    public func stop() {
        guard let process = currentProcess else { return }
        process.terminate()
        currentProcess = nil
        isRunning = false
        currentSeconds = nil
    }

    deinit {
        stop()
    }
}
