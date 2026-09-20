import SwiftUI

/// 横幅に余裕があるときは横並び、なければ縦積み。Web 版の `lg:flex-row` に対応する。
struct AdaptiveStack<Content: View>: View {
    let horizontal: Bool
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        if horizontal {
            HStack(alignment: .top, spacing: spacing) { content() }
        } else {
            VStack(spacing: spacing) { content() }
        }
    }
}
