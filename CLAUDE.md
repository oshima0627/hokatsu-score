# 保活スコア計算アプリ（hokatsu-score）

## プロジェクト概要

沖縄県南部の認可保育園入園選考に使われる「保育指数（点数）」を計算できるAndroidアプリ。
無料・広告収益モデル（AdMob）。AIなし。シンプルで実用的なツールアプリ。

-----

## 技術スタック

|項目        |採用技術                              |
|----------|----------------------------------|
|フレームワーク   |Flutter（Dart）                     |
|広告        |google_mobile_ads（AdMob）          |
|状態管理      |Riverpod（flutter_riverpod）        |
|ローカル保存    |shared_preferences                |
|ターゲット     |Android（Google Play）              |
|minSdk    |API 21（Android 5.0）               |
|targetSdk |API 35（Android 15）※Google Play提出必須|
|compileSdk|API 35                            |


> ⚠️ Google Playは2025年8月31日以降、新規アプリにtargetSdk 35必須。
> `android/app/build.gradle` に明示すること。

-----

## 対応自治体

### 【沖縄南部 本島】8市町（MVP対象）

|#|自治体名|区分|人口規模  |備考     |
|-|----|--|------|-------|
|1|那覇市 |市 |約31万人 |県都・最優先 |
|2|浦添市 |市 |約12万人 |那覇隣接   |
|3|豊見城市|市 |約6.5万人|那覇南隣   |
|4|糸満市 |市 |約6万人  |本島最南端  |
|5|南城市 |市 |約4.5万人|東海岸    |
|6|南風原町|町 |約4万人  |那覇東隣・内陸|
|7|与那原町|町 |約2万人  |東海岸    |
|8|八重瀬町|町 |約3万人  |南東部    |

### 【離島・遠隔地】将来対応（v2以降）

久米島町・粟国村・渡名喜村・座間味村・渡嘉敷村・南大東村・北大東村

> ⚠️ 離島は人口が少なく保活の競争が低いため、MVPでは本島8市町に絞る。
> 設計は将来追加できる構造にしておく。

-----

## ディレクトリ構成

```
hokatsu-score/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── parent_profile.dart           # 保護者情報モデル（父 or 母）
│   │   ├── family_profile.dart           # 世帯情報モデル
│   │   └── score_result.dart             # 計算結果モデル
│   ├── providers/
│   │   └── score_provider.dart           # Riverpod状態管理
│   ├── screens/
│   │   ├── home_screen.dart              # トップ画面（自治体選択）
│   │   ├── parent_input_screen.dart      # 保護者情報入力（父・母共用）
│   │   ├── family_input_screen.dart      # 世帯状況入力（調整指数）
│   │   └── result_screen.dart            # 結果表示
│   ├── widgets/
│   │   ├── ad_banner_widget.dart         # AdMobバナー
│   │   └── score_card_widget.dart        # スコア表示カード
│   └── scoring/
│       ├── scoring_rule.dart             # 抽象クラス（共通インターフェース）
│       ├── naha_city.dart                # 那覇市
│       ├── urasoe_city.dart              # 浦添市
│       ├── tomigusuku_city.dart          # 豊見城市
│       ├── itoman_city.dart              # 糸満市
│       ├── nanjo_city.dart               # 南城市
│       ├── haebaru_town.dart             # 南風原町
│       ├── yonabaru_town.dart            # 与那原町
│       └── yaese_town.dart               # 八重瀬町
├── android/
│   └── app/
│       └── build.gradle
├── pubspec.yaml
└── CLAUDE.md
```

-----

## 画面フロー

```
ホーム画面（自治体選択）
  └─→ 保護者情報入力（父）
        └─→ 保護者情報入力（母）
              └─→ 世帯状況入力（調整指数）
                    └─→ 結果表示画面
                          └─→ シェアボタン（テキスト共有）
```

-----

## 機能仕様

### 1. 自治体選択画面

- 沖縄南部の8市町をリスト表示（地図イメージ付きが望ましい）
- 選択した自治体に応じて計算ロジックが切り替わる

-----

### 2. 家庭状況入力フォーム

#### 基本指数（父・母それぞれ入力）

|項目       |入力形式    |備考                                                             |
|---------|--------|---------------------------------------------------------------|
|就労状況     |選択肢     |就労中 / 採用予定 / 妊娠・産後 / 疾病・障害 / 介護中 / 就学・職業訓練 / 求職中 / 育休中 / みなし育休中|
|月の就労時間   |数値入力（時間）|那覇市は月64h/90h/120h/140h/160hで段階判定                               |
|障害の有無・等級 |選択肢     |身体/精神/療育手帳の級、障害年金等級                                            |
|介護の状況    |選択肢     |要介護1〜5、または介護証明書の区分                                             |
|育休対象児との関係|選択肢     |育休対象児以外の申込か否か                                                  |


