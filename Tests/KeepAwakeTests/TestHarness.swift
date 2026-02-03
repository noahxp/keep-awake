import Foundation

// Lightweight test framework, independent of XCTest and swift-testing

/// A single test case
struct TestCase {
    let name: String
    let body: () throws -> Void
}

/// Global test registry
var allTests: [TestCase] = []

/// Register a test
func registerTest(_ name: String, _ body: @escaping () throws -> Void) {
    allTests.append(TestCase(name: name, body: body))
}

/// Assertion: two values are equal
func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "") throws {
    guard actual == expected else {
        let detail = "期望 \(expected)，但得到 \(actual)"
        throw TestFailure(reason: message.isEmpty ? detail : "\(message) — \(detail)")
    }
}

/// Assertion: condition is true
func assertTrue(_ condition: Bool, _ message: String = "條件應為 true") throws {
    guard condition else { throw TestFailure(reason: message) }
}

/// Assertion: condition is false
func assertFalse(_ condition: Bool, _ message: String = "條件應為 false") throws {
    guard !condition else { throw TestFailure(reason: message) }
}

/// Test failure error
struct TestFailure: Error {
    let reason: String
}

/// Run all registered tests and print the report
func runAllTests() -> Bool {
    var passed = 0
    var failed = 0

    for test in allTests {
        do {
            try test.body()
            print("  ✓ \(test.name)")
            passed += 1
        } catch let failure as TestFailure {
            print("  ✗ \(test.name): \(failure.reason)")
            failed += 1
        } catch {
            print("  ✗ \(test.name): \(error)")
            failed += 1
        }
    }

    print("")
    print("結果：\(passed) passed, \(failed) failed, \(allTests.count) total")
    return failed == 0
}
