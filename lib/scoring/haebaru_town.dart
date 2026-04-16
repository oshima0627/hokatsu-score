import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 南風原町の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.town.haebaru.lg.jp/soshiki/11/13031.html
/// 特徴: 月間時間6段階（170h以上→10, 64h以上→5）
class HaebaruTownScoringRule extends ScoringRule {
  @override
  String get municipalityName => '南風原町';

  @override
  String get sourceUrl =>
      'https://www.town.haebaru.lg.jp/soshiki/11/13031.html';

  @override
  String get fiscalYear => '令和8年度';

  // ---------------------------------------------------------------------------
  // 就労スコア
  // ---------------------------------------------------------------------------

  @override
  int calcWorkScore(ParentProfile parent) {
    switch (parent.workStatus) {
      case WorkStatus.employed:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.selfEmployedNoProof:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.employedProspect:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.pregnant:
        return 10;
      case WorkStatus.pregnantMultiple:
        return 10;
      case WorkStatus.hospitalizedBedridden:
        return 10;
      case WorkStatus.medicalTreatmentSerious:
        return 8;
      case WorkStatus.medicalTreatmentMild:
        return 6;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.jobSeeking:
        return 4;
      case WorkStatus.parentalLeave:
        return 5;
      case WorkStatus.pseudoParentalLeave:
        return 5;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間から点数（南風原町独自の6段階）
  int _scoreByHours(int hours) {
    if (hours >= 170) return 10;
    if (hours >= 155) return 9;
    if (hours >= 135) return 8;
    if (hours >= 100) return 7;
    if (hours >= 80) return 6;
    if (hours >= 64) return 5;
    return 0;
  }

  // ---------------------------------------------------------------------------
  // 障害スコア
  // ---------------------------------------------------------------------------

  @override
  int calcDisabilityScore(ParentProfile parent) {
    switch (parent.disabilityGrade) {
      case DisabilityGrade.none:
        return 0;
      case DisabilityGrade.physical1to2:
        return 10;
      case DisabilityGrade.mental1:
        return 10;
      case DisabilityGrade.nursingA:
        return 10;
      case DisabilityGrade.pensionA:
        return 10;
      case DisabilityGrade.physical3:
        return 8;
      case DisabilityGrade.mental2:
        return 8;
      case DisabilityGrade.mental3:
        return 8;
      case DisabilityGrade.nursingB:
        return 8;
      case DisabilityGrade.pensionB:
        return 8;
      case DisabilityGrade.physical4to6:
        return 6;
    }
  }

  // ---------------------------------------------------------------------------
  // 介護スコア
  // ---------------------------------------------------------------------------

  @override
  int calcCareScore(ParentProfile parent) {
    if (parent.workStatus != WorkStatus.caregiving) {
      return 0;
    }
    switch (parent.careLevel) {
      case CareLevel.none:
        return 0;
      case CareLevel.support1:
        return 5;
      case CareLevel.support2:
        return 5;
      case CareLevel.care1:
        return 5;
      case CareLevel.care2:
        return 8;
      case CareLevel.care3:
        return 8;
      case CareLevel.care4:
        return 10;
      case CareLevel.care5:
        return 10;
    }
  }

  // ---------------------------------------------------------------------------
  // 調整指数
  // ---------------------------------------------------------------------------

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;

    // ひとり親（排他的: 高い方を採用）
    // 単独世帯14点、祖父母同居12点 → 簡略化: isSingleParent=14
    score += math.max(
      family.isSingleParent ? 14 : 0,
      family.isPseudoSingleParent ? 12 : 0,
    );

    if (family.isOnWelfare) score += 4;

    // 保育士（月155h以上→+5, 未満→+2）
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 5;
      case NurseryWorkerType.childcareSupporter:
        score += 2;
      case NurseryWorkerType.none:
        break;
    }

    if (family.isTransferredAway) score += 1;
    if (family.siblingAtFirstChoiceNursery) score += 1;

    // 在園施設への申込（きょうだい）→ +5
    // siblingAtFirstChoiceNurseryで代用済み。追加で在園加点
    if (family.isGraduatingFromSmallNursery) score += 5;

    // 保育料未納
    if (family.hasUnpaidFees) score -= 8;

    // 同居人が保育可能（grandparentCanCare 流用）
    if (family.grandparentCanCare) score -= 1;

    return score;
  }
}
