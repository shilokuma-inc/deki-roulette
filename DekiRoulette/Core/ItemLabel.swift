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

    /// 改行で行に分け、行ごとに `normalize` を掛けて空行を除く。
    /// 改行区切りの文章を貼り付けてまとめて追加するときに使う。1 行の規則は `normalize` のまま変えない。
    static func splitLines(_ raw: String) -> [String] {
        raw.split(whereSeparator: \.isNewline)
            .map { normalize(String($0)) }
            .filter { !$0.isEmpty }
    }

    /// 入力中の文字列を行ごとに上限の文字数で切る。改行は保つ。
    /// 入力欄全体で切ると 2 行目以降が消えるため、`maxLength` 相当の制限は行単位に掛ける。
    static func clampLines(_ raw: String) -> String {
        raw.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
            .map { $0.prefix(Config.maxLabelLength) }
            .joined(separator: "\n")
    }
}
