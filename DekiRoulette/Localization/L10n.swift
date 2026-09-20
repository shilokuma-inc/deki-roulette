import Foundation

/// 文言テーブルへの入口。実体は `Localizable.xcstrings`（日英）。
/// 表示言語は OS の設定に従う（設定アプリのアプリ別言語も有効）。アプリ内での切替は持たない。
enum L10n {
    static var title: String { tr("title") }
    static var tagline: String { tr("tagline") }
    static var spin: String { tr("spin") }
    static var spinning: String { tr("spinning") }
    static var resultPlaceholder: String { tr("resultPlaceholder") }
    static func resultAnnounce(_ label: String) -> String { fmt("resultAnnounce", label) }
    static var itemListTitle: String { tr("itemListTitle") }
    static var addPlaceholder: String { tr("addPlaceholder") }
    static var addButton: String { tr("addButton") }
    static var emptyList: String { tr("emptyList") }
    static var needMoreItems: String { tr("needMoreItems") }
    static func atCapacity(_ max: Int) -> String { fmt("atCapacity", max) }
    static func itemCount(_ count: Int, _ max: Int) -> String { fmt("itemCount", count, max) }
    static func removeAccessibilityLabel(_ label: String) -> String { fmt("removeAccessibilityLabel", label) }
    static var helpTitle: String { tr("helpTitle") }
    static var helpBasic: String { tr("helpBasic") }
    static var helpAimTitle: String { tr("helpAimTitle") }
    static var helpAim: String { tr("helpAim") }
    static var helpAimStealth: String { tr("helpAimStealth") }
    static var helpAimRandom: String { tr("helpAimRandom") }
    static var useCasesTitle: String { tr("useCasesTitle") }
    static var useCases: String { tr("useCases") }
    static var noticeTitle: String { tr("noticeTitle") }
    static var notice: String { tr("notice") }
    static var orderNavLabel: String { tr("orderNavLabel") }
    static var rouletteNavLabel: String { tr("rouletteNavLabel") }
    static var orderTitle: String { tr("orderTitle") }
    static var orderTagline: String { tr("orderTagline") }
    static var orderShuffle: String { tr("orderShuffle") }
    static var orderShuffling: String { tr("orderShuffling") }
    static var orderResultPlaceholder: String { tr("orderResultPlaceholder") }
    static var orderResultTitle: String { tr("orderResultTitle") }
    static func orderRankAccessibilityLabel(_ rank: Int) -> String { fmt("orderRankAccessibilityLabel", rank) }
    static var orderCopy: String { tr("orderCopy") }
    static var orderCopied: String { tr("orderCopied") }
    static var orderMarkFirst: String { tr("orderMarkFirst") }
    static var orderMarkLast: String { tr("orderMarkLast") }
    static var orderHelpBasic: String { tr("orderHelpBasic") }
    static var orderHelpAimTitle: String { tr("orderHelpAimTitle") }
    static var orderHelpAim: String { tr("orderHelpAim") }
    static var orderHelpAimStealth: String { tr("orderHelpAimStealth") }
    static var orderHelpAimRandom: String { tr("orderHelpAimRandom") }
    static var orderUseCases: String { tr("orderUseCases") }
    static var settingsTitle: String { tr("settingsTitle") }
    static var close: String { tr("close") }
    static var copyright: String { tr("copyright") }
    static var copyrightTitle: String { tr("copyrightTitle") }
    static var copyrightOwner: String { tr("copyrightOwner") }
    static var hapticsTitle: String { tr("hapticsTitle") }

    static var defaultItems: [String] { lines("defaultItems") }
    static var orderDefaultItems: [String] { lines("orderDefaultItems") }

    static func markLabel(_ mark: Mark) -> String? {
        switch mark {
        case .first: orderMarkFirst
        case .last: orderMarkLast
        case .target: nil
        }
    }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }

    private static func fmt(_ key: String, _ args: CVarArg...) -> String {
        String(format: tr(key), locale: .current, arguments: args)
    }

    private static func lines(_ key: String) -> [String] {
        tr(key).split(separator: "\n").map(String.init)
    }
}
