# アーキテクチャ

> 親ドキュメント：[../CLAUDE.md](../CLAUDE.md)

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
│   │   └── score_provider.dart           # 上記を集約してスコア計算（computed Provider）
│   ├── screens/
│   │   ├── home_screen.dart              # トップ画面（自治体選択）
│   │   ├── parent_input_screen.dart      # 保護者情報入力（父・母共用）
│   │   ├── family_input_screen.dart      # 世帯状況入力（調整指数）
│   │   ├── result_screen.dart            # 結果表示
│   │   └── settings_screen.dart          # 設定（保存データ削除など）
│   ├── widgets/
│   │   ├── ad_banner_widget.dart         # AdMobバナー
│   │   └── score_card_widget.dart        # スコア表示カード
│   ├── storage/
│   │   └── secure_storage.dart           # flutter_secure_storage ラッパ
│   └── scoring/
│       ├── scoring_rule.dart             # 抽象クラス（共通インターフェース）
│       ├── scoring_rule_factory.dart     # Municipality enum → ScoringRule 解決
│       ├── municipality.dart             # 自治体 enum
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
├── docs/
├── pubspec.yaml
└── CLAUDE.md
```

-----

## データモデル定義

### `WorkStatus`（enum）

UI上は10項目に集約し、サブ選択（妊娠の単胎/多胎、療養の重度/軽度等）で内部 enum 値を決定する。

| 値                          | UIカテゴリ      | 表示名               |
|----------------------------|------------|-------------------|
| `notSpecified`             | （未選択）      | 未選択（バリデーション用初期値） |
| `employed`                 | 就労中        | 就労中（雇用契約あり）       |
| `employedProspect`         | 採用予定       | 採用予定              |
| `selfEmployedNoProof`      | 就労中        | 自営業（証明書なし）        |
| `pregnant`                 | 妊娠・産後      | 妊娠中（単胎）           |
| `pregnantMultiple`         | 妊娠・産後      | 妊娠中（多胎）           |
| `hospitalizedBedridden`    | 疾病・障害      | 入院・常時臥床           |
| `medicalTreatmentSerious`  | 疾病・障害      | 療養中（重度）           |
| `medicalTreatmentMild`     | 疾病・障害      | 療養中（軽度）           |
| `caregiving`               | 介護中        | 介護中               |
| `student`                  | 就学・職業訓練    | 就学・職業訓練           |
| `jobSeeking`               | 求職中        | 求職中               |
| `parentalLeave`            | 育休中        | 育休中               |
| `pseudoParentalLeave`      | みなし育休中     | みなし育休中            |

> ⚠️ `notSpecified` は UI 初期値。ユーザーが必ず1つ選ぶよう **送信前バリデーションを必須** とする。

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

### `Municipality`（enum）

| 値             | 表示名    |
|---------------|--------|
| `naha`        | 那覇市    |
| `urasoe`      | 浦添市    |
| `tomigusuku`  | 豊見城市   |
| `itoman`      | 糸満市    |
| `nanjo`       | 南城市    |
| `haebaru`     | 南風原町   |
| `yonabaru`    | 与那原町   |
| `yaese`       | 八重瀬町   |

### `ParentProfile`（モデル）

| フィールド              | 型                  | 備考                   |
|--------------------|--------------------|----------------------|
| `workStatus`       | `WorkStatus`       | 初期値: `notSpecified` |
| `monthlyWorkHours` | `int`              | 月の就労時間              |
| `disabilityGrade`  | `DisabilityGrade`  | 初期値: `none`         |
| `careLevel`        | `CareLevel`        | 初期値: `none`         |
| `isLeaveTarget`    | `bool`             | 育休対象児の申込か否か         |

### `FamilyProfile`（モデル）

| フィールド                          | 型               | 備考              |
|--------------------------------|----------------|-----------------|
| `father`                       | `ParentProfile`| 父               |
| `mother`                       | `ParentProfile`| 母               |
| `isSingleParent`               | `bool`         | ひとり親世帯          |
| `isPseudoSingleParent`         | `bool`         | ひとり親みなし（排他）     |
| `isYoungParent`                | `bool`         | 18歳以下出産         |
| `isOnWelfare`                  | `bool`         | 生活保護受給中         |
| `isNurseryWorker`              | `bool`         | 市内認可で保育士就労      |
| `isChildcareSupporter`         | `bool`         | 子育て支援員          |
| `returningFromLeave`           | `bool`         | 育休から復帰予定        |
| `hasDisabilityAndWorks`        | `bool`         | 手帳保持＋就労中        |
| `isTransferredAway`            | `bool`         | 単身赴任            |
| `isUsingNinkagai`              | `bool`         | 認可外利用中          |
| `siblingAtFirstChoiceNursery`  | `bool`         | きょうだいが第1希望園在園   |
| `twoSiblingsApplyingSameNursery` | `bool`       | きょうだい2名同時同園申込   |
| `siblingHasDisability`         | `bool`         | きょうだいに障害児       |
| `isGraduatingFromSmallNursery` | `bool`         | 地域型保育園卒園児       |
| `grandparentCanCare`           | `bool`         | 65歳未満近居祖父母が保育可能 |
| `acceptsLeaveExtension`        | `bool`         | 育休延長許容          |
| `hasUnpaidFees`                | `bool`         | 保育料の滞納あり        |

> ⚠️ 上記フィールドは MVP の最小セット。
> 自治体固有項目は v2 以降で必要が確認された時点で追加（型安全性確保のため `Map<String, dynamic>` 拡張点は MVP には設けない）。

-----

## スコアリング設計

### 抽象クラス（`scoring/scoring_rule.dart`）

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

  /// 家族の要介護対応に基づく点数
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

### ファクトリ（`scoring/scoring_rule_factory.dart`）

```dart
class ScoringRuleFactory {
  static ScoringRule of(Municipality m) {
    switch (m) {
      case Municipality.naha:       return NahaCityScoringRule();
      case Municipality.urasoe:     return UrasoeCityScoringRule();
      case Municipality.tomigusuku: return TomigusukuCityScoringRule();
      case Municipality.itoman:     return ItomanCityScoringRule();
      case Municipality.nanjo:      return NanjoCityScoringRule();
      case Municipality.haebaru:    return HaebaruTownScoringRule();
      case Municipality.yonabaru:   return YonabaruTownScoringRule();
      case Municipality.yaese:      return YaeseTownScoringRule();
    }
  }
}
```

### 自治体別実装

各自治体の実装方針と公式資料 URL は [`scoring/README.md`](./scoring/README.md) を参照。
