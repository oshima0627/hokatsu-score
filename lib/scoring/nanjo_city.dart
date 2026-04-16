import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 南城市の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.city.nanjo.okinawa.jp/userfiles/files/R08boshuuannai.pdf
/// 特徴: 就労基準が「週○時間」単位で規定されている。
/// 本アプリでは月の就労時間を入力するため、月→週への換算（÷4.33）で判定する。
class NanjoCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '南城市';

  @override
  String get sourceUrl =>
      'https://www.city.nanjo.okinawa.jp/userfiles/files/R08boshuuannai.pdf';

  @override
  String get fiscalYear => '令和8年度';

  // ---------------------------------------------------------------------------
  // 就労スコア
  // ---------------------------------------------------------------------------

  @override
  int calcWorkScore(ParentProfile parent) {
    switch (parent.workStatus) {
      case WorkStatus.employed:
        return _scoreByWeeklyHours(parent.monthlyWorkHours);
      case WorkStatus.selfEmployedNoProof:
        // 自営業は就労と同じ時間段階で判定（調整指数で-2される）
        return _scoreByWeeklyHours(parent.monthlyWorkHours);
      case WorkStatus.employedProspect:
        // 採用予定: 自営業と同様に調整で-2（基本は就労扱い）
        return _scoreByWeeklyHours(parent.monthlyWorkHours);
      case WorkStatus.pregnant:
        return 18;
      case WorkStatus.pregnantMultiple:
        return 18;
      case WorkStatus.hospitalizedBedridden:
        return 20;
      case WorkStatus.medicalTreatmentSerious:
        return 20;
      case WorkStatus.medicalTreatmentMild:
        return 15;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        // 大学等で週35h以上 → 17点、それ以外 → 12点
        // 月の就労時間を週換算して判定
        final weeklyHours = parent.monthlyWorkHours / 4.33;
        return weeklyHours >= 35 ? 17 : 12;
      case WorkStatus.jobSeeking:
        return 10;
      case WorkStatus.parentalLeave:
        // PDFでは育休は基本指数なし（調整指数+1のみ）
        return 0;
      case WorkStatus.pseudoParentalLeave:
        return 0;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間を週換算して南城市の段階に当てはめる
  int _scoreByWeeklyHours(int monthlyHours) {
    final weeklyHours = monthlyHours / 4.33;
    if (weeklyHours >= 38) return 20;
    if (weeklyHours >= 35) return 19;
    if (weeklyHours >= 30) return 18;
    if (weeklyHours >= 25) return 17;
    if (weeklyHours >= 20) return 16;
    if (weeklyHours >= 16) return 15;
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
      case DisabilityGrade.nursingA:
        return 20;
      case DisabilityGrade.mental1:
        return 20;
      case DisabilityGrade.pensionA:
        return 20;
      case DisabilityGrade.physical3:
        return 18;
      case DisabilityGrade.nursingB:
        return 18;
      case DisabilityGrade.mental2:
        return 18;
      case DisabilityGrade.pensionB:
        return 18;
      case DisabilityGrade.physical4to6:
        return 16;
      case DisabilityGrade.mental3:
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
        return 15;
      case CareLevel.support2:
        return 15;
      case CareLevel.care1:
        return 15;
      case CareLevel.care2:
        return 18;
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

    // ひとり親（排他的: 高い方を採用）
    score += math.max(
      family.isSingleParent ? 25 : 0,
      family.isPseudoSingleParent ? 19 : 0,
    );

    if (family.isOnWelfare) score += 5;

    // 保育士（南城市: 週35h以上=+7, 週25h以上=+5, 週16h以上=+3）
    // 簡略化: nurseryWorker=+7, childcareSupporter=+5
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 7;
      case NurseryWorkerType.childcareSupporter:
        score += 5;
      case NurseryWorkerType.none:
        break;
    }

    if (family.returningFromLeave) score += 1;
    if (family.hasDisabilityAndWorks) score += 3;
    if (family.isTransferredAway) score += 2;
    if (family.siblingAtFirstChoiceNursery) score += 2;
    if (family.twoSiblingsApplyingSameNursery) score += 1;
    if (family.siblingHasDisability) score += 5;

    // 自営業・採用予定の減点
    if (family.father.workStatus == WorkStatus.selfEmployedNoProof ||
        family.father.workStatus == WorkStatus.employedProspect) {
      score -= 2;
    }
    if (family.mother.workStatus == WorkStatus.selfEmployedNoProof ||
        family.mother.workStatus == WorkStatus.employedProspect) {
      score -= 2;
    }

    // 同一世帯に保育可能な親族がいる
    if (family.grandparentCanCare) score -= 5;

    if (family.hasUnpaidFees) score -= 10;

    return score;
  }
}
