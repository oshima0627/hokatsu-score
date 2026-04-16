import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 浦添市の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.city.urasoe.lg.jp/doc/2025071500035/file_contents/file_20251_1.pdf
/// 基本点数は max(就労, 障害, 介護) 方式。
class UrasoeCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '浦添市';

  @override
  String get sourceUrl =>
      'https://www.city.urasoe.lg.jp/doc/2025071500035/file_contents/file_20251_1.pdf';

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
        return _selfEmployedByHours(parent.monthlyWorkHours);
      case WorkStatus.employedProspect:
        // 浦添市の基準表に明示なし。求職活動に準じて3点とする。
        return 3;
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
        return 3;
      case WorkStatus.parentalLeave:
        return 8;
      case WorkStatus.pseudoParentalLeave:
        return 8;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 就労(1) 雇用契約あり: 月の就労時間から点数
  int _scoreByHours(int hours) {
    if (hours >= 160) return 20;
    if (hours >= 140) return 18;
    if (hours >= 120) return 16;
    if (hours >= 100) return 14;
    if (hours >= 80) return 12;
    if (hours >= 64) return 10;
    return 0;
  }

  /// 就労(2) 自営業等（挙証資料なし）
  int _selfEmployedByHours(int hours) {
    if (hours >= 160) return 14;
    if (hours >= 140) return 13;
    if (hours >= 120) return 12;
    if (hours >= 100) return 11;
    if (hours >= 80) return 10;
    if (hours >= 64) return 9;
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
      // 1〜2級 / 精神1〜2級 / 療育A → 20点
      case DisabilityGrade.physical1to2:
        return 20;
      case DisabilityGrade.mental1:
        return 20;
      case DisabilityGrade.mental2:
        return 20;
      case DisabilityGrade.nursingA:
        return 20;
      case DisabilityGrade.pensionA:
        return 20;
      // 3級 / 精神3級 / 療育B → 18点
      case DisabilityGrade.physical3:
        return 18;
      case DisabilityGrade.mental3:
        return 18;
      case DisabilityGrade.nursingB:
        return 18;
      case DisabilityGrade.pensionB:
        return 18;
      // 4〜6級 → 16点
      case DisabilityGrade.physical4to6:
        return 16;
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
        return 13;
      case CareLevel.care1:
        return 13;
      case CareLevel.care2:
        return 15;
      case CareLevel.care3:
        return 18;
      case CareLevel.care4:
        return 20;
      case CareLevel.care5:
        return 20;
    }
  }

  // ---------------------------------------------------------------------------
  // 調整指数
  // ---------------------------------------------------------------------------

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;

    // ひとり親世帯（排他的: 高い方を採用）
    score += math.max(
      family.isSingleParent ? 26 : 0,
      family.isPseudoSingleParent ? 26 : 0,
    );

    if (family.isOnWelfare) score += 3;

    // 保育士（浦添市: +12）
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 12;
      case NurseryWorkerType.childcareSupporter:
        score += 12;
      case NurseryWorkerType.none:
        break;
    }

    if (family.returningFromLeave) score += 8;
    if (family.isTransferredAway) score += 3;
    if (family.isUsingNinkagai) score += 5;
    if (family.siblingAtFirstChoiceNursery) score += 3;
    if (family.twoSiblingsApplyingSameNursery) score += 1;
    if (family.isGraduatingFromSmallNursery) score += 300;

    // 減点項目
    if (family.acceptsLeaveExtension) score -= 300;
    if (family.hasUnpaidFees) score -= 10;

    return score;
  }
}
