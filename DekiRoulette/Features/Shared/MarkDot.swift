import SwiftUI

/// 項目の色見本。指定中は塗りを抜いてリングにする。位置も大きさも変えないので、
/// 気づいていない人にはただの色見本のままに見える。
/// 末尾指定だけは中心にも点を置いて先頭と見分けられるようにする。
struct MarkDot: View {
    let color: Color
    let mark: Mark?

    var body: some View {
        ZStack {
            if let mark {
                Circle().strokeBorder(color, lineWidth: 2)
                if mark == .last {
                    Circle().fill(color).frame(width: 4, height: 4)
                }
            } else {
                Circle().fill(color)
            }
        }
        .frame(width: 12, height: 12)
        .animation(.easeOut(duration: 0.15), value: mark)
        .accessibilityHidden(true)
    }
}
