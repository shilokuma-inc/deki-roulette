import SwiftUI

/// ヘッダ右上のアイコンから開く設定。いまは著作権表示だけを置く。
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 0)
                Text(L10n.copyright)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
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

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
        .fontDesign(.rounded)
}
