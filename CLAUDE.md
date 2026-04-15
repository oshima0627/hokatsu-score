# 保活スコア計算アプリ（hokatsu-score）

## プロジェクト概要

沖縄県南部の認可保育園入園選考に使われる「保育指数（点数）」を計算できるAndroidアプリ。
無料・広告収益モデル（AdMob）。AIなし。シンプルで実用的なツールアプリ。

> 「**保活**」＝ 保育園入園を希望する家庭が、希望園に入るために行う情報収集・申請準備等の活動の通称。

ライセンス：[LICENSE](./LICENSE) を参照。

-----

## ドキュメント目次

詳細仕様は `docs/` 配下に分割しています。

| ドキュメント                                            | 内容                                  |
|---------------------------------------------------|-------------------------------------|
| [docs/architecture.md](./docs/architecture.md)    | ディレクトリ構成・データモデル・スコアリング設計（抽象クラス／ファクトリ） |
| [docs/ui-spec.md](./docs/ui-spec.md)              | 画面フロー・入力フォーム・結果画面・シェア書式・アクセシビリティ    |
| [docs/admob-and-privacy.md](./docs/admob-and-privacy.md) | 広告ポリシー・プライバシー・データセーフティ・年度更新運用       |
| [docs/testing.md](./docs/testing.md)              | スコア計算ユニットテスト方針・境界値表                |
| [docs/workflow.md](./docs/workflow.md)            | ブランチ運用・main マージ手順                  |
| [docs/scoring/README.md](./docs/scoring/README.md)| 自治体別スコアリングルール一覧と公式資料URL            |
| [docs/scoring/naha-city.md](./docs/scoring/naha-city.md) | 那覇市の詳細配点と実装例                       |

-----

## 技術スタック

| 項目         | 採用技術                                        |
|------------|---------------------------------------------|
| フレームワーク    | Flutter（Dart）                               |
| 広告         | google_mobile_ads（AdMob）                    |
| 状態管理       | Riverpod（flutter_riverpod）                  |
| ローカル保存     | flutter_secure_storage（暗号化）                 |
| ターゲット      | Android（Google Play）                        |
| minSdk     | API 23（Android 6.0）※`flutter_secure_storage` 安定動作要件 |
| targetSdk  | API 36（Android 16）※Google Play提出必須          |
| compileSdk | API 36                                      |

> ⚠️ Google Playは2025年8月31日以降、新規アプリにtargetSdk 35必須、
> 2026年8月31日以降はtargetSdk 36必須となる予定。
> 本プロジェクトは2026年4月時点の新規開発のため、最初から `targetSdk 36` を採用する。
> `android/app/build.gradle` に明示すること。最新要件は事前にGoogle Play公式を確認のこと。

> ⚠️ `minSdk 23` は `flutter_secure_storage` の Android Keystore 連携が
> API 23以上で安定動作するため。API 21–22 を切り捨てる方針。

-----

## 対応自治体

### 【沖縄南部 本島】8市町（MVP対象）

| # | 自治体名 | 区分 | 人口規模    | 備考       |
|---|------|----|---------|----------|
| 1 | 那覇市  | 市  | 約31万人   | 県都・最優先   |
| 2 | 浦添市  | 市  | 約12万人   | 那覇隣接     |
| 3 | 豊見城市 | 市  | 約6.5万人  | 那覇南隣     |
| 4 | 糸満市  | 市  | 約6万人    | 本島最南端    |
| 5 | 南城市  | 市  | 約4.5万人  | 東海岸      |
| 6 | 南風原町 | 町  | 約4万人    | 那覇東隣・内陸  |
| 7 | 与那原町 | 町  | 約2万人    | 東海岸      |
| 8 | 八重瀬町 | 町  | 約3万人    | 南東部      |

### 【離島・遠隔地】将来対応（v2以降）

久米島町・粟国村・渡名喜村・座間味村・渡嘉敷村・南大東村・北大東村

> ⚠️ 離島は人口が少なく保活の競争が低いため、MVPでは本島8市町に絞る。
> 設計は将来追加できる構造にしておく（[docs/architecture.md](./docs/architecture.md) 参照）。

-----

## pubspec.yaml（主要依存）

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  google_mobile_ads: ^5.1.0
  flutter_secure_storage: ^9.2.2   # 要配慮個人情報の暗号化保存
  share_plus: ^10.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

> ⚠️ `shared_preferences` は要配慮個人情報を平文で保存してしまうため使用しない。
> 軽微な UI 設定（最後に選んだ自治体ID等）に限り `shared_preferences` を併用することは可。

-----

## android/app/build.gradle（SDK設定）

```gradle
android {
    compileSdk 36

    defaultConfig {
        applicationId "com.nexeedlab.hokatsu_score"
        minSdk 23
        targetSdk 36
        versionCode 1
        versionName "1.0.0"
    }
}
```

-----

## MVP スコープ

- [ ] 沖縄南部8市町の自治体選択画面（自治体ごと対応年度表示）
- [ ] ScoringRule 抽象クラス + ScoringRuleFactory の定義
- [ ] 那覇市の指数ロジック実装（基本指数＋調整指数フル対応）
- [ ] 残り7自治体の指数ロジック実装（各公式PDFを確認して実装）
- [ ] 父母それぞれの基本指数 + 調整指数の計算・結果表示
- [ ] テキストシェア機能
- [ ] AdMobバナー＆インタースティシャル広告（日本配信のみ、UMPなし）
- [ ] 設定画面：「保存データを削除」ボタン
- [ ] 免責文言の表示
- [ ] **スコア計算ユニットテスト**（自治体ごとに代表ケースを最低5件 + ゴールデン1件）
- [ ] **プライバシーポリシー作成と公開**（Google Play 必須）
- [ ] **データセーフティセクション記入**（Google Play Console）
- [ ] **ストア提出物**：アプリアイコン（512×512）、フィーチャーグラフィック（1024×500）、スクリーンショット最低2枚
- [ ] Google Playリリース（配信地域：日本のみ）

-----

## 将来的な拡張（v2以降）

- 離島自治体の追加（久米島町・粟国村など）
- 沖縄中部・北部への拡張
- 申請書類チェックリスト
- 保育園見学メモ機能
- ボーダーライン表示（過去の最低指数との比較）

-----

## 注意事項・免責

- 計算結果はあくまで目安であり、実際の選考結果を保証するものではない旨を画面上に必ず明記
- 各自治体の指数ルールは毎年更新される。ルールファイルに参照元URLと対象年度を `sourceUrl` / `fiscalYear` プロパティで記載すること
- 指数データは各自治体の公式ページ・入園案内を一次情報として使用すること
- 個人情報の取り扱い詳細：[docs/admob-and-privacy.md](./docs/admob-and-privacy.md)
