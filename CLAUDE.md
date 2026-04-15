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
|ローカル保存    |flutter_secure_storage（暗号化）       |
|ターゲット     |Android（Google Play）              |
|minSdk    |API 21（Android 5.0）               |
|targetSdk |API 36（Android 16）※Google Play提出必須|
|compileSdk|API 36                            |


> ⚠️ Google Playは2025年8月31日以降、新規アプリにtargetSdk 35必須、
> 2026年8月31日以降はtargetSdk 36必須となる予定。
> 本プロジェクトは2026年4月時点の新規開発のため、最初から `targetSdk 36` を採用する。
> `android/app/build.gradle` に明示すること。最新要件は事前にGoogle Play公式を確認のこと。

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
│   │   ├── parent_provider.dart          # 父・母の入力状態
│   │   ├── family_provider.dart          # 世帯（調整指数）入力状態
│   │   ├── municipality_provider.dart    # 選択中の自治体
│   │   └── score_provider.dart           # 上記を集約してスコア計算
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
│       ├── scoring_rule_factory.dart     # 自治体ID→ScoringRule解決
│       ├── naha_city.dart                # 那覇市
│       ├── urasoe_city.dart              # 浦添市
│       ├── tomigusuku_city.dart          # 豊見城市
│       ├── itoman_city.dart              # 糸満市
│       ├── nanjo_city.dart               # 南城市
│       ├── haebaru_town.dart             # 南風原町
│       ├── yonabaru_town.dart            # 与那原町
│       └── yaese_town.dart               # 八重瀬町
├── test/
│   └── scoring/
│       ├── naha_city_test.dart           # 那覇市スコア計算ユニットテスト
│       └── ...                           # 各自治体ごとに作成
├── android/
│   └── app/
│       └── build.gradle
├── pubspec.yaml
└── CLAUDE.md
```

-----

## データモデル定義

### `WorkStatus`（enum）

UI上は9項目に集約し、サブ選択（妊娠の単胎/多胎、療養の重度/軽度等）で内部 enum 値を決定する。

| 値                          | UIカテゴリ      | 表示名         |
|----------------------------|------------|-------------|
| `employed`                 | 就労中        | 就労中（雇用契約あり） |
| `employedProspect`         | 採用予定       | 採用予定        |
| `selfEmployedNoProof`      | 就労中        | 自営業（証明書なし）  |
| `pregnant`                 | 妊娠・産後      | 妊娠中（単胎）     |
| `pregnantMultiple`         | 妊娠・産後      | 妊娠中（多胎）     |
| `hospitalizedBedridden`    | 疾病・障害      | 入院・常時臥床     |
| `medicalTreatmentSerious`  | 疾病・障害      | 療養中（重度）     |
| `medicalTreatmentMild`     | 疾病・障害      | 療養中（軽度）     |
| `caregiving`               | 介護中        | 介護中         |
| `student`                  | 就学・職業訓練    | 就学・職業訓練     |
| `jobSeeking`               | 求職中        | 求職中         |
| `parentalLeave`            | 育休中        | 育休中         |
| `pseudoParentalLeave`      | みなし育休中     | みなし育休中      |

### `DisabilityGrade`（enum）

自治体ごとに区分が異なるため、内部表現は手帳種別＋級番号で持つ。

| 値             | 表示名             |
|---------------|-----------------|
| `none`        | なし              |
| `physical1to2`| 身体障害者手帳 1〜2級    |
| `physical3`   | 身体障害者手帳 3級      |
| `physical4to6`| 身体障害者手帳 4〜6級    |
| `mental1`     | 精神障害者保健福祉手帳 1級  |
| `mental2`     | 精神障害者保健福祉手帳 2級  |
| `mental3`     | 精神障害者保健福祉手帳 3級  |
| `nursingA`    | 療育手帳 A          |
| `nursingB`    | 療育手帳 B          |
| `pensionA`    | 障害年金 1級         |
| `pensionB`    | 障害年金 2級         |

### `CareLevel`（enum）

| 値           | 表示名      |
|-------------|----------|
| `none`      | なし       |
| `support1`  | 要支援1     |
| `support2`  | 要支援2     |
| `care1`     | 要介護1     |
| `care2`     | 要介護2     |
| `care3`     | 要介護3     |
| `care4`     | 要介護4     |
| `care5`     | 要介護5     |

### `ParentProfile`（モデル）

| フィールド              | 型                  | 備考                     |
|--------------------|--------------------|------------------------|
| `workStatus`       | `WorkStatus`       | 就労状況                   |
| `monthlyWorkHours` | `int`              | 月の就労時間                 |
| `disabilityGrade` | `DisabilityGrade`  | 障害区分（既定: `none`）        |
| `careLevel`        | `CareLevel`        | 介護区分（既定: `none`）        |
| `isLeaveTarget`    | `bool`             | 育休対象児の申込か否か            |
| `extra`            | `Map<String, dynamic>?` | v2以降の自治体固有項目用拡張点（MVPは空）|

### `FamilyProfile`（モデル）

| フィールド                          | 型               | 備考                |
|--------------------------------|----------------|-------------------|
| `father`                       | `ParentProfile`| 父                 |
| `mother`                       | `ParentProfile`| 母                 |
| `isSingleParent`               | `bool`         | ひとり親世帯            |
| `isPseudoSingleParent`         | `bool`         | ひとり親みなし（排他）       |
| `isYoungParent`                | `bool`         | 18歳以下出産           |
| `isOnWelfare`                  | `bool`         | 生活保護受給中           |
| `isNurseryWorker`              | `bool`         | 市内認可で保育士就労        |
| `isChildcareSupporter`         | `bool`         | 子育て支援員            |
| `returningFromLeave`           | `bool`         | 育休から復帰予定          |
| `hasDisabilityAndWorks`        | `bool`         | 手帳保持＋就労中          |
| `isTransferredAway`            | `bool`         | 単身赴任              |
| `isUsingNinkagai`              | `bool`         | 認可外利用中            |
| `siblingAtFirstChoiceNursery`  | `bool`         | きょうだいが第1希望園在園     |
| `twoSiblingsApplyingSameNursery` | `bool`       | きょうだい2名同時同園申込     |
| `siblingHasDisability`         | `bool`         | きょうだいに障害児         |
| `isGraduatingFromSmallNursery` | `bool`         | 地域型保育園卒園児         |
| `grandparentCanCare`           | `bool`         | 65歳未満近居祖父母が保育可能   |
| `acceptsLeaveExtension`        | `bool`         | 育休延長許容            |
| `hasUnpaidFees`                | `bool`         | 保育料の滞納あり          |
| `extra`                        | `Map<String, dynamic>?` | v2以降の自治体固有項目用（MVPは空）|

> ⚠️ 上記フィールドはMVP想定の最小セット。`extra` は MVP では未使用（null許容）。
> 将来の自治体固有項目（例：認可外利用月数、就労期間等）は `extra` 経由で追加する。

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

> ⚠️ 「みなし育休中」の定義：育児休業給付金を受給せずに実態として育児休業に相当する休業を取得しているケース。
> 自治体により定義が異なるため、各自治体ルールでの取扱を明示すること。

> ⚠️ 基本指数の算定方式：自治体により「就労・障害・介護のうち最も高い点数を採用」する方式と
> 「合算」する方式が混在する。各自治体ルールファイルで方針を明記すること（デフォルトは「最大値採用」）。

#### 調整指数（世帯全体）

|項目               |入力形式    |備考                                       |
|-----------------|--------|-----------------------------------------|
|ひとり親世帯           |はい / いいえ|那覇市+50点（「ひとり親みなし」と排他、より高い方を採用）         |
|ひとり親みなし（離婚調停中等）  |はい / いいえ|那覇市+35点（「ひとり親世帯」と排他）                   |
|18歳以下での出産（若年出産）  |はい / いいえ|那覇市+15点                                  |
|生活保護受給中          |はい / いいえ|那覇市+3点                                   |
|市内認可保育所での就労（保育士等）|はい / いいえ|那覇市+50点（保育士）/ +20点（支援員）                  |
|育児休業から復帰予定       |はい / いいえ|那覇市+9点                                   |
|障害者手帳保持かつ就労中     |はい / いいえ|那覇市+5点（就労時間要件は最新PDFで再確認）                 |
|単身赴任（県外・離島）      |はい / いいえ|那覇市+5点                                   |
|認可外保育施設を現在利用中    |はい / いいえ|那覇市+11点（条件あり）                            |
|きょうだいが第1希望園に在園中  |はい / いいえ|那覇市+7点                                   |
|きょうだい2名同時同園申込    |はい / いいえ|那覇市+6点                                   |
|きょうだいに障害児あり      |はい / いいえ|那覇市+5点                                   |
|地域型保育園卒園児        |はい / いいえ|那覇市+100点（優先）                             |
|65歳未満の近居祖父母が保育可能 |はい / いいえ|多くの自治体で減点                                |
|希望園入れない場合に育休延長許容 |はい / いいえ|那覇市−500点(実質辞退)                           |
|保育料の滞納あり         |はい / いいえ|那覇市−20点                                  |


> ⚠️ 上記配点はすべて那覇市の参考値。**他7自治体は項目および配点が異なる**ため、
> 実装フェーズで各自治体ごとの調整指数差分表を本ファイルに追記すること（または `docs/scoring/` に分割）。

> ⚠️ 配点は最新の公式PDFで必ず再検証すること（特に「市内認可保育所での就労（保育士等）」と
> 「障害者手帳保持かつ就労中」の項目は年度更新で配点・条件が変動しやすい）。

-----

### 3. 自治体別指数ルールの設計方針

#### 抽象クラス（scoring/scoring_rule.dart）

```dart
import 'dart:math' as math;