> ⚠️ 那覇市の基本指数は「月の就労時間」単位で判定（月64h以上で15点〜月160h以上で30点）。
> 他自治体も同様の月間時間ベースが多いが、日数・時間の組み合わせで判定する自治体も存在する。
> 各自治体ルールファイルで解釈する。UIは共通入力、ロジックを分離すること。

#### 調整指数（世帯全体）

|項目               |入力形式    |備考                     |
|-----------------|--------|-----------------------|
|ひとり親世帯           |はい / いいえ|那覇市+50点（最大加算項目）        |
|ひとり親みなし（離婚調停中等）  |はい / いいえ|那覧市+35点                |
|18歳以下での出産（若年出産）  |はい / いいえ|那覇市+15点                |
|生活保護受給中          |はい / いいえ|那覇市+3点                 |
|市内認可保育所での就労（保育士等）|はい / いいえ|那覇市+50点（保育士）/ +20点（支援員）|
|育児休業から復帰予定       |はい / いいえ|那覇市+9点                 |
|障害者手帳保持かつ月64h以上就労|はい / いいえ|那覇市+5点                 |
|単身赴任（県外・離島）      |はい / いいえ|那覇市+5点                 |
|認可外保育施設を現在利用中    |はい / いいえ|那覇市+11点（条件あり）          |
|きょうだいが第1希望園に在園中  |はい / いいえ|那覇市+7点                 |
|きょうだい2名同時同園申込    |はい / いいえ|那覇市+6点                 |
|きょうだいに障害児あり      |はい / いいえ|那覇市+5点                 |
|地域型保育園卒園児        |はい / いいえ|那覇市+100点（優先）           |
|65歳未満の近居祖父母が保育可能 |はい / いいえ|多くの自治体で減点              |
|希望園入れない場合に育休延長許容 |はい / いいえ|那覇市−500点(実質辞退)         |
|保育料の滞納あり         |はい / いいえ|那覇市−20点                |

-----

### 3. 自治体別指数ルールの設計方針

#### 抽象クラス（scoring/scoring_rule.dart）

```dart
abstract class ScoringRule {
  String get municipalityName;

  /// 父または母1人分の基本指数を返す
  int calcBaseScore(ParentProfile parent);

  /// 世帯全体の調整指数を返す
  int calcAdjustScore(FamilyProfile family);

  /// 合計指数（父の基本 + 母の基本 + 調整）
  int calcTotalScore(FamilyProfile family) {
    return calcBaseScore(family.father) +
           calcBaseScore(family.mother) +
           calcAdjustScore(family);
  }
}
```

#### 那覇市 実装例（scoring/naha_city.dart）

> 参照：那覇市「令和8年度 保育所入所選考基準表」
> URL: https://www.city.naha.okinawa.jp/_res/projects/default_project/*page*/001/002/785/r8kijunnhyo.pdf

```dart
class NahaCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '那覇市';

  @override
  int calcBaseScore(ParentProfile parent) {
    switch (parent.workStatus) {
      case WorkStatus.employed:
        if (parent.monthlyWorkHours >= 160) return 30;
        if (parent.monthlyWorkHours >= 140) return 26;
        if (parent.monthlyWorkHours >= 120) return 22;
        if (parent.monthlyWorkHours >= 90)  return 19;
        if (parent.monthlyWorkHours >= 64)  return 15;
        return 0;
      case WorkStatus.employedProspect:    return 15;
      case WorkStatus.selfEmployedNoProof: return 9;
      case WorkStatus.pregnantMultiple:    return 23;
      case WorkStatus.pregnant:            return 18;
      case WorkStatus.hospitalizedBedridden: return 32;
      case WorkStatus.medicalTreatmentSerious: return 23;
      case WorkStatus.medicalTreatmentMild:    return 12;
      case WorkStatus.jobSeeking:          return 9;
      case WorkStatus.parentalLeave:       return 15;
      case WorkStatus.pseudoParentalLeave: return 7;
      // 障害・手帳は別メソッドで処理
      default: return 0;
    }
  }

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;
    if (family.isSingleParent) score += 50;
    else if (family.isPseudoSingleParent) score += 35;
    if (family.isYoungParent) score += 15;         // 18歳以下出産
    if (family.isOnWelfare) score += 3;
    if (family.isNurseryWorker) score += 50;        // 市内認可で保育士就労
    if (family.isChildcareSupporter) score += 20;   // 子育て支援員
    if (family.returningFromLeave) score += 9;
    if (family.hasDisabilityAndWorks) score += 5;
    if (family.isTransferredAway) score += 5;
    if (family.isUsingNinkagai) score += 11;
    if (family.siblingAtFirstChoiceNursery) score += 7;
    if (family.twoSiblingsApplyingSameNursery) score += 6;
    if (family.siblingHasDisability) score += 5;
    if (family.isGraduatingFromSmallNursery) score += 100;
    if (family.grandparentCanCare) score -= 3;       // 65歳未満近居祖父母
    if (family.acceptsLeaveExtension) score -= 500;  // 育休延長許容
    if (family.hasUnpaidFees) score -= 20;
    return score;
  }
}
```

