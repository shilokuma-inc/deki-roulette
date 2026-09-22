import Testing
@testable import DekiRoulette

struct ItemLabelTests {
    @Test func 前後の空白を落とし連続する空白を1つにする() {
        #expect(ItemLabel.normalize("  ラーメン   大盛り \n") == "ラーメン 大盛り")
    }

    @Test func 上限の文字数で切る() {
        let long = String(repeating: "あ", count: 30)
        #expect(ItemLabel.normalize(long).count == Config.maxLabelLength)
    }

    @Test func 空白だけなら空文字になる() {
        #expect(ItemLabel.normalize("   ").isEmpty)
    }

    @Test func makeItemsはラベルごとに別のIDを振る() {
        let items = ItemLabel.makeItems(["A", "B", "A"])
        #expect(items.map(\.label) == ["A", "B", "A"])
        #expect(Set(items.map(\.id)).count == 3)
    }

    @Test func splitLinesは改行で分けて行ごとに正規化し空行を除く() {
        #expect(ItemLabel.splitLines("田中\n 佐藤  太郎 \n\n\r\n鈴木\n") == ["田中", "佐藤 太郎", "鈴木"])
    }

    @Test func splitLinesは1行なら1件になる() {
        #expect(ItemLabel.splitLines("  ラーメン ") == ["ラーメン"])
        #expect(ItemLabel.splitLines("   \n  ").isEmpty)
    }

    @Test func splitLinesは行ごとに上限で切る() {
        let long = String(repeating: "あ", count: 30)
        let lines = ItemLabel.splitLines("\(long)\n\(long)")
        #expect(lines.count == 2)
        #expect(lines.allSatisfy { $0.count == Config.maxLabelLength })
    }

    @Test func clampLinesは改行を保ったまま行ごとに上限で切る() {
        let long = String(repeating: "あ", count: 30)
        let clamped = ItemLabel.clampLines("\(long)\n短い\n\n\(long)")
        #expect(clamped == String(repeating: "あ", count: 20) + "\n短い\n\n" + String(repeating: "あ", count: 20))
    }

    @Test func clampLinesは上限内の入力を変えない() {
        #expect(ItemLabel.clampLines("田中\n佐藤") == "田中\n佐藤")
        #expect(ItemLabel.clampLines("").isEmpty)
    }
}
