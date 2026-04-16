import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 那覇市の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf
class NahaCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '那覇市';

  @override
  String get sourceUrl =>
      'https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf';

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
        return math.min(_scoreByHours(parent.monthlyWorkHours), 9);
      case WorkStatus.employedProspect:
        return 15;
      case WorkStatus.pregnant:
        return 18;
      case WorkStatus.pregnantMultiple:
        return 23;
      case WorkStatus.hospitalizedBedridden:
        return 32;
      case WorkStatus.medicalTreatmentSerious:
        return 23;
      case WorkStatus.medicalTreatmentMild:
        return 12;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.jobSeeking:
        return 9;
      case WorkStatus.parentalLeave:
        return 15;
      case WorkStatus.pseudoParentalLeave:
        return 7;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間から基本点数を算出
  int _scoreByHours(int hours) {
    if (hours >= 160) return 30;
    if (hours >= 140) return 26;
    if (hours >= 120) return 22;
    if (hours >= 90) return 19;
    if (hours >= 64) return 15;
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
        return 32;
      case DisabilityGrade.physical3:
        return 23;
      case DisabilityGrade.physical4to6:
        return 12;
      case DisabilityGrade.mental1:
        return 32;
      case DisabilityGrade.mental2:
        return 23;
      case DisabilityGrade.mental3:
        return 12;
      case DisabilityGrade.nursingA:
        return 32;
      case DisabilityGrade.nursingB:
        return 12;
      case DisabilityGrade.pensionA:
        return 32;
      case DisabilityGrade.pensionB:
        return 23;
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
        return 12;
      case CareLevel.support2:
        return 15;
      case CareLevel.care1:
        return 19;
      case CareLevel.care2:
        return 22;
      case CareLevel.care3:
        return 26;
      case CareLevel.care4:
        return 30;
      case CareLevel.care5:
        return 32;
    }
  }

  // ---------------------------------------------------------------------------
  // 調整指数
  // ---------------------------------------------------------------------------

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;

    // ひとり親（排他的：高い方を採用）
    score += math.max(
      family.isSingleParent ? 50 : 0,
      family.isPseudoSingleParent ? 35 : 0,
    );

    if (family.isYoungParent) score += 15;
    if (family.isOnWelfare) score += 3;

    // 保育士・支援員（排他的enum）
    switch (family.nurseryWorkerType) {
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

    // 減点項目
    if (family.grandparentCanCare) score -= 3;
    if (family.acceptsLeaveExtension) score -= 500;
    if (family.hasUnpaidFees) score -= 20;

    return score;
  }
}
