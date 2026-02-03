import Foundation
import KeepAwakeLib

// Duration data model test registration

func registerDurationTests() {
    // Options count is six
    registerTest("test_optionsCount_是六個") {
        try assertEqual(Duration.options.count, 6)
    }

    // Each option has the correct seconds value
    registerTest("test_每個選項的seconds值正確") {
        let expected = [300, 1800, 3600, 7200, 10800, 18000]
        let actual = Duration.options.map { $0.seconds }
        try assertEqual(actual, expected)
    }

    // Each option has a unique key
    registerTest("test_每個選項的key互不相同") {
        let keys = Duration.options.map { $0.key }
        let uniqueKeys = Set(keys)
        try assertEqual(keys.count, uniqueKeys.count)
    }
}
