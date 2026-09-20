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

    /// 結果の行が現れた回数。1 件ごとに触覚を鳴らすトリガで、リセットしない。
    private(set) var revealTick = 0

    private var revealTask: Task<Void, Never>?
    private var tickTask: Task<Void, Never>?

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

        // 行が現れる時刻は View のアニメーション遅延と同じ式で決まるので、同じ時刻に刻む
        tickTask?.cancel()
        let ticks = HapticSchedule.revealTicks(count: items.count, reducedMotion: reducedMotion)
        tickTask = TickScheduler.run(at: ticks) { [weak self] in self?.revealTick += 1 }
    }
}
