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
}
