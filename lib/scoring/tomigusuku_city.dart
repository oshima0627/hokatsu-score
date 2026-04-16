import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 豊見城市の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.city.tomigusuku.lg.jp/material/files/group/22/r8_application_guide.pdf
class TomigusukuCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '豊見城市';

  @override
  String get sourceUrl =>
      'https://www.city.tomigusuku.lg.jp/material/files/group/22/r8_application_guide.pdf';

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
        return 10; // 挙証資料なし: 一律10点
      case WorkStatus.employedProspect:
        // 採用予定: 就労時間の点数から-1（最低0）
        return math.max(_scoreByHours(parent.monthlyWorkHours) - 1, 0);
      case WorkStatus.pregnant:
        return 20;
      case WorkStatus.pregnantMultiple:
        return 20;
      case WorkStatus.hospitalizedBedridden:
        return 20;
      case WorkStatus.medicalTreatmentSerious:
        return 18;
      case WorkStatus.medicalTreatmentMild:
        return 14;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.jobSeeking:
        return 9;
      case WorkStatus.parentalLeave:
        return 10;
      case WorkStatus.pseudoParentalLeave:
        return 10;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間から点数
  int _scoreByHours(int hours) {
    if (hours >= 160) return 20;
    if (hours >= 140) return 18;
    if (hours >= 120) return 16;
    if (hours >= 100) return 14;
    if (hours >= 80) return 12;
    if (hours >= 64) return 10;
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
        return 20;
      case DisabilityGrade.mental1:
        return 20;
      case DisabilityGrade.nursingA:
        return 20;
      case DisabilityGrade.pensionA:
        return 20;
      case DisabilityGrade.physical3:
        return 15;
      case DisabilityGrade.mental2:
        return 15;
      case DisabilityGrade.nursingB:
        return 15;
      case DisabilityGrade.pensionB:
        return 15;
      // 上記以外の手帳 → 10点
      case DisabilityGrade.physical4to6:
        return 10;
      case DisabilityGrade.mental3:
        return 10;
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
        return 10;
      case CareLevel.support2:
        return 10;
      case CareLevel.care1:
        return 12;
      case CareLevel.care2:
        return 12;
      case CareLevel.care3:
        return 16;
      case CareLevel.care4:
        return 16;
      case CareLevel.care5:
        return 18;
    }
  }

  // ---------------------------------------------------------------------------
  // 調整指数
  // ---------------------------------------------------------------------------

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;

    // ひとり親（排他的: 高い方を採用）
    score += math.max(
      family.isSingleParent ? 12 : 0,
      family.isPseudoSingleParent ? 10 : 0,
    );

    if (family.isOnWelfare) score += 7;

    // 保育士（市内: +15）
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 15;
      case NurseryWorkerType.childcareSupporter:
        score += 5;
      case NurseryWorkerType.none:
        break;
    }

    // 育休復帰: PDF 2歳児+3, 1歳児+2。区別できないため+3を適用
    if (family.returningFromLeave) score += 3;
    if (family.isTransferredAway) score += 1;
    if (family.isUsingNinkagai) score += 3;
    if (family.siblingAtFirstChoiceNursery) score += 11;
    if (family.twoSiblingsApplyingSameNursery) score += 3;
    if (family.isGraduatingFromSmallNursery) score += 4;

    // 65歳未満の同居人がいるひとり親世帯（減点）
    if (family.grandparentCanCare) score -= 3;

    // 育休延長許容
    if (family.acceptsLeaveExtension) score -= 150;

    // 保育料滞納
    if (family.hasUnpaidFees) score -= 15;

    return score;
  }
}
