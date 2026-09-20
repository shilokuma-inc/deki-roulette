# deki-roulette

[デキレーレット](https://roulette.basekeita.com/) の iOS アプリ。
結果をユーザが事前に指定できる抽選アプリで、ルーレットと順番決めの 2 画面をタブで切り替える。

機能仕様は [`docs/SPEC.md`](docs/SPEC.md) が正。Web 版（React + Vite）から移植したもので、
プラットフォーム差分は同書の「iOS 版との対応」にまとめてある。Web 版のコードは b7b3936 以前の履歴にある。

## 環境

- Xcode 27 / iOS 17.0 以上
- Swift 6（strict concurrency: complete）
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（`brew install xcodegen`）

## セットアップ

`.xcodeproj` はコミットせず、`project.yml` から生成する。

```bash
xcodegen generate
open DekiRoulette.xcodeproj
```

コマンドラインでのビルドとテスト:

```bash
xcodebuild -project DekiRoulette.xcodeproj -scheme DekiRoulette \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

```bash
xcodebuild -project DekiRoulette.xcodeproj -scheme DekiRoulette \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

アプリアイコンは `scripts/make-icon.swift` で描いている。作り直すとき:

```bash
swift scripts/make-icon.swift DekiRoulette/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

## 構成

```
DekiRoulette/
  App/            DekiRouletteApp（入口）, RootView（2 タブ）
  Core/           Config（定数）, Item, ItemLabel（正規化）, Shuffle（Fisher-Yates と arrange）,
                  RouletteMath（回転角の計算）, RevealTiming（演出時間）
  Design/         Theme（配色・アニメーション）, reveal 演出
  Features/
    Roulette/     RouletteModel, RouletteWheelView（盤面）, RouletteScreen
    Order/        OrderModel, OrderResultView, OrderScreen
    Shared/       ItemListView（項目リストと隠しジェスチャ）, MarkDot（印）, PageFrame（共通枠）,
                  PrimaryActionButton, AdaptiveStack
  Localization/   Localizable.xcstrings（日英）, InfoPlist.xcstrings, L10n
  Resources/      Assets.xcassets
DekiRouletteTests/  Swift Testing によるユニットテスト
```

Web 版との対応:

| Web 版 | iOS 版 |
|---|---|
| `src/config.ts` | `Core/Config.swift` |
| `src/items.ts` | `Core/ItemLabel.swift` |
| `src/shuffle.ts` | `Core/Shuffle.swift` |
| `useRoulette.spin` の角度計算 | `Core/RouletteMath.swift` |
| `src/hooks/useRoulette.ts` | `Features/Roulette/RouletteModel.swift` |
| `src/hooks/useOrder.ts` | `Features/Order/OrderModel.swift` |
| `src/hooks/useLongPress.ts` | `ItemListView` の `onLongPressGesture` |
| `src/components/*` | `Features/*/…View.swift` |
| `src/i18n.ts` | `Localization/Localizable.xcstrings` + `L10n.swift` |
| `tailwind.config.ts` | `Design/Theme.swift` |

## ライセンス

MIT
