# Euro Travel Translate (iOS) — 設計書（MVP → 旅行で実用）
対象期間: **2026/4/19〜2026/5/5（ヨーロッパ旅行）**  
対象端末: **iPhone 17 Pro**（この端末で動けばOK）  
目的: **自分が旅行中に使える、音声翻訳 + カメラ翻訳の軽量アプリ**を最短で作る（App Store公開は必須ではない）

---

## 1. ゴール / 非ゴール

### 1.1 ゴール（旅行で「使える」基準）
**音声翻訳モード（Voice）**
- 周囲の会話を **リアルタイムに文字起こし（現地語）**
- **日本語訳**を逐次表示（確定文単位）
- 別セクションで **返答例（現地語 + 英語）**を表示（まずは定型フレーズ方式でOK）
- 旅行中の利用を想定して、**不安定回線でも壊れない**（可能ならオフラインで最低限動く）

**カメラ翻訳モード（Camera）**
- アプリ内でカメラ起動
- 看板/メニュー等の文字を検出して、画面上に **日本語ラベル**を重ねて表示
- 完全AR置換ではなく、まずは **検出枠 + 日本語ラベル**で実用優先
- **Freeze（停止）**で読みやすくする

### 1.2 非ゴール（MVPではやらない）
- 複数端末同期、アカウント、クラウド保存
- 長文ドキュメント翻訳（PDF/WEBページ）
- “翻訳精度の最大化” を目的とした大規模モデル運用（自分用の実用ライン優先）
- ARで文字を置換して背景と馴染ませる（まずは枠＋ラベルでOK）
- 常時録音の保存（プライバシーリスクが高い）

---

## 2. 想定利用シーン
- レストランでの会話（注文、値段、アレルギー、支払い）
- 駅や観光地での案内表示（行き先、注意書き、営業時間）
- 簡単な会話の返答（聞き返し、依頼、ありがとう、分からない）

---

## 3. 技術方針（最短で作る）

### 3.1 コア方針
- **Apple純正フレームワーク中心**（実装量・依存関係を最小に）
- 翻訳/認識は **オンデバイス優先**（回線が無い/遅い場面を想定）
- “差し替え可能” な抽象化（Speech/Translation/OCRの選択肢を後から替えられる）

### 3.2 推奨スタック
- 言語: **Swift**
- UI: **SwiftUI**
- Concurrency: **async/await**（Swift Concurrency）
- 永続化: **SwiftData**（軽量に履歴を残す）
- 音声入力: **AVAudioEngine**
- 音声認識（STT）: **Speech.framework**（まずはこれで最短）
- 翻訳: **Translation framework（iOS 17.4+）**を第一候補
- カメラ文字検出:
  - 最短: **VisionKit DataScanner**
  - 追加の制御が必要なら: **Vision (VNRecognizeTextRequest)** を併用

### 3.3 フォールバック（保険）
- 言語/精度/オフラインの事情で不足がある場合のみ:
  - OCR: **Google ML Kit Text Recognition**
  - 翻訳: **Google ML Kit Translation**
- MVPでは導入しない（依存・容量・設定の手間が増えるため）。**必要になったらFeature Flagで追加**。

---

## 4. 画面設計（情報設計）

### 4.1 タブ構成
1. **Voice**（音声翻訳）
2. **Camera**（カメラ翻訳）
3. **Phrases**（定型フレーズブック）
4. **Settings**（言語 / オフライン準備 / デバッグ）

### 4.2 Voice 画面（要件 & UI）
**上 → 下**
- 入力言語（例: FR/DE/ES/IT）セレクタ（Autoも用意）
- 「聞き取り中」ステータス（録音開始/停止ボタン）
- セクションA: **現地語の文字起こし**
  - partial（途中経過）表示
  - final（確定）を履歴に積む
- セクションB: **日本語訳**
  - final文単位で翻訳して積む（partial翻訳は原則しない）
- セクションC: **返答例（現地語 + 英語）**
  - 3〜5件
  - 「丁寧/カジュアル」トグル
  - タップでコピー、長押しで読み上げ（TTS）
