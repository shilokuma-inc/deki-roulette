import SwiftUI

struct OrderScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var model = OrderModel(items: ItemLabel.makeItems(L10n.orderDefaultItems))
    @AppStorage(Config.hapticsEnabledKey) private var hapticsEnabled = true

    // コピー済みかどうかは「どの結果をコピーしたか」から導く。
    @State private var copiedResultId: UUID?
    @State private var copyTask: Task<Void, Never>?

    private var copied: Bool { model.ordered != nil && copiedResultId == model.resultId }

    var body: some View {
        PageFrame(
            title: L10n.orderTitle,
            tagline: L10n.orderTagline,
            busy: model.revealing,
            useCases: L10n.orderUseCases
        ) {
            Text(L10n.orderHelpBasic)
            HelpHeading(text: L10n.orderHelpAimTitle)
            Text(L10n.orderHelpAim)
            Text(L10n.orderHelpAimStealth)
            Text(L10n.orderHelpAimRandom)
        } content: {
            AdaptiveStack(horizontal: sizeClass == .regular, spacing: 48) {
                resultSection
                ItemListView(
                    items: model.items,
                    marks: model.marks,
                    busy: model.revealing,
                    concealMarks: model.revealing || model.ordered != nil,
                    atCapacity: model.atCapacity,
                    onAdd: { model.addItem($0) },
                    onRemove: { model.removeItem(id: $0) },
                    onLongPress: { model.cycleMark(id: $0) }
                )
                .frame(maxWidth: sizeClass == .regular ? 320 : .infinity)
            }
        }
        .onDisappear { copyTask?.cancel() }
        // 触覚: 行が 1 件現れるごとの刻みと、全件そろった手応え。設定で OFF にできる
        .sensoryFeedback(trigger: model.revealTick) { _, _ in
            hapticsEnabled ? .selection : nil
        }
        .sensoryFeedback(trigger: model.revealing) { wasRevealing, revealing in
            hapticsEnabled && wasRevealing && !revealing ? .success : nil
        }
    }

    private var resultSection: some View {
        VStack(spacing: 24) {
            OrderResultView(
                ordered: model.ordered,
                resultId: model.resultId,
                revealing: model.revealing,
                reducedMotion: reduceMotion
            )

            PrimaryActionButton(
                title: model.revealing ? L10n.orderShuffling : L10n.orderShuffle,
                busy: model.revealing,
                enabled: model.canShuffle,
                action: { model.shuffleItems(reducedMotion: reduceMotion) }
            )

            ZStack {
                if model.ordered != nil && !model.revealing {
                    Button(action: copyResult) {
                        Text(copied ? L10n.orderCopied : L10n.orderCopy)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.muted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Theme.ink800, in: .capsule)
                            .overlay(Capsule().strokeBorder(Theme.ink700, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }

    private func copyResult() {
        guard let ordered = model.ordered else { return }
        UIPasteboard.general.string = ordered.enumerated()
            .map { "\($0.offset + 1). \($0.element.label)" }
            .joined(separator: "\n")
        copiedResultId = model.resultId
        copyTask?.cancel()
        copyTask = Task {
            try? await Task.sleep(for: .seconds(Config.copyFeedbackDuration))
            guard !Task.isCancelled else { return }
            copiedResultId = nil
        }
    }
}

#Preview {
    OrderScreen()
}
