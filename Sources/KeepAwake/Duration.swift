// Duration option data model
public struct Duration {
    /// String key for this option (display title is looked up via LocalizationManager)
    public let key: StringKey
    /// Duration in seconds
    public let seconds: Int

    // Six available duration options
    public static let options: [Duration] = [
        Duration(key: .duration5Min,  seconds: 300),
        Duration(key: .duration30Min, seconds: 1800),
        Duration(key: .duration1Hour, seconds: 3600),
        Duration(key: .duration2Hours, seconds: 7200),
        Duration(key: .duration3Hours, seconds: 10800),
        Duration(key: .duration5Hours, seconds: 18000)
    ]
}
