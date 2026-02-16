# Euro Travel Translate

ヨーロッパ旅行（2026/4/19〜5/5）で使うための EUR→JPY 換算 & 支出管理 iOS アプリ。
フランス三色旗をモチーフにした Liquid Glass デザイン。

## 機能

### Convertisseur（通貨換算）
- テンキーでユーロ金額を入力、リアルタイムで円に換算
- ダブルタップでクリア
- 換算後そのまま支出を記録（カテゴリ・メモ付き）

### 支出管理
- 6カテゴリ（食事・交通・買物・宿泊・観光・その他）で支出を記録
- 日別グループ表示 & カテゴリ別集計バーチャート
- EUR / JPY 両建て表示

### 設定
- 為替レート（€1 = ¥?）のカスタム設定
- 旅行開始日の設定
- 支出データの一括削除

## 技術スタック

- **Swift 6.0** / **SwiftUI** / **iOS 26.0**
- **SwiftData** で支出・設定を永続化
- Apple 純正フレームワークのみ（外部依存ゼロ）

## セットアップ

```bash
# XcodeGen をインストール（未インストールの場合）
brew install xcodegen

# Xcode プロジェクトを生成
xcodegen generate

# Xcode で開く
open EuroTravelTranslate.xcodeproj
```

## ビルド & テスト

```bash
# ビルド
xcodebuild build -project EuroTravelTranslate.xcodeproj -scheme EuroTravelTranslate \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# テスト
xcodebuild test -project EuroTravelTranslate.xcodeproj -scheme EuroTravelTranslateTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
