import SwiftUI

/// 項目の追加・削除・隠しジェスチャの受け口と、印の表示制御。両画面で共有する。
struct ItemListView: View {
    let items: [Item]
    let marks: Marks
    /// 演出中。入力と隠しジェスチャを止める。
    let busy: Bool
    /// 印を無条件に伏せる。演出中と結果表示中に立てる。
    let concealMarks: Bool
    let atCapacity: Bool
    let onAdd: (String) -> Void
    let onRemove: (UUID) -> Void
    let onLongPress: (UUID) -> Void

    @State private var input = ""
    @State private var pressingCount = 0
    @State private var hinting = false
    @State private var hintTask: Task<Void, Never>?
    @FocusState private var inputFocused: Bool
    /// 画面収録・ミラーリング中は相手側にも印が映るので伏せる。無ければ（Preview 等）キャプチャ無しとみなす。
    @Environment(ScreenCaptureMonitor.self) private var screenCapture: ScreenCaptureMonitor?

    private var trimmed: String { input.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var inputDisabled: Bool { busy || atCapacity }

    /// 指定した本人だけが確認できればよいので、印は項目に触れている間と
    /// 指定直後だけ出す。演出中と結果表示中、画面がキャプチャされている間は無条件で伏せる。
    private var revealMarks: Bool {
        MarkVisibility.reveals(
            concealed: concealMarks,
            captured: screenCapture?.isCaptured ?? false,
            pressing: pressingCount > 0,
            hinting: hinting
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            addForm
            if items.isEmpty {
                emptyState
            } else {
                rows
            }
            footnotes
        }
        .onDisappear { hintTask?.cancel() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(L10n.itemListTitle)
                .font(.callout.weight(.bold))
                .foregroundStyle(Theme.ivory)
            Spacer()
            Text(L10n.itemCount(items.count, Config.maxItems))
                .font(.caption.monospacedDigit())
                .foregroundStyle(Theme.muted)
        }
    }

    private var addForm: some View {
        HStack(spacing: 8) {
            TextField(L10n.addPlaceholder, text: $input)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .submitLabel(.done)
                .onSubmit(handleAdd)
                .onChange(of: input) { _, newValue in
                    if newValue.count > Config.maxLabelLength {
                        input = String(newValue.prefix(Config.maxLabelLength))
                    }
                }
                .disabled(inputDisabled)
                .font(.subheadline)
                .foregroundStyle(Theme.ivory)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Theme.ink800, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(inputFocused ? Theme.ink400 : Theme.ink600, lineWidth: 1)
                )
                .opacity(inputDisabled ? 0.4 : 1)

            Button(action: handleAdd) {
                Text(L10n.addButton)
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .foregroundStyle(inputDisabled || trimmed.isEmpty ? Theme.muted.opacity(0.6) : Theme.ivory)
            .background(inputDisabled || trimmed.isEmpty ? Theme.ink800 : Theme.ink700, in: .rect(cornerRadius: 12))
            .disabled(inputDisabled || trimmed.isEmpty)
        }
    }

    private var emptyState: some View {
        Text(L10n.emptyList)
            .font(.subheadline)
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.ink600, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
    }

    private var rows: some View {
        LazyVStack(spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let mark = marks[item.id]
                ItemRow(
                    item: item,
                    color: Theme.sliceAccent(at: index),
                    mark: mark,
                    showMark: revealMarks && mark != nil,
                    busy: busy,
                    onPressingChanged: { pressing in pressingCount += pressing ? 1 : -1 },
                    onLongPress: { handleLongPress(item.id) },
                    onRemove: { onRemove(item.id) }
                )
            }
        }
    }

    @ViewBuilder
    private var footnotes: some View {
        if items.count < Config.minItems {
            Text(L10n.needMoreItems)
                .font(.caption)
                .foregroundStyle(Theme.flareText)
        }
        if atCapacity {
            Text(L10n.atCapacity(Config.maxItems))
                .font(.caption)
                .foregroundStyle(Theme.muted)
        }
    }

    private func handleAdd() {
        guard !trimmed.isEmpty, !inputDisabled else { return }
        onAdd(trimmed)
        input = ""
    }

    private func handleLongPress(_ id: UUID) {
        onLongPress(id)
        hinting = true
        hintTask?.cancel()
        hintTask = Task {
            try? await Task.sleep(for: .seconds(Config.targetHintDuration))
            guard !Task.isCancelled else { return }
            hinting = false
        }
    }
}

private struct ItemRow: View {
    let item: Item
    let color: Color
    let mark: Mark?
    let showMark: Bool
    let busy: Bool
    let onPressingChanged: (Bool) -> Void
    let onLongPress: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 10) {
                MarkDot(color: color, mark: showMark ? mark : nil)
                Text(item.label)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ivory)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 0)
            }
            .padding(.leading, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            // 通常のタップでは何も起きない。長押しだけを拾うので、見ている人には
            // 「ただ項目に触れただけ」にしか映らない。
            .onLongPressGesture(
                minimumDuration: Config.longPressDuration,
                perform: { if !busy { onLongPress() } },
                onPressingChanged: onPressingChanged
            )
            // 印を伏せている間は選択中の読み上げも落とす。残すと指定先が伝わる。
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(showMark ? .isSelected : [])
            .accessibilityValue(showMark ? (mark.flatMap(L10n.markLabel) ?? "") : "")

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.ink400)
                    .frame(width: 32, height: 40)
            }
            .buttonStyle(.plain)
            .disabled(busy)
            .accessibilityLabel(L10n.removeAccessibilityLabel(item.label))
            .padding(.trailing, 6)
        }
        .background(Theme.ink800, in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(showMark ? Theme.ink500 : Theme.ink700, lineWidth: 1)
        )
    }
}

#Preview("Marks visible") {
    ItemListView(
        items: ItemLabel.makeItems(["ラーメン", "カレー", "寿司", "焼肉"]),
        marks: [:],
        busy: false,
        concealMarks: false,
        atCapacity: false,
        onAdd: { _ in },
        onRemove: { _ in },
        onLongPress: { _ in }
    )
    .padding()
    .background(Theme.ink900)
}

#Preview("Empty") {
    ItemListView(
        items: [],
        marks: [:],
        busy: false,
        concealMarks: false,
        atCapacity: false,
        onAdd: { _ in },
        onRemove: { _ in },
        onLongPress: { _ in }
    )
    .padding()
    .background(Theme.ink900)
}
