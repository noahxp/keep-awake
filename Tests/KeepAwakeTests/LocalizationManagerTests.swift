import Foundation
import KeepAwakeLib

// LocalizationManager i18n business test registration

func registerLocalizationManagerTests() {

    // MARK: - Initialization

    // currentLanguage is correct when initialized with a specific language
    registerTest("test_指定語言初始化_currentLanguage正確") {
        let manager = LocalizationManager(language: .ja)
        try assertEqual(manager.currentLanguage, .ja)
    }

    // MARK: - Language switching

    // currentLanguage updates after setLanguage
    registerTest("test_setLanguage_切換語言") {
        let manager = LocalizationManager(language: .en)
        manager.setLanguage(.zhTW)
        try assertEqual(manager.currentLanguage, .zhTW)
    }

    // Strings update correctly after language switch
    registerTest("test_切換語言後_字串正確更新") {
        let manager = LocalizationManager(language: .en)
        try assertEqual(manager.string(for: .autoLaunch), "Launch at Login")
        manager.setLanguage(.ja)
        try assertEqual(manager.string(for: .autoLaunch), "ログイン時に起動")
    }

    // MARK: - String lookups per language

    // English lookup returns correct string
    registerTest("test_string_英文查詢正確") {
        let manager = LocalizationManager(language: .en)
        try assertEqual(manager.string(for: .quit), "Quit")
    }

    // Traditional Chinese lookup returns correct string
    registerTest("test_string_繁體中文查詢正確") {
        let manager = LocalizationManager(language: .zhTW)
        try assertEqual(manager.string(for: .quit), "結束")
    }

    // Simplified Chinese lookup returns correct string
    registerTest("test_string_简体中文查詢正確") {
        let manager = LocalizationManager(language: .zhCN)
        try assertEqual(manager.string(for: .quit), "退出")
    }

    // Japanese lookup returns correct string
    registerTest("test_string_日本語查詢正確") {
        let manager = LocalizationManager(language: .ja)
        try assertEqual(manager.string(for: .quit), "終了")
    }

    // MARK: - System language detection

    // detectSystemLanguage returns a supported language without crashing
    registerTest("test_detectSystemLanguage_返回支援語言") {
        let detected = LocalizationManager.detectSystemLanguage()
        try assertTrue(Language.allCases.contains(detected), "檢測結果應為支援的語言")
    }
}
