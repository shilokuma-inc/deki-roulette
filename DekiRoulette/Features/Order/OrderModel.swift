import Foundation
import Observation

/// 項目・先頭末尾の指定・並べ替え結果のステートと演出時間の計算。Web 版 `useOrder` に対応する。
@MainActor
@Observable
final class OrderModel {
    private(set) var items: [Item]
    private(set) var firstId: UUID?
    private(set) var lastId: UUID?
    private(set) var ordered: [Item]?
    private(set) var revealing = false

    /// 結果ごとに変わる識別子。結果の行を作り直して演出をやり直すために使う。
    private(set) var resultId = UUID()

    private var revealTask: Task<Void, Never>?

    init(items: [Item]) {
        self.items = items
    }

    var canShuffle: Bool { !revealing && items.count >= Config.minItems }
    var atCapacity: Bool { items.count >= Config.maxItems }

    var marks: Marks {
        var next: Marks = [:]
        if let firstId { next[firstId] = .first }
        if let lastId { next[lastId] = .last }
        return next
    }

    func addItem(_ raw: String) {
        let label = ItemLabel.normalize(raw)
        guard !label.isEmpty, !atCapacity else { return }
        items.append(Item(label: label))
        ordered = nil
    }

    /// 複数のラベルをまとめて追加する。上限に収まらない分は切り捨て、追加できた件数を返す。
    @discardableResult
    func addItems(_ raws: [String]) -> Int {
        let labels = raws.map(ItemLabel.normalize).filter { !$0.isEmpty }
        let accepted = Array(labels.prefix(max(0, Config.maxItems - items.count)))
        guard !accepted.isEmpty else { return 0 }
        items.append(contentsOf: ItemLabel.makeItems(accepted))
        ordered = nil
        return accepted.count
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        if firstId == id { firstId = nil }
        if lastId == id { lastId = nil }
        ordered = nil
    }

    /// 長押しのたびに 先頭 → 末尾 → 解除 と回す。
    /// 先頭と末尾はそれぞれ 1 項目までなので、付け替えると前の指定は落ちる。
    func cycleMark(id: UUID) {
        if firstId == id {
            firstId = nil
            lastId = id
        } else if lastId == id {
            lastId = nil
        } else {
            firstId = id
        }
        ordered = nil
    }

    func shuffleItems(reducedMotion: Bool) {
        guard canShuffle else { return }
        ordered = Shuffler.arrange(items, firstId: firstId, lastId: lastId)
        resultId = UUID()
        revealing = true

        revealTask?.cancel()
        let wait = RevealTiming.duration(count: items.count, reducedMotion: reducedMotion)
        revealTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(wait))
            guard !Task.isCancelled else { return }
            self?.revealing = false
        }
    }
}