- 右上: 「履歴」ボタン（当日の会話ログ）

ワイヤーフレーム（概略）
```
┌──────────────────────────────┐
│ Voice  [Input: FR ▾]   [History] │
│ [● Listening]   [Stop]           │
├──────────────────────────────┤
│ Transcript (FR)                 │
│  ... partial ...                │
│  1) Bonjour ... (final)         │
│  2) ...                         │
├──────────────────────────────┤
│ 日本語訳                         │
│  1) こんにちは...                │
│  2) ...                         │
├──────────────────────────────┤
│ Reply Suggestions  (Polite ▾)   │
│  FR: ...      EN: ...   [Copy]  │
│  FR: ...      EN: ...   [Copy]  │
└──────────────────────────────┘
```

### 4.3 Camera 画面（要件 & UI）
- カメラプレビュー（全画面）
- 上部: 入力言語セレクタ（Auto/FR/DE/ES/IT…）
- 中央: 検出枠（矩形）＋日本語ラベル（枠の上 or 下）
- 下部: 操作
  - **Freeze**（停止/再開）
  - **Tap-to-Translate**（枠タップでその要素だけ翻訳）
  - **Save**（スクショ + 抽出テキスト + 翻訳を保存）

ワイヤーフレーム（概略）
```
┌──────────────────────────────┐
│ Camera [Input: Auto ▾]         │
│ ┌─────────────┐   JP: 営業時間 │
│ │  TEXT AREA   │                │
│ └─────────────┘                │
│                                 │
│ [Freeze]   [Tap Translate] [Save]│
└──────────────────────────────┘
```

### 4.4 Phrases 画面
- カテゴリ一覧（注文/道案内/支払い/謝罪/聞き返し…）
- 各カテゴリに「現地語 / 英語 / 日本語（意味）」を表示
- ワンタップ: コピー
- 長押し: 読み上げ（現地語）

### 4.5 Settings 画面
- 旅行で使う言語のプリセット（FR/DE/ES/IT など）
- 返答例スタイル（丁寧/カジュアル）
- オフライン準備チェック
  - 翻訳モデル（利用言語）が端末にある状態を促す
- ログ/デバッグ（開発中のみ）
  - STTのpartial頻度
  - OCRのFPS
  - 翻訳キャッシュ件数

---

## 5. アーキテクチャ（差し替え可能な設計）

### 5.1 全体構成（MVVM + UseCase）
- View（SwiftUI）
- ViewModel（状態管理/非同期処理の起点）
- UseCase（パイプライン処理：STT→分割→翻訳→提案）
- Services（Speech / Translation / OCR）
- Repository（SwiftData 永続化）

### 5.2 主要プロトコル（依存を切る）
**SpeechTranscriber**
- start/stop
- partial/finalをストリームで流す

**Translator**
- translate(text, sourceLang, targetLang) -> translatedText

**TextScanner**
- start/stop
- 検出されたテキスト要素（文字列＋バウンディングボックス）をストリームで流す

**ReplyEngine**
- input（最終文/日本語訳/状況）から返答候補を生成

> ここを抽象化しておくと「SpeechAnalyzerに差し替え」「ML Kitに差し替え」が小さな変更で済む。

---

## 6. データフロー詳細

### 6.1 Voice パイプライン
1. マイク音声取得（AVAudioEngine）
2. STT（Speech.framework）で partial/final を取得
3. final 文を **Segmenter** で整形（不要な重複除去/文末処理）
4. final 文のみ Translator に渡して日本語化
5. 翻訳結果を履歴に保存
6. ReplyEngine が **返答例（現地語 + 英語）**を提示

#### Segmenter（重要）
- STTは同じ内容を繰り返し返すことがあるため、**finalの重複排除**が必須
- 句読点や停止（無音）で文として確定させる（v1は簡易ルールでOK）

例ルール（v1）
- finalText を受け取ったら、前回finalTextと一致したら捨てる
- 前回より短い/同じなら捨てる（STTのブレ対策）
- 先頭/末尾の空白除去、連続スペースを1つに

