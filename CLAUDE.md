# CLAUDE.md

このファイルは Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## ビルド・テストコマンド

```bash
# project.yml 変更後に Xcode プロジェクトを再生成
xcodegen generate

# ビルド（シミュレータ）
xcodebuild build -project EuroTravelTranslate.xcodeproj -scheme EuroTravelTranslate \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# テスト実行
xcodebuild test -project EuroTravelTranslate.xcodeproj -scheme EuroTravelTranslateTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# 通常のワークフロー: 再生成 → ビルド
xcodegen generate && xcodebuild build -project EuroTravelTranslate.xcodeproj \
  -scheme EuroTravelTranslate -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

テストは XCTest ではなく Apple Swift Testing フレームワーク（`@Test`, `@Suite`, `#expect`）を使用。テストターゲットは `TEST_HOST`/`BUNDLE_LOADER` 設定により、テスト内の `Bundle.main` がホストアプリのバンドルを指す。

## アーキテクチャ

**MVVM**、iOS 26.0 / Swift 6.0 strict concurrency、外部依存ゼロ。

```
View (SwiftUI) → ViewModel (@Observable @MainActor) → SwiftData
```

3タブ構成: **Convertisseur**（EUR→JPY換算 + テンキー）、**支出**（支出記録・カテゴリ別集計）、**設定**（為替レート・旅行期間・データ管理）。

### デザインシステム: Liquid Glass

フランス三色旗をモチーフにしたカラーテーマ。

- **背景**: MeshGradient で上部=フレンチブルー → 中央=クリームホワイト → 下部=ソフトローズの三色旗フロー
- **カードスタイル**: `.ultraThinMaterial` / `.thinMaterial` + 白オーバーレイのフロストガラス効果
- **トークン定義**: `LiquidGlassTokens.swift`（`Glass.*`）に色・角丸・アニメーション値を集約
- **ボタンスタイル**: `LiquidGlass.swift` に `.glass()`, `.glassKey()`, `.glassCategory()` を定義
- **アクセント色**: フレンチブルー（`Glass.accent`）をメイン、フレンチレッド（`Glass.accentRed`）をアクション強調に使用

### サービス層

- `LocationService` / `POIResolver`: 位置情報からカテゴリ提案
- `CategorySuggester`: 支出カテゴリの推定
- `CurrencyDetector`: 通貨検出ヘルパー
- `AppLogger`: `Logger` ベースのログ出力

## 注意点・ハマりどころ

- **project.yml が設定の正**: `.xcodeproj` を直接編集せず、変更後は必ず `xcodegen generate` を実行する。
- **`.foregroundStyle(.accentColor)`** はコンパイルエラーになる。`.foregroundStyle(Color.accentColor)` を使う。
- **ForEach と配列**: `ForEach(array, id: \.rawValue) { (lang: LanguageCode) in` のように明示的な型注釈を付けないと、Swift コンパイラが `Binding` オーバーロードを選択してしまう。
