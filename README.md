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

## CI/CD（GitHub Actions + Fastlane）

`main` ブランチへの push をトリガーに、テスト → スクリーンショット撮影 → ビルド → App Store 審査提出 → 自動リリースまでを一気通貫で実行する。

### パイプライン概要

```
git push main
  → GitHub Actions (macos-15)
    → xcodegen generate
    → fastlane release
      1. ユニットテスト実行
      2. UI テストでスクリーンショット撮影 + デバイスフレーム合成
      3. match でコード署名（App Store Distribution）
      4. ipa ビルド（ビルド番号は YYYYMMDDHHMM タイムスタンプ）
      5. App Store へアップロード + 審査提出 + 承認後自動リリース
```

### 初回セットアップ

以下の手順は一度だけ手動で実施する。

#### 1. リポジトリ作成

```bash
gh repo create hirotaka-iwasaki/euro-travel-translater --private --source=. --push
gh repo create hirotaka-iwasaki/ios-certificates --private
```

#### 2. App Store Connect API キー発行

[App Store Connect](https://appstoreconnect.apple.com) → 統合 → API キー → **App Manager** 権限でキーを作成し、`.p8` ファイルをダウンロード。

#### 3. Fastlane セットアップ

```bash
bundle install
bundle exec fastlane match appstore   # 証明書・プロファイルを ios-certificates リポに保存
```

#### 4. App Store Connect でアプリ登録

Bundle ID `art.minasehiro.EuroTravelTranslate` でアプリを作成し、以下を手動設定する（API 非対応のため Fastlane では自動化不可）:

- **価格**: 「価格および配信状況」→ 無料（¥0）に設定
- **App Privacy**: 「App のプライバシー」→ データ収集の回答を公開（本アプリは「大まかな位置情報」を「App の機能」目的で使用、ユーザーに紐付けない）

#### 5. GitHub Secrets 設定

リポジトリの Settings → Secrets and variables → Actions に以下を登録:

| Secret 名 | 内容 |
|---|---|
| `MATCH_GIT_URL` | `https://github.com/hirotaka-iwasaki/ios-certificates.git` |
| `MATCH_PASSWORD` | match の暗号化パスワード |
| `APP_STORE_CONNECT_API_KEY_ID` | API キー ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | `.p8` ファイルの中身（Base64） |
| `GIT_AUTH_TOKEN` | `repo` スコープ付き Personal Access Token |
| `KEYCHAIN_PASSWORD` | CI 用キーチェーンの任意のパスワード |

### Fastlane レーン一覧

```bash
bundle exec fastlane test          # ユニットテストのみ
bundle exec fastlane screenshots   # スクショ撮影 + フレーム合成
bundle exec fastlane beta          # TestFlight へアップロード
bundle exec fastlane release       # フルリリース（テスト→スクショ→ビルド→App Store 提出）
```

### App Store メタデータ

`fastlane/metadata/ja/` 配下のテキストファイルで Git 管理。`fastlane release` 時に自動反映される。

```
fastlane/metadata/
├── ja/
│   ├── name.txt              # アプリ名
│   ├── subtitle.txt          # サブタイトル
│   ├── description.txt       # 説明文
│   ├── keywords.txt          # 検索キーワード
│   ├── promotional_text.txt  # プロモーションテキスト
│   └── release_notes.txt     # リリースノート
├── review_information/
│   └── notes.txt             # 審査メモ
├── copyright.txt
└── primary_category.txt
```

### 注意事項

- **macOS ランナー無料枠**: 月 200 分（Free）/ 300 分（Pro）。1 リリースあたり 30〜45 分
- **Xcode バージョン**: ランナーに Xcode 26 が未提供の場合、`maxim-lobanov/setup-xcode` で対応するか、セルフホストランナーを検討
- **ビルド番号**: タイムスタンプ方式（`YYYYMMDDHHMM`）で常に単調増加。App Store Connect へのクエリ不要
