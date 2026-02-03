# KeepAwake

A macOS menu bar application that prevents the computer from going to sleep using the system `caffeinate` command.

## Requirements

| Item | Version |
|------|---------|
| macOS | 13 Ventura or later |
| Swift | 5.9 or later |
| Xcode / CommandLineTools | Any that provides the Swift toolchain |

## Usage

Click the coffee cup icon in the menu bar and select a duration from the dropdown:

| Option | Duration |
|--------|----------|
| 5 Minutes | 300 seconds |
| 30 Minutes | 1,800 seconds |
| 1 Hour | 3,600 seconds |
| 2 Hours | 7,200 seconds |
| 3 Hours | 10,800 seconds |
| 5 Hours | 18,000 seconds |

- A checkmark appears next to the currently active duration.
- The icon switches to **cup.and.saucer.fill** while caffeinate is running, and reverts to **cup.and.saucer** when it stops.
- Selecting a different duration while one is already active will automatically stop the previous one before starting the new one.
- When the timer expires, caffeinate exits automatically and the icon reverts — no manual action is needed.
- The "Quit" option at the bottom of the menu stops caffeinate and exits the app.

### Launch at Login

The "Launch at Login" toggle in the menu registers or unregisters the app as a login item via `SMAppService`. When enabled, the system will automatically launch KeepAwake at login.

### Language

Four languages are supported. The app detects the system language on launch; unsupported locales fall back to English. You can also switch languages manually via the language submenu:

| Language | System Language Code |
|----------|---------------------|
| English | en |
| Traditional Chinese | zh-TW, zh-HK |
| Simplified Chinese | zh-CN |
| Japanese | ja |

## Getting Started

### Build

```bash
swift build                          # debug
swift build --configuration release  # release
```

### Run (development)

```bash
./run.sh                          # debug build + launch
./run.sh --configuration release  # release build + launch
```

`run.sh` assembles the binary into a `.app` bundle (with `LSBackgroundOnly` set to prevent it from appearing in the Dock) and launches it via `open`, ensuring `MenuBarExtra` displays correctly in the menu bar.

### Run Tests

```bash
swift run KeepAwakeTests
```

Exit code `0` when all tests pass; `1` when any test fails.

> This project uses a custom lightweight test harness instead of XCTest or swift-testing. The reason is that in environments with only CommandLineTools installed (no Xcode), the `XCTest` framework is unavailable, and `swift-testing`'s cross-module overlay (`_Testing_Foundation`) lacks a `.swiftmodule` that SPM can resolve. The custom harness depends only on Foundation and is functionally equivalent to both frameworks.

### Uninstall

```bash
./remove.sh
```

Removes all KeepAwake-related configuration and caches, including the login-item LaunchAgent plist, the `.app` bundle installed to `/Applications` via DMG, preferences in `~/Library/Preferences`, and caches in `~/Library/Application Support` and `~/Library/Caches`.

## Release

Releases are automated via GitHub Actions (`.github/workflows/release.yml`). Pushing a tag matching `v*` triggers tests, a release build, `.app` assembly, DMG packaging, and publication to GitHub Releases:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Project Structure

```
keep-awake/
├── Package.swift                          # SPM definition: three targets
├── run.sh                                 # Development launch script
├── remove.sh                              # Script to remove the app and related config
├── .github/
│   └── workflows/
│       └── release.yml                    # GitHub Actions: automated DMG release
├── Sources/
│   ├── KeepAwake/                         # KeepAwakeLib — core business library
│   │   ├── Duration.swift                 # Duration option data model
│   │   ├── ProcessRunner.swift            # ProcessRunner protocol + RealProcessRunner
│   │   ├── CaffeinateManager.swift        # caffeinate lifecycle management (ObservableObject)
│   │   ├── LoginItemService.swift         # LoginItemService protocol + RealLoginItemService
│   │   ├── LoginItemManager.swift         # Login item state management (ObservableObject)
│   │   ├── Language.swift                 # Supported language enum
│   │   ├── LocalizationManager.swift      # i18n string management (ObservableObject)
│   │   └── MenuBarView.swift              # Menu bar dropdown view
│   └── KeepAwakeApp/                      # KeepAwake — application entry point
│       └── KeepAwakeApp.swift             # @main, MenuBarExtra scene
└── Tests/
    └── KeepAwakeTests/                    # KeepAwakeTests — unit tests (33 total)
        ├── main.swift                     # Test entry point: registers and runs all tests
        ├── TestHarness.swift              # Lightweight test framework (registerTest / assertEqual, etc.)
        ├── MockProcessRunner.swift        # Test mock for ProcessRunner
        ├── MockLoginItemService.swift     # Test mock for LoginItemService
        ├── DurationTests.swift            # Duration data model tests (3)
        ├── CaffeinateManagerTests.swift   # CaffeinateManager business tests (16)
        ├── LoginItemManagerTests.swift    # LoginItemManager business tests (6)
        └── LocalizationManagerTests.swift # LocalizationManager tests (8)
```

