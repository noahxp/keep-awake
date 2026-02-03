// Supported language enumeration
public enum Language: String, CaseIterable {
    case en   = "en"
    case zhTW = "zh-TW"
    case zhCN = "zh-CN"
    case ja   = "ja"

    /// Native display name for the language (always shown in that language regardless of app locale)
    public var displayName: String {
        switch self {
        case .en:   return "English"
        case .zhTW: return "中文（繁體）"
        case .zhCN: return "中文（简体）"
        case .ja:   return "日本語"
        }
    }
}
