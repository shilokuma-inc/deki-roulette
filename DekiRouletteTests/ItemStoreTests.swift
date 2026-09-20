import Foundation
import Testing
@testable import DekiRoulette

/// `UserDefaults` の代わりにメモリへ書く保存先。
final class InMemoryStorage: ItemStorage {
    var values: [String: Data] = [:]

    func data(forKey key: String) -> Data? { values[key] }

    func setData(_ data: Data?, forKey key: String) {
        values[key] = data
    }
}

struct ItemStoreTests {
    private func makeStore(
        _ storage: InMemoryStorage = InMemoryStorage(),
        defaults: [String] = ["X", "Y"]
    ) -> ItemStore {
        ItemStore(key: .roulette, storage: storage, defaultLabels: { defaults })
    }

    @Test func 保存した項目はidとラベルごと戻る() {
        let store = makeStore()
        let items = ItemLabel.makeItems(["ラーメン", "カレー", "寿司"])
        store.save(items)
        #expect(store.loadSaved() == items)
        #expect(store.load() == items)
    }

    @Test func 保存データが無ければ初期項目() {
        let store = makeStore()
        #expect(store.loadSaved() == nil)
        #expect(store.load().map(\.label) == ["X", "Y"])
    }

    @Test func 初期項目は読むたびに評価する() {
        var labels = ["X"]
        let store = ItemStore(key: .order, storage: InMemoryStorage(), defaultLabels: { labels })
        #expect(store.load().map(\.label) == ["X"])
        labels = ["Y", "Z"]
        #expect(store.load().map(\.label) == ["Y", "Z"])
    }

    @Test func 空のリストも保存済みとして扱う() {
        let store = makeStore()
        store.save([])
        #expect(store.loadSaved() == [])
        #expect(store.load().isEmpty)
    }

    @Test func 壊れたデータは初期項目に戻す() {
        let storage = InMemoryStorage()
        let store = makeStore(storage)
        storage.values[ItemStore.Key.roulette.rawValue] = Data("not json".utf8)
        #expect(store.loadSaved() == nil)
        #expect(store.load().map(\.label) == ["X", "Y"])
    }

    @Test func 形の違うJSONは初期項目に戻す() {
        let storage = InMemoryStorage()
        let store = makeStore(storage)
        storage.values[ItemStore.Key.roulette.rawValue] = Data(#"{"items":[]}"#.utf8)
        #expect(store.loadSaved() == nil)
        storage.values[ItemStore.Key.roulette.rawValue] = Data(#"[{"label":"A"}]"#.utf8)
        #expect(store.loadSaved() == nil)
    }

    @Test func 消すと初期項目に戻る() {
        let store = makeStore()
        store.save(ItemLabel.makeItems(["A"]))
        store.clear()
        #expect(store.loadSaved() == nil)
        #expect(store.load().map(\.label) == ["X", "Y"])
    }

    @Test func 画面ごとに別のキーへ保存する() {
        let storage = InMemoryStorage()
        let roulette = ItemStore(key: .roulette, storage: storage, defaultLabels: { [] })
        let order = ItemStore(key: .order, storage: storage, defaultLabels: { [] })
        roulette.save(ItemLabel.makeItems(["A"]))
        order.save(ItemLabel.makeItems(["B"]))
        #expect(roulette.load().map(\.label) == ["A"])
        #expect(order.load().map(\.label) == ["B"])
    }

    @Test func 読み込み時にラベルを正規化し空になったものは落とす() throws {
        let json = #"""
        [
          {"id":"00000000-0000-0000-0000-000000000001","label":"  A   B  "},
          {"id":"00000000-0000-0000-0000-000000000002","label":"   "},
          {"id":"00000000-0000-0000-0000-000000000003","label":"\#(String(repeating: "あ", count: 30))"}
        ]
        """#
        let items = try #require(ItemStore.decode(Data(json.utf8)))
        #expect(items.map(\.label) == ["A B", String(repeating: "あ", count: Config.maxLabelLength)])
    }

    @Test func idが重複する項目は最初のものだけ残す() throws {
        let json = #"""
        [
          {"id":"00000000-0000-0000-0000-000000000001","label":"A"},
          {"id":"00000000-0000-0000-0000-000000000001","label":"B"},
          {"id":"00000000-0000-0000-0000-000000000002","label":"C"}
        ]
        """#
        let items = try #require(ItemStore.decode(Data(json.utf8)))
        #expect(items.map(\.label) == ["A", "C"])
    }

    @Test func 上限を超える項目は切り捨てる() throws {
        let stored = (0..<(Config.maxItems + 5)).map { StoredItem(Item(label: "\($0)")) }
        let data = try JSONEncoder().encode(stored)
        let items = try #require(ItemStore.decode(data))
        #expect(items.count == Config.maxItems)
        #expect(items.last?.label == "\(Config.maxItems - 1)")
    }

    @Test func 保存形式はidとラベルだけ() throws {
        let item = Item(label: "A")
        let data = try #require(ItemStore.encode([item]))
        let object = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        let entry = try #require(object?.first)
        #expect(Set(entry.keys) == ["id", "label"])
        #expect(entry["id"] as? String == item.id.uuidString)
    }
}
