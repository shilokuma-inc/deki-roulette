import Foundation

/// ドメイン定数。Web 版 `src/config.ts` に対応する。
enum Config {
    static let spinDuration: TimeInterval = 4.5

    /// アニメーション完了コールバックが呼ばれない環境（バックグラウンド等）向けの保険。
    static let spinFallback: TimeInterval = spinDuration + 0.6
    static let reducedMotionSpinDuration: TimeInterval = 0.32

    static let minItems = 2
    static let maxItems = 24
    static let maxLabelLength = 20

    /// 当たり指定の隠しジェスチャ。短すぎると通常のタップで誤爆する。
    static let longPressDuration: TimeInterval = 0.6

    /// 指定直後だけ印を見せる時間。以降はリストに触れない限り痕跡を残さない。
    static let targetHintDuration: TimeInterval = 1.6

    /// 順番の結果を 1 件ずつ出すときの間隔。
    static let orderRevealStep: TimeInterval = 0.16

    /// 結果 1 件が現れるアニメーションの長さ。演出の終了時刻の計算に使う。
    static let revealAnimationDuration: TimeInterval = 0.36

    /// 視差効果を減らす設定のときは 1 件ずつ出さないので、演出はこの時間で終わる。
    static let reducedMotionRevealDuration: TimeInterval = 0.2

    /// コピーできたことを伝える表示を出しておく時間。
    static let copyFeedbackDuration: TimeInterval = 1.8

    /// スピンのイージング（Web 版 `SPIN_EASING`）。`Theme.spinAnimation` と、クリック音の時刻の逆算の両方で使う。
    static let spinEasing = CubicBezierCurve(0.15, 0.85, 0.3, 1)

    /// 追加の入力欄が伸びる行数の上限。改行区切りの貼り付けはこの行数を超えるとスクロールする。
    static let bulkInputVisibleLines = 5

    // MARK: 効果音

    /// 効果音の ON/OFF を保存する `UserDefaults` のキー。未設定なら ON。
    static let soundEnabledKey = "soundEnabled"

    /// スピン中にクリック音を鳴らす最短間隔。序盤は境目を越える間隔がこれより短いので間引く。
    static let clickMinInterval: TimeInterval = 0.032

    /// クリック音の音量。密に重なっても耳に刺さらないところまで下げてある。
    static let clickGain: Float = 0.7
}