### 6.2 翻訳キャッシュ
**同じテキストは何度も翻訳しない**（特にCameraで重要）
- キー: `sourceLang + "→" + targetLang + ":" + normalizedText`
- 値: translatedText
- LRU（最大 500 件程度）でメモリキャッシュ
- SwiftDataにも保存して、次回起動時も使えると便利（v1はメモリだけでもOK）

### 6.3 ReplyEngine（返答例の作り方）
#### v1（MVP推奨）: Phrasebook + キーワード分類
- 返答を「意図カテゴリ」に分けてJSONで同梱
- 入力（現地語/英語）からカテゴリを推定し、上位3カテゴリを返す
- 表示は「現地語 + 英語」。日本語は意味確認用に小さく出してもOK

カテゴリ例（最低限）
- ありがとう / すみません
- もう一度言ってください
- ゆっくり話してください
- 分かりません
- これは何ですか？
- いくらですか？
- 〜はありますか？
- 〜へ行きたい
- 支払い（カード/現金）
- アレルギー（〜は食べられません）

推定方法（v1）
- 文字列に含まれるキーワードでスコアリング（言語別）
- 例: "how much" / "combien" / "cuánto" / "quanto" → PRICE
- 例: "where" / "où" / "dónde" / "wo" → WHERE

> v2（余裕があれば）でLLM/オンデバイス生成に拡張できるが、MVPは定型が速い。

---

## 7. Camera パイプライン詳細

### 7.1 最短実装（VisionKit DataScanner）
- DataScanner からテキスト要素を取得（文字列 + 矩形）
- 文字列を正規化 → 翻訳（キャッシュ優先）
- SwiftUIのZStackで矩形座標にラベル描画

### 7.2 間引き（パフォーマンス要）
- OCR/スキャンは **毎フレームしない**
- 例: 10fps相当で間引く（タイマー/デバウンス）
- 「同じテキスト要素」は翻訳しない（キャッシュ）
- **Freeze**中はスキャン停止（バッテリー節約）

### 7.3 オーバーレイ座標
- Scannerが返す矩形（通常はビュー座標系）を、そのままSwiftUIの座標に合わせる
- 画面回転は想定しない（iPhone縦固定でもOK）
- 端末依存でズレる可能性があるので、デバッグ表示を用意
  - 枠の座標、ラベル位置（上/下）を切替

### 7.4 読みやすさ（UX）
- ラベルは **1〜2行**で切る（長いと邪魔）
- ラベル背景に半透明の板を敷く
- 同じ枠がチラつく場合は「安定化」
  - 同一文字列が連続N回検出されたら表示、など

---

## 8. データモデル（SwiftData）

### 8.1 言語
- `LanguageCode`（BCP-47想定）
  - `ja`, `en`, `fr`, `de`, `es`, `it`, `pt`, `nl` など
- v1は主要言語に限定（旅行ルートに合わせる）

### 8.2 エンティティ（案）
**TranscriptItem**
- id: UUID
- createdAt: Date
- sourceLang: String
- sourceText: String
- isFinal: Bool（保存はfinalのみ推奨）
- confidence: Double?（取れるなら）

**TranslationItem**
- id: UUID
- createdAt: Date
- sourceLang: String
- targetLang: String（= "ja"）
- sourceText: String
- translatedText: String
- mode: String（voice/camera/phrase）

**CameraCaptureItem**
- id: UUID
- createdAt: Date
- sourceLang: String
- extractedText: String（まとめ）
- translatedText: String（まとめ）
- imageData: Data?（スクショ保存するなら。容量注意）

**SettingsState**
- selectedInputLang: String（Autoなら "auto"）
- enabledLangs: [String]
- politeStyle: Bool
- ttsEnabled: Bool
- offlineReadyCheckedAt: Date?

---

## 9. 権限 & プライバシー

必要権限
- Camera
- Microphone
- Speech Recognition

注意
- 旅行中に許可ダイアログで詰まると致命的なので、**初回起動で事前に誘導**する
- 音声の保存はしない（MVPでは）
- 履歴も「テキストのみ」保存を推奨（必要なら削除ボタン）

