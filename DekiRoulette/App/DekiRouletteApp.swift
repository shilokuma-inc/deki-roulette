import SwiftUI

@main
struct DekiRouletteApp: App {
    /// 画面収録・ミラーリングの状態。両画面の `ItemListView` が印を伏せる判断に使う。
    @State private var screenCapture = ScreenCaptureMonitor(source: UIScreenCaptureSource())

    var body: some Scene {
        WindowGroup {
            RootView()
                .fontDesign(.rounded)
                .environment(screenCapture)
        }
    }
}