abstract class ScoringRule {
  String get municipalityName;

  /// 参照した公式PDFのURL
  String get sourceUrl;

  /// 対象年度（例: '令和8年度'）
  String get fiscalYear;

  /// 就労状況に基づく点数（介護・就学含む）
  int calcWorkScore(ParentProfile parent);

  /// 障害・手帳に基づく点数
  int calcDisabilityScore(ParentProfile parent);

  /// 介護（家族の要介護対応）に基づく点数
  int calcCareScore(ParentProfile parent);

  /// 父または母1人分の基本指数を返す。
  /// デフォルトは「就労・障害・介護のうち最大値を採用」する方式。
  /// 合算方式の自治体は本メソッドを override する。
  int calcBaseScore(ParentProfile parent) {
    return [
      calcWorkScore(parent),
      calcDisabilityScore(parent),
      calcCareScore(parent),
    ].reduce(math.max);
  }

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
> URL: https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf
> （※実URLは事前に必ず公式サイトで確認）

```dart
import 'dart:math' as math;

class NahaCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '那覇市';

  @override
  String get sourceUrl =>
      'https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf';

  @override
  String get fiscalYear => '令和8年度';

  @override
  int calcWorkScore(ParentProfile parent) {
    switch (parent.workStatus) {
      case WorkStatus.employed:
      case WorkStatus.selfEmployedNoProof:
        final base = _scoreByHours(parent.monthlyWorkHours);
        // 自営業（証明書なし）は上限9点で頭打ち
        return parent.workStatus == WorkStatus.selfEmployedNoProof
            ? math.min(base, 9)
            : base;
      case WorkStatus.employedProspect:        return 15;
      case WorkStatus.pregnantMultiple:        return 23;
      case WorkStatus.pregnant:                return 18;
      case WorkStatus.hospitalizedBedridden:   return 32;
      case WorkStatus.medicalTreatmentSerious: return 23;
      case WorkStatus.medicalTreatmentMild:    return 12;
      case WorkStatus.jobSeeking:              return 9;
      case WorkStatus.parentalLeave:           return 15;
      case WorkStatus.pseudoParentalLeave:     return 7;
      // 介護中は calcCareScore へ委譲（こちらは0を返す）
      case WorkStatus.caregiving:              return 0;
      // 就学・職業訓練は時間ベース判定
      case WorkStatus.student:
        return _scoreByHours(parent.monthlyWorkHours);
    }
  }

  int _scoreByHours(int hours) {
    if (hours >= 160) return 30;
    if (hours >= 140) return 26;
    if (hours >= 120) return 22;
    if (hours >= 90)  return 19;
    if (hours >= 64)  return 15;
    return 0;
  }

  @override
  int calcDisabilityScore(ParentProfile parent) {
    // TODO: 公式PDFの障害区分表に従って実装
    return 0;
  }

  @override
  int calcCareScore(ParentProfile parent) {
    // TODO: 公式PDFの介護区分表に従って実装
    // 例: 要介護3以上 + 同居なら高得点 等
    return 0;
  }

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;
    // ひとり親系は排他（高い方を採用）。将来配点が逆転しても安全なよう max を取る。
    final singleParentBonus = math.max(
      family.isSingleParent ? 50 : 0,
      family.isPseudoSingleParent ? 35 : 0,
    );
    score += singleParentBonus;
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
|那覇市 |https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf|
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
- 選択した自治体名と参照年度（`fiscalYear`）を明示
- テキストシェアボタン（LINEやメモアプリへ）
- 画面下部に免責文言を必ず表示

#### シェアテキストの雛形

```
【保活スコア計算結果】
自治体：那覇市（令和8年度基準）
合計指数：XX点
　父の基本指数：XX点
　母の基本指数：XX点
　調整指数：XX点

※本結果はあくまで目安です。実際の選考結果を保証するものではありません。
保活スコア計算アプリ
```

-----

### 5. 広告（AdMob）

- バナー広告：結果画面の下部に常時表示（結果表示エリアと十分な余白を設けて誤クリック防止）
- インタースティシャル広告：結果表示画面への遷移直前に表示。
  - **頻度キャップ：前回表示から3分以上経過した場合のみ表示**
  - 自治体を切り替えて再計算する場合は連続表示を避けるため、上記タイマーで自然に抑制される
- AdMob管理画面で「広告コンテンツのフィルタリング」を G レーティング相当に設定する。
- 本アプリは家族・育児カテゴリのため **Google Play Families ポリシー** に適合させる。
  - 認定広告ネットワーク以外を無効化
  - 「子ども向けコンテンツ扱い」を AdMob 管理画面で設定（パーソナライズ広告は既定オフ）
- **配信地域：日本のみ** とするため、UMP SDK（GDPR同意フロー）は導入しない。
  - 将来海外配信する場合は UMP SDK と地域別同意ロジックを追加すること

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
        minSdk 21
        targetSdk 36
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
- [ ] AdMobバナー広告（日本配信のみ、UMPなし）
- [ ] 免責文言の表示
- [ ] **スコア計算ユニットテスト**（自治体ごとに代表ケースを最低5件）
- [ ] **プライバシーポリシー作成と公開**（Google Play 必須）
- [ ] **データセーフティセクション記入**（Google Play Console）
- [ ] Google Playリリース

-----

## テスト方針

- スコア計算は副作用がなく純粋関数で構成されるため、`test/scoring/<municipality>_test.dart` で網羅テスト必須
- 各自治体ファイルにつき以下を最低限カバー
  - 月の就労時間境界値（63h / 64h / 89h / 90h / ... / 160h）
  - ひとり親 / ひとり親みなしの排他
  - 育休延長許容で大きな減点が反映されること
  - 全フラグOFFで0点であること
- ゴールデンテスト（PDF掲載例の数値を再現）を1自治体あたり最低1ケース

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
- **言語：日本語のみ**（`flutter_localizations` は当面導入しない）

### アクセシビリティ最低要件

- すべての `TextField` に `labelText` を設定（スクリーンリーダー対応）
- タップターゲットは最小 48×48 dp
- 端末のフォントスケール設定に追従（`MediaQuery.textScaleFactor` を尊重し、固定 fontSize は使わない）
- 色のみで情報を伝えない（減点項目はアイコン＋色でラベリング）
- コントラスト比 WCAG AA 以上

-----

## 注意事項・免責

- 計算結果はあくまで目安であり、実際の選考結果を保証するものではない旨を画面上に必ず明記
- 各自治体の指数ルールは毎年更新される。ルールファイルに参照元URLと対象年度をコメントで残すこと
- 指数データは各自治体の公式ページ・入園案内を一次情報として使用すること

### ローカル保存ポリシー

- ユーザーが入力した家庭情報は **要配慮個人情報** を含む（障害等級、生活保護受給など）
- そのため、`shared_preferences`（平文XML）には保存せず、**`flutter_secure_storage`** を使用する
  - Android: EncryptedSharedPreferences で保存
  - 直近の入力値は永続保存し、起動時に再表示する用途
- 設定画面に「保存データを削除」ボタンを必ず提供する
- 外部サーバーへの送信は行わない（AdMob による広告識別子送信を除く）

### Google Play 公開時に必要なもの

- プライバシーポリシーURL（GitHub Pages 等で公開）
- データセーフティセクション
  - 収集データ：広告ID／端末識別子（AdMob）
  - 共有先：Google（AdMob）
  - 暗号化転送：はい
  - データ削除リクエスト方法：アプリ内「保存データを削除」ボタン
- 対象年齢設定（家族向け or 一般）の確定
- 配信地域：日本のみ

### バージョニングと年度更新

- 指数ルールは毎年度更新されるため、`pubspec.yaml` の `version` を年度切替時に必ず上げる
- ホーム画面に「対応年度：令和X年度」を明示
- 年度更新の際は `ScoringRule.fiscalYear` を更新し、ユニットテストのゴールデンケースも更新

-----

## 開発ワークフロー（必読）

### ブランチ運用

- 作業ブランチ命名規約：`claude/<topic>-<shortid>`
  - 例：`claude/naha-scoring-aP5Yl`、`claude/review-claude-md-cFZXt`
- 1タスク = 1ブランチを基本とし、**固定ブランチを使い回さない**
- 直接 `main` にコミットしない

### 作業完了時の標準フロー（個人開発モード）

1. 作業ブランチでコミット
2. 作業ブランチをリモートへプッシュ（`git push -u origin <branch>`）
3. レビュー不要かつ破壊的影響がないと判断できる場合は `main` にマージ

```bash
# 例：作業完了後
git push -u origin claude/<topic>-<shortid>

# main にマージ（個人開発時のみ）
git checkout main
git pull origin main
git merge --no-ff claude/<topic>-<shortid>
git push origin main

# 作業ブランチへ戻る
git checkout claude/<topic>-<shortid>
```

### 将来コラボ／CI導入時の運用

- `main` をブランチ保護（直接プッシュ禁止、PR必須、CI緑化必須）
- PR レビュー経由でのマージに切り替える
- `flutter test` および `flutter analyze` を CI 必須チェックとする

> ⚠️ 「作業ブランチへのプッシュだけで終わらせない」原則は維持するが、
> マージ前に変更の影響範囲を必ず確認すること。スコアロジック変更時はテスト緑化必須。