---

## 10. エラーハンドリング（最低限）
- 権限拒否 → Settingsアプリへの導線
- STT開始失敗 → リトライ（1回）＋手動再開ボタン
- 翻訳失敗（モデル未準備/一時エラー） → 原文表示＋「後で翻訳」ボタン
- Cameraスキャン失敗 → FreezeモードでOCR（Vision）に切替（将来）

---

## 11. 実装タスク（Claude Code 用の分割）

### 11.1 リポジトリ初期化
- Xcode新規 iOS App（SwiftUI）
- SwiftData導入
- タブUI作成（Voice/Camera/Phrases/Settings）

### 11.2 Voice MVP
- SpeechTranscriber（Speech.framework）
- ViewModel（録音開始/停止、partial表示、final受け取り）
- Segmenter（重複排除）
- Translator（Apple Translation）
- 履歴保存（SwiftData）
- UI表示（Transcript / 日本語訳）

### 11.3 ReplyEngine v1
- Phrasebook JSON同梱
- キーワード分類（言語別辞書）
- 返答例表示、Copy、TTS（任意）

### 11.4 Camera MVP
- TextScanner（VisionKit DataScanner）
- オーバーレイ描画（枠＋日本語ラベル）
- Freeze / Save

### 11.5 Settings
- 言語プリセット
- 返答スタイル
- オフライン準備チェック（v1はUIだけでもOK）

---

## 12. テスト計画（MVP）
ユニットテスト
- Segmenter（重複排除/正規化）
- TranslationCache（キー生成/ヒット率）
- ReplyEngine（カテゴリ推定）

手動テスト（旅行前に必須）
- 空港やカフェで実際にVoiceを回す（騒音下）
- Cameraでメニュー・看板をスキャン（暗所/反射）
- オフライン（機内モード）での挙動確認
- バッテリー消費（30分連続運用）

---

## 13. 未来拡張（旅行後でもOK）
- 言語自動推定（Autoの精度改善）
- 返答例 v2（生成/オンデバイスモデル）
- Cameraの安定化（トラッキング、AR的馴染ませ）
- 旅行ログとして日別にまとめる（場所/時間）

---

## 14. 参考（公式ドキュメント）
（実装時に参照するリンク。必要に応じて最新版を確認）
- Speech: Recognizing speech in live audio  
  https://developer.apple.com/documentation/speech/recognizing-speech-in-live-audio
- Vision: Recognizing text in images  
  https://developer.apple.com/documentation/vision/recognizing-text-in-images
- WWDC: Translate your app with the Translation framework  
  https://developer.apple.com/videos/play/wwdc2024/10117/
- WWDC: VisionKit DataScanner / Live Text関連（セッション）  
  https://developer.apple.com/videos/play/wwdc2022/10026/

---

## 付録A: Phrasebook JSON スキーマ（案）
`Resources/phrasebook.json`

```json
{
  "version": 1,
  "categories": [
    {
      "id": "PRICE",
      "label_ja": "値段を聞く",
      "phrases": [
        {
          "style": "polite",
          "ja_hint": "いくらですか？",
          "en": "How much is it?",
          "fr": "C'est combien ?",
          "de": "Wie viel kostet das?",
          "es": "¿Cuánto cuesta?",
          "it": "Quanto costa?"
        }
      ],
      "keywords": {
        "en": ["how much", "price", "cost"],
        "fr": ["combien", "prix"],
        "de": ["wie viel", "kostet", "preis"],
        "es": ["cuánto", "precio", "cuesta"],
        "it": ["quanto", "prezzo", "costa"]
      }
    }
  ]
}
```

---

## 付録B: 実装の基本ルール（Claude Code 運用）
- 1コミット = 1機能（Voice STT / Translation / Camera overlay…）
- 先に「動く最小」を通してから、最適化/美化
- 依存注入（protocol + implementation）で差し替えを担保
- ログは `Logger` を使い、SettingsでON/OFFできるように（開発中だけでも可）

---

以上。
