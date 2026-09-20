import Foundation

/// 順番決めの結果を 1 件ずつ出す演出の時間計算。Web 版 `useOrder` の `revealDelayMs` / `revealDurationMs` に対応する。
enum RevealTiming {
    static func delay(index: Int, reducedMotion: Bool) -> TimeInterval {
        reducedMotion ? 0 : Double(index) * Config.orderRevealStep
    }

    static func duration(count: Int, reducedMotion: Bool) -> TimeInterval {
        if reducedMotion { return Config.reducedMotionRevealDuration }
        return delay(index: max(count - 1, 0), reducedMotion: false) + Config.revealAnimationDuration
    }
}
