import SwiftUI

/// 両画面で共通の枠。ヘッダ・本文・フッターの折りたたみ。
struct PageFrame<Content: View, Help: View>: View {
    let title: String
    let tagline: String
    /// 演出中。開いたままの説明を畳む。
    let busy: Bool
    let useCases: String
    @ViewBuilder let help: () -> Help
    @ViewBuilder let content: () -> Content

    @State private var helpOpen = false
    @State private var settingsOpen = false
    @State private var useCasesOpen = false
    @State private var noticeOpen = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 40)
                content()
                footer
                    .padding(.top, 56)
            }
            .padding(.horizontal, Theme.Layout.pageHorizontalPadding)
            .padding(.vertical, 24)
            .frame(maxWidth: Theme.Layout.pageMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.ink900.ignoresSafeArea())
        .sheet(isPresented: $settingsOpen) { SettingsView() }
        // 開始した瞬間に畳む。人前で回すときに開きっぱなしを踏まないための保険
        .onChange(of: busy) { _, isBusy in
            if isBusy { helpOpen = false }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .tracking(-1)
                    .foregroundStyle(Theme.ivory)
                    .accessibilityAddTraits(.isHeader)
                Text(tagline)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
            settingsButton
        }
    }

    private var settingsButton: some View {
        Button {
            settingsOpen = true
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.muted)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.ink800))
                .overlay(Circle().strokeBorder(Theme.ink700))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.settingsTitle)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider().overlay(Theme.ink700)

            FooterDisclosure(title: L10n.helpTitle, isExpanded: $helpOpen) {
                help()
            }
            FooterDisclosure(title: L10n.useCasesTitle, isExpanded: $useCasesOpen) {
                Text(useCases)
            }
            FooterDisclosure(title: L10n.noticeTitle, isExpanded: $noticeOpen) {
                Text(L10n.notice)
            }
        }
        .font(.subheadline)
        .foregroundStyle(Theme.muted)
    }
}

private struct FooterDisclosure<Body: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder let body_: () -> Body

    init(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Body) {
        self.title = title
        self._isExpanded = isExpanded
        self.body_ = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    Text(title)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(Theme.ivory)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    body_()
                }
                .lineSpacing(3)
                .padding(.leading, 20)
            }
        }
    }
}

/// フッターの説明文で使う小見出し。
struct HelpHeading: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Theme.ivory)
            .padding(.top, 6)
    }
}
