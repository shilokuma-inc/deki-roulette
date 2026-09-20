import Foundation

enum ItemLabel {
    /// 連続する空白を 1 つに潰し、前後を落として上限で切る。Web 版 `normalizeLabel` と同じ規則。
    static func normalize(_ raw: String) -> String {
        let collapsed = raw
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
        return String(collapsed.prefix(Config.maxLabelLength))
    }

    static func makeItems(_ labels: [String]) -> [Item] {
        labels.map { Item(label: $0) }
    }
}
