import SwiftUI

/// 配色・書体・アニメーション。Web 版 `tailwind.config.ts` の `theme.extend` に対応する。
enum Theme {
    static let ink900 = Color(hex: 0x17111F)
    static let ink800 = Color(hex: 0x1F1829)
    static let ink700 = Color(hex: 0x2A2138)
    static let ink600 = Color(hex: 0x3A2F4C)
    static let ink500 = Color(hex: 0x4C3F62)
    static let ink400 = Color(hex: 0x7D6D96)
    static let ivory = Color(hex: 0xF5EFE6)
    static let muted = Color(hex: 0xA99BBD)

    /// 結果表示（順番決めは 1 位）とフォーカスリング専用。
    static let gold = Color(hex: 0xFFC94A)

    /// スピン・並べ替えの操作専用。
    static let flare = Color(hex: 0xFF4E63)

    /// 彩度と明度を揃えた 10 色。ラベルとセパレータを地色（インク）で描くため、
    /// どのスライスも暗色テキストで 4.5:1 を超える明るさに寄せてある。
    /// 指定中の印には専用色を使わず、この色をそのまま流用する。
    static let sliceColors: [Color] = [
        0xFF8080, 0xFFA366, 0xF2CE5C, 0xA3DB6B, 0x5FD6A8,
        0x5CC9E0, 0x7BAEF5, 0xA48CF0, 0xCE8CEE, 0xFF85C0,
    ].map { Color(hex: $0) }

    static func sliceColor(at index: Int) -> Color {
        sliceColors[index % sliceColors.count]
    }

    static let spinAnimation = Animation.timingCurve(0.15, 0.85, 0.3, 1, duration: Config.spinDuration)

    /// 結果が現れる演出。両画面で使い回す。
    static let revealAnimation = Animation.timingCurve(0.2, 0.9, 0.3, 1, duration: Config.revealAnimationDuration)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

/// 結果が現れる演出。Web 版の `animate-reveal` に対応する。
struct RevealModifier: ViewModifier {
    let shown: Bool

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 6)
            .scaleEffect(shown ? 1 : 0.96)
    }
}

/// 表示された時点から `delay` 後に現れる。`reducedMotion` のときは即座に出す。
struct RevealOnAppear: ViewModifier {
    let delay: TimeInterval
    let reducedMotion: Bool
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .modifier(RevealModifier(shown: shown))
            .onAppear {
                if reducedMotion {
                    shown = true
                } else {
                    withAnimation(Theme.revealAnimation.delay(delay)) { shown = true }
                }
            }
    }
}

extension View {
    func revealOnAppear(delay: TimeInterval = 0, reducedMotion: Bool) -> some View {
        modifier(RevealOnAppear(delay: delay, reducedMotion: reducedMotion))
    }
}
