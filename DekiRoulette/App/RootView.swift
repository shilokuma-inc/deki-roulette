import SwiftUI

/// ルーレットと順番決めの 2 画面をタブで切り替える。Web 版のページ間リンクに対応する。
struct RootView: View {
    private enum Tab: Hashable {
        case roulette
        case order
    }

    @State private var selection: Tab = .roulette

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.ink800)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selection) {
            RouletteScreen()
                .tabItem { Label(L10n.rouletteNavLabel, systemImage: "circle.circle") }
                .tag(Tab.roulette)
            OrderScreen()
                .tabItem { Label(L10n.orderNavLabel, systemImage: "list.number") }
                .tag(Tab.order)
        }
        .tint(Theme.ivory)
    }
}

#Preview {
    RootView()
        .fontDesign(.rounded)
}
