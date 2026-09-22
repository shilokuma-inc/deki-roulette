import SwiftUI

struct OrderScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    let model: OrderModel
    @AppStorage(Config.hapticsEnabledKey) private var hapticsEnabled = true

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
                    onAdd: { model.addItems($0) },
                    onRemove: { model.removeItem(id: $0) },
                    onLongPress: { model.cycleMark(id: $0) }
                )
                .frame(maxWidth: sizeClass == .regular ? 320 : .infinity)
            }
        }
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
                // 演出が終わって結果が出ている間だけ出す。結果が変わると作り直されるので
                // 「コピーしました」も自然に戻る
                if let ordered = model.ordered, !model.revealing {
                    let text = ResultText.order(ordered.map(\.label))
                    ResultActions(copyText: text, shareText: ResultText.share(text, appName: L10n.appName))
                        .id(model.resultId)
                }
            }
            .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OrderScreen(model: OrderModel(items: ItemLabel.makeItems(L10n.orderDefaultItems)))
}
