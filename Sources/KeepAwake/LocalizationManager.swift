import Foundation

// UI string keys
public enum StringKey: Hashable {
    case duration5Min
    case duration30Min
    case duration1Hour
    case duration2Hours
    case duration3Hours
    case duration5Hours
    case autoLaunch     // Launch at login
    case quit           // Quit
    case language       // Language switching menu title
}

// Business class that manages internationalization and language switching
public final class LocalizationManager: ObservableObject {
    /// The current language
    @Published public var currentLanguage: Language

    // Full string table: [Language][StringKey] → localized string
    private static let table: [Language: [StringKey: String]] = [
        .en: [
            .duration5Min:  "5 Minutes",
            .duration30Min: "30 Minutes",
            .duration1Hour: "1 Hour",
            .duration2Hours: "2 Hours",
            .duration3Hours: "3 Hours",
            .duration5Hours: "5 Hours",
            .autoLaunch:    "Launch at Login",
            .quit:          "Quit",
            .language:      "Language",
        ],
        .zhTW: [
            .duration5Min:  "5 分鐘",
            .duration30Min: "30 分鐘",
            .duration1Hour: "1 小時",
            .duration2Hours: "2 小時",
            .duration3Hours: "3 小時",
            .duration5Hours: "5 小時",
            .autoLaunch:    "開機執行",
            .quit:          "結束",
            .language:      "語言",
        ],
        .zhCN: [
            .duration5Min:  "5 分钟",
            .duration30Min: "30 分钟",
            .duration1Hour: "1 小时",
            .duration2Hours: "2 小时",
            .duration3Hours: "3 小时",
            .duration5Hours: "5 小时",
            .autoLaunch:    "开机执行",
            .quit:          "退出",
            .language:      "语言",
        ],
        .ja: [
            .duration5Min:  "5分間",
            .duration30Min: "30分間",
            .duration1Hour: "1時間",
            .duration2Hours: "2時間",
            .duration3Hours: "3時間",
            .duration5Hours: "5時間",
            .autoLaunch:    "ログイン時に起動",
            .quit:          "終了",
            .language:      "言語",
        ],
    ]

    /// Detect a supported language from system locale; falls back to English if unsupported
    public static func detectSystemLanguage() -> Language {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        switch code {
        case "en": return .en
        case "zh":
            // zh requires region to distinguish Traditional from Simplified Chinese
            let region = Locale.current.language.region?.identifier ?? ""
            switch region {
            case "TW", "HK": return .zhTW
            case "CN":       return .zhCN
            default:         return .zhTW  // Default to Traditional Chinese when region is absent
            }
        case "ja": return .ja
        default:   return .en
        }
    }

    /// Default initializer: auto-detects system language
    public init() {
        self.currentLanguage = LocalizationManager.detectSystemLanguage()
    }

    /// Initializer with an explicit language (for testing)
    public init(language: Language) {
        self.currentLanguage = language
    }

    /// Manually switch language
    public func setLanguage(_ language: Language) {
        currentLanguage = language
    }

    /// Look up the string for the current language; falls back to English if the key is missing
    public func string(for key: StringKey) -> String {
        Self.table[currentLanguage]?[key] ?? Self.table[.en]?[key] ?? "\(key)"
    }
}
