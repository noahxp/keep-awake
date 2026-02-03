import Foundation

// Protocol wrapping Process operations
public protocol ProcessRunner: AnyObject {
    var executableURL: URL? { get set }
    var arguments: [String]? { get set }
    /// Callback invoked when the process terminates
    var terminationHandler: ((ProcessRunner) -> Void)? { get set }
    /// Start the process
    func run() throws
    /// Terminate the process
    func terminate()
    /// Whether the process is currently running
    var isRunning: Bool { get }
}

// Thin wrapper around Foundation.Process
public final class RealProcessRunner: ProcessRunner {
    private let process = Process()

    public init() {}

    public var executableURL: URL? {
        get { process.executableURL }
        set { process.executableURL = newValue }
    }

    public var arguments: [String]? {
        get { process.arguments }
        set { process.arguments = newValue }
    }

    // Bridge the external handler to Process's terminationHandler
    public var terminationHandler: ((ProcessRunner) -> Void)? {
        didSet {
            process.terminationHandler = { [weak self] _ in
                guard let self else { return }
                self.terminationHandler?(self)
            }
        }
    }

    public func run() throws {
        try process.run()
    }

    public func terminate() {
        process.terminate()
    }

    public var isRunning: Bool {
        process.isRunning
    }
}