### SPM Targets

| Target | Type | Description |
|--------|------|-------------|
| `KeepAwakeLib` | `.target` (library) | All business logic and UI, shared by the entry point and tests |
| `KeepAwake` | `.executableTarget` | Contains only the `@main` entry point, depends on KeepAwakeLib |
| `KeepAwakeTests` | `.executableTarget` | Test suite, depends on KeepAwakeLib |

Business code is extracted into a separate library target because `.executableTarget` produces an executable binary that cannot be `import`ed by other targets. By using `.target`, a `.swiftmodule` is emitted so the test target can import the public types.

## Architecture

### Dependency Injection and Testability

Core business classes do not depend directly on system services. Instead, they use protocol abstractions injected at `init`, with production implementations as defaults and mocks substituted during testing:

```swift
// CaffeinateManager: obtains a ProcessRunner via a factory closure
public init(processFactory: @escaping () -> ProcessRunner = { RealProcessRunner() })

// LoginItemManager: obtains a LoginItemService via a parameter
public init(service: LoginItemService = RealLoginItemService())
```

- **Production**: Default values automatically use `RealProcessRunner` (thin wrapper around `Foundation.Process`) and `RealLoginItemService` (thin wrapper around `SMAppService`).
- **Testing**: `MockProcessRunner` / `MockLoginItemService` are injected, providing full control over behavior and call recording.

```
┌──────────────────┐  uses  ┌──────────────────┐
│ CaffeinateManager │──────►│  ProcessRunner   │ ← protocol
└──────────────────┘        └──────────────────┘
                                  ▲          ▲
                    ┌─────────────┘          └─────────────┐
                    ▼                                       ▼
         ┌─────────────────┐                ┌─────────────────────┐
         │ RealProcessRunner│               │  MockProcessRunner  │
         └─────────────────┘                └─────────────────────┘

┌──────────────────┐  uses  ┌──────────────────┐
│ LoginItemManager  │──────►│ LoginItemService │ ← protocol
└──────────────────┘        └──────────────────┘
                                  ▲          ▲
                    ┌─────────────┘          └─────────────┐
                    ▼                                       ▼
         ┌──────────────────┐              ┌─────────────────────┐
         │RealLoginItemService│            │ MockLoginItemService │
         └──────────────────┘              └─────────────────────┘
```

### State Synchronization

`caffeinate` exits automatically when its timer expires. `RealProcessRunner` bridges `Foundation.Process`'s `terminationHandler` to its own; `CaffeinateManager` flips `isRunning` to `false` and `currentSeconds` to `nil` in that callback via `DispatchQueue.main.async`. SwiftUI's `@Published` then automatically drives the icon and checkmark updates.

## Tests

A total of **33 unit tests**, developed in TDD Red → Green order:

| Wave | What is tested | Count |
|------|----------------|-------|
| 1 | Duration data model (option count, seconds values, key uniqueness) | 3 |
| 2 | CaffeinateManager start behavior (executableURL, arguments, run call) | 3 |
| 3 | isRunning state transitions (initial, after start, after caffeinate exit) | 3 |
| 4 | stop behavior (terminate call, isRunning toggle, no crash on empty state) | 3 |
| 4.5 | currentSeconds state (initial, after start, after stop, after exit, after switch) | 5 |
| 5 | Repeated start (previous process terminated on switch, new process params correct) | 2 |
| 6 | LoginItemManager (initial state, setEnabled, register/unregister failure handling) | 6 |
| 7 | LocalizationManager (initialization, language switch, per-locale string lookup, system language detection) | 8 |

`MockProcessRunner` provides a `simulateTermination()` method that manually triggers the `terminationHandler` in tests, simulating caffeinate's auto-exit when the timer expires — no need to wait for a real process.