#### 他自治体の実装方針

各自治体ファイルは同じ `ScoringRule` を継承して実装する。
指数PDFは各自治体の公式サイトから取得し、URLとバージョン（年度）をコメントで記載すること。

|自治体 |公式資料URL（確認用）                                                                                     |
|----|-------------------------------------------------------------------------------------------------|
|那覇市 |https://www.city.naha.okinawa.jp/_res/projects/default_project/*page*/001/002/785/r8kijunnhyo.pdf|
|浦添市 |https://www.city.urasoe.lg.jp/ （保育課ページ）                                                          |
|豊見城市|https://www.city.tomigusuku.lg.jp/soshiki/4/1021/gyomuannai/1/2/170.html                         |
|糸満市 |https://www.city.itoman.lg.jp/ （保育課ページ）                                                          |
|南城市 |https://www.city.nanjo.okinawa.jp/ （保育課ページ）                                                      |
|南風原町|https://www.town.haebaru.okinawa.jp/ （保育課ページ）                                                    |
|与那原町|https://www.town.yonabaru.okinawa.jp/ （保育課ページ）                                                   |
|八重瀬町|https://www.town.yaese.lg.jp/ （保育課ページ）                                                           |


> ⚠️ 那覇市以外の指数表は実装前に必ず各自治体の公式PDFを確認すること。
> 配点スケールが自治体ごとに異なるため、コピーせず個別に実装する。

-----

### 4. 結果表示画面

- 合計指数を大きく表示
- 内訳（父の基本指数 / 母の基本指数 / 調整指数）を表示
- 選択した自治体名を明示
- テキストシェアボタン（LINEやメモアプリへ）
- 画面下部に免責文言を必ず表示

-----

### 5. 広告（AdMob）

- バナー広告：結果画面の下部に常時表示
- インタースティシャル広告：結果表示時に1回

-----

## pubspec.yaml（主要依存）

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  google_mobile_ads: ^5.1.0
  shared_preferences: ^2.3.2
  share_plus: ^10.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

-----

## android/app/build.gradle（SDK設定）

```gradle
android {
    compileSdk 35

    defaultConfig {
        applicationId "com.nexeedlab.hokatsu_score"
        minSdk 21
        targetSdk 35
        versionCode 1
        versionName "1.0.0"
    }
}
```

-----

## MVP スコープ

- [ ] 沖縄南部8市町の自治体選択画面
- [ ] ScoringRule抽象クラスの定義
- [ ] 那覇市の指数ロジック実装（基本指数＋調整指数フル対応）
- [ ] 残り7自治体の指数ロジック実装（各公式PDFを確認して実装）
- [ ] 父母それぞれの基本指数 + 調整指数の計算・結果表示
- [ ] テキストシェア機能
- [ ] AdMobバナー広告
- [ ] 免責文言の表示
- [ ] Google Playリリース

-----

## 将来的な拡張（v2以降）

- 離島自治体の追加（久米島町・粟国村など）
- 沖縄中部・北部への拡張
- 申請書類チェックリスト
- 保育園見学メモ機能
- ボーダーライン表示（過去の最低指数との比較）

-----

## デザイン方針

- マテリアルデザイン3（Material You）ベース
- メインカラー：沖縄らしいターコイズ or 温かみのあるオレンジ系
- フォント：Noto Sans JP
- シンプルで直感的なUI（保活で疲弊している親御さん向け）

-----

## 注意事項・免責

- 計算結果はあくまで目安であり、実際の選考結果を保証するものではない旨を画面上に必ず明記
- 各自治体の指数ルールは毎年更新される。ルールファイルに参照元URLと対象年度をコメントで残すこと
- 個人情報はローカルのみ保存（サーバー送信なし）
- 指数データは各自治体の公式ページ・入園案内を一次情報として使用すること
