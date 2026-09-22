import Foundation
import Observation

/// スピンの結果。結果表示の色を止まったスライスに合わせるため、
/// ラベルだけでなく盤面上の添字も持つ（同じラベルの項目があっても色が一意に決まる）。
struct SpinOutcome: Equatable {
    let index: Int
    let label: String
}

/// 項目・当たり指定・回転・結果のステートとスピンロジック。Web 版 `useRoulette` に対応する。
@MainActor
@Observable
final class RouletteModel {
    private(set) var items: [Item]
    private(set) var targetId: UUID?
    private(set) var spinning = false
    private(set) var outcome: SpinOutcome?

    /// 累積の回転角（度）。View がアニメーションの中で書き込む。
    var rotation: Double = 0

    /// スピン中にクリック音を鳴らす時刻（開始からの秒）。View が再生に渡す。
    private(set) var clickTimes: [TimeInterval] = []

    private var pendingOutcome: SpinOutcome?
    private var fallbackTask: Task<Void, Never>?

    init(items: [Item]) {
        self.items = items
    }

    var canSpin: Bool { !spinning && items.count >= Config.minItems }
    var atCapacity: Bool { items.count >= Config.maxItems }

    var result: String? { outcome?.label }

    var marks: Marks {
        guard let targetId else { return [:] }
        return [targetId: .target]
    }

    func addItem(_ raw: String) {
        let label = ItemLabel.normalize(raw)
        guard !label.isEmpty, !atCapacity else { return }
        items.append(Item(label: label))
        outcome = nil
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        if targetId == id { targetId = nil }
        outcome = nil
    }

    /// 長押しで当たりの指定と解除を切り替える。
    func toggleTarget(id: UUID) {
        targetId = targetId == id ? nil : id
        outcome = nil
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
        pendingOutcome = SpinOutcome(index: targetIndex, label: items[targetIndex].label)
        outcome = nil
        spinning = true

        // 補間中の角度は observable でないので、境目を越える時刻を先に求めておく。
        // 動きを減らす設定では盤面が回らないので鳴らさない
        clickTimes = reducedMotion ? [] : SpinTicks.boundaryCrossings(
            from: rotation,
            to: next,
            count: items.count,
            duration: Config.spinDuration,
            easing: Config.spinEasing,
            minInterval: Config.clickMinInterval
        )

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
        guard let pendingOutcome else { return }
        outcome = pendingOutcome
        self.pendingOutcome = nil
    }
}
