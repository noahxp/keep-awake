// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeepAwake",
    platforms: [.macOS(.v13)],
    targets: [
        // Core business library (shared by test and entry-point targets)
        .target(
            name: "KeepAwakeLib",
            path: "Sources/KeepAwake"
        ),
        // Application entry point
        .executableTarget(
            name: "KeepAwake",
            dependencies: ["KeepAwakeLib"],
            path: "Sources/KeepAwakeApp"
        ),
        // Unit test entry point (custom test harness)
        .executableTarget(
            name: "KeepAwakeTests",
            dependencies: ["KeepAwakeLib"],
            path: "Tests/KeepAwakeTests"
        )
    ]
)
