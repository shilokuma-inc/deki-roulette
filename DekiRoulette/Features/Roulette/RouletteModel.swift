import Foundation
import Observation

/// 項目・当たり指定・回転・結果のステートとスピンロジック。Web 版 `useRoulette` に対応する。
@MainActor
@Observable
final class RouletteModel {
    private(set) var items: [Item]
    private(set) var targetId: UUID?
    private(set) var spinning = false
    private(set) var result: String?

    /// 累積の回転角（度）。View がアニメーションの中で書き込む。
    var rotation: Double = 0

    private var pendingResult: String?
    private var fallbackTask: Task<Void, Never>?

    init(items: [Item]) {
        self.items = items
    }

    var canSpin: Bool { !spinning && items.count >= Config.minItems }
    var atCapacity: Bool { items.count >= Config.maxItems }

    var marks: Marks {
        guard let targetId else { return [:] }
        return [targetId: .target]
    }

    func addItem(_ raw: String) {
        let label = ItemLabel.normalize(raw)
        guard !label.isEmpty, !atCapacity else { return }
        items.append(Item(label: label))
        result = nil
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        if targetId == id { targetId = nil }
        result = nil
    }

    /// 長押しで当たりの指定と解除を切り替える。
    func toggleTarget(id: UUID) {
        targetId = targetId == id ? nil : id
        result = nil
    }

    /// スピンを開始し、盤面が止まるべき累積回転角を返す。回せないときは nil。
    /// 呼び出し側はこの値を `rotation` にアニメーション付きで反映し、
    /// アニメーション完了時に `finishSpin()` を呼ぶ。
    func beginSpin(reducedMotion: Bool) -> Double? {
        guard canSpin else { return nil }

        let targetIndex: Int
        if let targetId {
            guard let found = items.firstIndex(where: { $0.id == targetId }) else { return nil }
            targetIndex = found
        } else {
            targetIndex = Int.random(in: 0..<items.count)
        }

        let next = RouletteMath.nextRotation(current: rotation, targetIndex: targetIndex, count: items.count)
        pendingResult = items[targetIndex].label
        result = nil
        spinning = true

        // 完了コールバックが来ない環境（バックグラウンド等）向けの保険
        fallbackTask?.cancel()
        let wait = reducedMotion ? Config.reducedMotionSpinDuration : Config.spinFallback
        fallbackTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(wait))
            guard !Task.isCancelled else { return }
            self?.finishSpin()
        }
        return next
    }

    func finishSpin() {
        fallbackTask?.cancel()
        fallbackTask = nil
        spinning = false
        guard let pendingResult else { return }
        result = pendingResult
        self.pendingResult = nil
    }
}
