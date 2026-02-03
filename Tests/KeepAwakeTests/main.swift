import Foundation

// Test entry point: register and run all tests

print("=== KeepAwake 單元測試 ===")
print("")

// Register tests for each module
registerDurationTests()
registerCaffeinateManagerTests()
registerLoginItemManagerTests()
registerLocalizationManagerTests()

// Run all tests
let allPassed = runAllTests()

// Non-zero exit code indicates test failure
exit(allPassed ? 0 : 1)
