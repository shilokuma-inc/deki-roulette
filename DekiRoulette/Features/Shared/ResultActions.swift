import SwiftUI

/// 結果の下に置く「結果をコピー」と「共有」。両画面で同じ見た目にする。
/// 「コピーしました」の表示は `Config.copyFeedbackDuration` の間だけ出す。
struct ResultActions: View {
    /// クリップボードに書き込む本文。
    let copyText: String
    /// 共有シートに渡す本文（アプリ名入り）。
    let shareText: String

    @State private var copied = false
    @State private var copyTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 8) {
            Button(action: copy) {
                ResultActionLabel(title: copied ? L10n.copied : L10n.copyResult)
            }
            .buttonStyle(.plain)

            // 開始ボタンの `flare` より目立たせないため、コピーと同じ控えめな見た目にする
            ShareLink(item: shareText) {
                ResultActionLabel(title: L10n.share, systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.plain)
        }
        .onDisappear { copyTask?.cancel() }
    }

    private func copy() {
        UIPasteboard.general.string = copyText
        copied = true
        copyTask?.cancel()
        copyTask = Task {
            try? await Task.sleep(for: .seconds(Config.copyFeedbackDuration))
            guard !Task.isCancelled else { return }
            copied = false
        }
    }
}

/// コピー・共有ボタンのラベル。`muted` の文字にカプセルの地と枠。
private struct ResultActionLabel: View {
    let title: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2.weight(.bold))
            }
            Text(title)
                .font(.caption.weight(.bold))
        }
        // 隣のラベルが「コピーしました」に変わって幅が動いても、こちらが省略記号で切れないようにする
        .fixedSize()
        .foregroundStyle(Theme.muted)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Theme.ink800, in: .capsule)
        .overlay(Capsule().strokeBorder(Theme.ink700, lineWidth: 1))
    }
}

#Preview {
    ResultActions(copyText: "結果: ラーメン", shareText: "結果: ラーメン\n\nデキレーレット")
        .padding()
        .background(Theme.ink900)
}
