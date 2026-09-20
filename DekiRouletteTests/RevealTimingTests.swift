import Testing
@testable import DekiRoulette

struct RevealTimingTests {
    @Test func 遅延は添字に比例する() {
        #expect(RevealTiming.delay(index: 0, reducedMotion: false) == 0)
        #expect(RevealTiming.delay(index: 3, reducedMotion: false) == 3 * Config.orderRevealStep)
    }

    @Test func 動きを減らす設定では遅延なし() {
        #expect(RevealTiming.delay(index: 5, reducedMotion: true) == 0)
        #expect(RevealTiming.duration(count: 24, reducedMotion: true) == Config.reducedMotionRevealDuration)
    }

    @Test func 演出の長さは最後の行が出終わる時刻() {
        let expected = 3 * Config.orderRevealStep + Config.revealAnimationDuration
        #expect(abs(RevealTiming.duration(count: 4, reducedMotion: false) - expected) < 1e-9)
    }
}
