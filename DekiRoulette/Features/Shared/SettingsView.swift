import SwiftUI

/// ヘッダ右上のアイコンから開く設定。効果音の切り替えと著作権を置く。
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Config.soundEnabledKey) private var soundEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SettingsSection(title: L10n.soundTitle) {
                        Toggle(L10n.soundToggle, isOn: $soundEnabled)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ivory)
                            .tint(Theme.ivory)
                        Text(L10n.soundNote)
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                    }

                    SettingsSection(title: L10n.copyrightTitle) {
                        Text(L10n.copyrightOwner)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ivory)
                            .lineSpacing(3)
                        Text(L10n.copyright)
                            .font(.caption)
                            .foregroundStyle(Theme.muted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Theme.ink900.ignoresSafeArea())
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.close) { dismiss() }
                        .foregroundStyle(Theme.ivory)
                }
            }
            .toolbarBackground(Theme.ink800, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

/// 設定の 1 項目。見出しと、枠で囲んだ中身。
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.callout.weight(.bold))
                .foregroundStyle(Theme.ivory)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Theme.ink800, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.ink700, lineWidth: 1)
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
        .fontDesign(.rounded)
}
