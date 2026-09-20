import SwiftUI

struct RouletteScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var model = RouletteModel(items: ItemLabel.makeItems(L10n.defaultItems))

    var body: some View {
        PageFrame(
            title: L10n.title,
            tagline: L10n.tagline,
            busy: model.spinning,
            useCases: L10n.useCases
        ) {
            Text(L10n.helpBasic)
            HelpHeading(text: L10n.helpAimTitle)
            Text(L10n.helpAim)
            Text(L10n.helpAimStealth)
            Text(L10n.helpAimRandom)
        } content: {
            AdaptiveStack(horizontal: sizeClass == .regular, spacing: 48) {
                wheelSection
                ItemListView(
                    items: model.items,
                    marks: model.marks,
                    busy: model.spinning,
                    concealMarks: model.spinning,
                    atCapacity: model.atCapacity,
                    onAdd: { model.addItem($0) },
                    onRemove: { model.removeItem(id: $0) },
                    onLongPress: { model.toggleTarget(id: $0) }
                )
                .frame(maxWidth: sizeClass == .regular ? 320 : .infinity)
            }
        }
        .onChange(of: model.result) { _, result in
            if let result {
                AccessibilityNotification.Announcement(L10n.resultAnnounce(result)).post()
            }
        }
    }

    private var wheelSection: some View {
        VStack(spacing: 24) {
            RouletteWheelView(items: model.items, rotation: model.rotation)
                .frame(maxWidth: 320)

            resultStatus
                .frame(height: 56)

            PrimaryActionButton(
                title: model.spinning ? L10n.spinning : L10n.spin,
                busy: model.spinning,
                enabled: model.canSpin,
                action: spin
            )
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var resultStatus: some View {
        if let result = model.result {
            Text(result)
                .font(.title3.weight(.black))
                .foregroundStyle(Theme.gold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.gold.opacity(0.1), in: .rect(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.gold.opacity(0.6), lineWidth: 1))
                .revealOnAppear(reducedMotion: reduceMotion)
                .id(result + "\(model.rotation)")
        } else {
            Text(model.spinning ? L10n.spinning : L10n.resultPlaceholder)
                .font(.caption)
                .foregroundStyle(Theme.muted)
        }
    }

    private func spin() {
        guard let next = model.beginSpin(reducedMotion: reduceMotion) else { return }
        if reduceMotion {
            // 動きを減らす設定では回さずに止まる。終了は保険のタイマーが担う
            model.rotation = next
        } else {
            withAnimation(Theme.spinAnimation) {
                model.rotation = next
            } completion: {
                model.finishSpin()
            }
        }
    }
}

#Preview {
    RouletteScreen()
}
