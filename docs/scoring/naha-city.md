# 那覇市 スコアリング詳細

> 親ドキュメント：[../../CLAUDE.md](../../CLAUDE.md)
> 一覧：[./README.md](./README.md)

## 参照

- 那覇市「令和8年度 保育所入所選考基準表」
- 案内ページ: https://www.city.naha.okinawa.jp/child/hoikuen/ninteikodomoen/R6hoikuen_moushikomi.html
  （ページURLは `R6` だが内容は令和8年度。那覇市のCMS仕様）
- 基準表PDF: https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf
- ボーダー点PDF（v2参考）: https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r7border.pdf
- 対象年度: 令和8年度

### 検証ステータス

| 項目        | 値                           |
|-----------|-----------------------------|
| PDF 取得日   | **未実施**（実装着手時に取得・記入）        |
| PDF 更新日   | **未確認**                     |
| 配点突合チェック  | **未実施**（本ドキュメントの配点は参考値） |
| 問合せ先      | 那覇市こどもみらい課 TEL 098-861-6903 |

> ⚠️ 本ドキュメントの配点は過去の公開情報に基づく参考値。
> 実装着手前に最新PDFを取得し、上記検証ステータスを更新してから実装すること。
> 年度更新時も同様のフローで再検証すること。

## 基本指数

### 就労時間段階判定（雇用契約あり）

| 月の就労時間  | 点数 |
|---------|----|
| 160h以上  | 30 |
| 140h以上  | 26 |
| 120h以上  | 22 |
| 90h以上   | 19 |
| 64h以上   | 15 |
| 64h未満   | 0  |

### 状況別点数

| 状況              | 点数 | 備考                        |
|-----------------|----|---------------------------|
| 採用予定            | 15 |                           |
| 自営業（証明書なし）      | -  | 上記時間段階の点数を上限9点で頭打ち      |
| 妊娠中（多胎）         | 23 |                           |
| 妊娠中（単胎）         | 18 |                           |
| 入院・常時臥床         | 32 |                           |
| 療養中（重度）         | 23 |                           |
| 療養中（軽度）         | 12 |                           |
| 求職中             | 9  |                           |
| 育休中             | 15 |                           |
| みなし育休中          | 7  |                           |
| 介護中             | -  | `calcCareScore` で別途算定     |
| 就学・職業訓練         | -  | 就労時間段階判定と同一               |

### 障害区分別点数

> ⚠️ 以下は一般的な保育指数の障害区分を元にした**暫定構造**。実装着手時に最新PDFで全項目を突合し、配点を確定すること。

| 区分                     | 点数   | 備考                |
|------------------------|------|-------------------|
| 身体障害者手帳 1〜2級          | TODO | PDF確認後に記入         |
| 身体障害者手帳 3級            | TODO | PDF確認後に記入         |
| 身体障害者手帳 4〜6級          | TODO | PDF確認後に記入         |
| 精神障害者保健福祉手帳 1級        | TODO | PDF確認後に記入         |
| 精神障害者保健福祉手帳 2級        | TODO | PDF確認後に記入         |
| 精神障害者保健福祉手帳 3級        | TODO | PDF確認後に記入         |
| 療育手帳 A                | TODO | PDF確認後に記入         |
| 療育手帳 B                | TODO | PDF確認後に記入         |
| 障害年金 1級               | TODO | PDF確認後に記入         |
| 障害年金 2級               | TODO | PDF確認後に記入         |

### 介護区分別点数

> ⚠️ 以下は暫定構造。実装着手時に最新PDFで確定すること。

| 区分        | 点数   | 備考                |
|-----------|------|-------------------|
| 要介護5     | TODO | PDF確認後に記入         |
| 要介護4     | TODO | PDF確認後に記入         |
| 要介護3     | TODO | PDF確認後に記入         |
| 要介護2     | TODO | PDF確認後に記入         |
| 要介護1     | TODO | PDF確認後に記入         |
| 要支援2     | TODO | PDF確認後に記入         |
| 要支援1     | TODO | PDF確認後に記入         |

## 調整指数

| 項目                | 点数   | 備考               |
|-------------------|------|------------------|
| ひとり親世帯            | +50  | みなしと排他、より高い方を採用  |
| ひとり親みなし（離婚調停中等）   | +35  | ひとり親世帯と排他        |
| 18歳以下での出産（若年出産）   | +15  |                  |
| 生活保護受給中           | +3   |                  |
| 市内認可保育所での就労（保育士）  | +50  |                  |
| 市内認可保育所での就労（支援員）  | +20  |                  |
| 育児休業から復帰予定        | +9   |                  |
| 障害者手帳保持かつ就労中      | +5   | 就労時間要件は最新PDFで再確認 |
| 単身赴任（県外・離島）       | +5   |                  |
| 認可外保育施設を現在利用中     | +11  | 条件あり             |
| きょうだいが第1希望園に在園中   | +7   |                  |
| きょうだい2名同時同園申込     | +6   |                  |
| きょうだいに障害児あり       | +5   |                  |
| 地域型保育園卒園児         | +100 | 優先               |
| 65歳未満の近居祖父母が保育可能  | −3   |                  |
| 希望園入れない場合に育休延長許容  | −500 | 実質辞退             |
| 保育料の滞納あり          | −20  |                  |

> ⚠️ 上記はすべて**参考値**。実装着手時に最新PDFで全項目を突合し、検証ステータスを更新すること。

## 実装例（`scoring/naha_city.dart`）

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
      // 未選択は0（UI側でバリデーション必須）
      case WorkStatus.notSpecified:            return 0;
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
    // TODO: 公式PDFの障害区分表で配点を確定し、数値を埋めること
    switch (parent.disabilityGrade) {
      case DisabilityGrade.none:        return 0;
      case DisabilityGrade.physical1to2: return 0; // TODO: PDF確認
      case DisabilityGrade.physical3:    return 0; // TODO: PDF確認
      case DisabilityGrade.physical4to6: return 0; // TODO: PDF確認
      case DisabilityGrade.mental1:      return 0; // TODO: PDF確認
      case DisabilityGrade.mental2:      return 0; // TODO: PDF確認
      case DisabilityGrade.mental3:      return 0; // TODO: PDF確認
      case DisabilityGrade.nursingA:     return 0; // TODO: PDF確認
      case DisabilityGrade.nursingB:     return 0; // TODO: PDF確認
      case DisabilityGrade.pensionA:     return 0; // TODO: PDF確認
      case DisabilityGrade.pensionB:     return 0; // TODO: PDF確認
    }
  }

  @override
  int calcCareScore(ParentProfile parent) {
    // TODO: 公式PDFの介護区分表で配点を確定し、数値を埋めること
    if (parent.workStatus != WorkStatus.caregiving) return 0;
    switch (parent.careLevel) {
      case CareLevel.none:     return 0;
      case CareLevel.support1: return 0; // TODO: PDF確認
      case CareLevel.support2: return 0; // TODO: PDF確認
      case CareLevel.care1:    return 0; // TODO: PDF確認
      case CareLevel.care2:    return 0; // TODO: PDF確認
      case CareLevel.care3:    return 0; // TODO: PDF確認
      case CareLevel.care4:    return 0; // TODO: PDF確認
      case CareLevel.care5:    return 0; // TODO: PDF確認
    }
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
    switch (family.nurseryWorkerType) {               // 市内認可保育所での就労（排他）
      case NurseryWorkerType.nurseryWorker:
        score += 50;
      case NurseryWorkerType.childcareSupporter:
        score += 20;
      case NurseryWorkerType.none:
        break;
    }
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
