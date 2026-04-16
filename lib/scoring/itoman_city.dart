import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 糸満市の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.city.itoman.lg.jp/soshiki/17/32254.html
/// 特徴: 就労基準が「週○時間」単位。配点スケールが4〜10点と他市より低め。
class ItomanCityScoringRule extends ScoringRule {
  @override
  String get municipalityName => '糸満市';

  @override
  String get sourceUrl =>
      'https://www.city.itoman.lg.jp/soshiki/17/32254.html';

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
        // 自営業（根拠書類なし）: 就労点数 -1
        return math.max(_scoreByWeeklyHours(parent.monthlyWorkHours) - 1, 0);
      case WorkStatus.employedProspect:
        // 就労・退職予定: 就労点数 -2
        return math.max(_scoreByWeeklyHours(parent.monthlyWorkHours) - 2, 0);
      case WorkStatus.pregnant:
        return 12;
      case WorkStatus.pregnantMultiple:
        return 12;
      case WorkStatus.hospitalizedBedridden:
        return 10;
      case WorkStatus.medicalTreatmentSerious:
        return 8;
      case WorkStatus.medicalTreatmentMild:
        return 6;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        return _studentByWeeklyHours(parent.monthlyWorkHours);
      case WorkStatus.jobSeeking:
        return 4;
      case WorkStatus.parentalLeave:
        return 2;
      case WorkStatus.pseudoParentalLeave:
        return 2;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間を週換算して糸満市の段階に当てはめる
  int _scoreByWeeklyHours(int monthlyHours) {
    final weeklyHours = monthlyHours / 4.33;
    if (weeklyHours >= 38) return 10;
    if (weeklyHours >= 35) return 9;
    if (weeklyHours >= 30) return 8;
    if (weeklyHours >= 25) return 7;
    if (weeklyHours >= 20) return 6;
    if (weeklyHours >= 16) return 5;
    return 4;
  }

  /// 就学の週時間段階
  int _studentByWeeklyHours(int monthlyHours) {
    final weeklyHours = monthlyHours / 4.33;
    if (weeklyHours >= 40) return 10;
    if (weeklyHours >= 30) return 8;
    if (weeklyHours >= 20) return 6;
    if (weeklyHours >= 16) return 5;
    return 4;
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
        return 9;
      case DisabilityGrade.mental2:
        return 9;
      case DisabilityGrade.nursingB:
        return 9;
      case DisabilityGrade.pensionB:
        return 9;
      case DisabilityGrade.physical4to6:
        return 7;
      case DisabilityGrade.mental3:
        return 7;
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
        return 6;
      case CareLevel.support2:
        return 6;
      case CareLevel.care1:
        return 7;
      case CareLevel.care2:
        return 7;
      case CareLevel.care3:
        return 8;
      case CareLevel.care4:
        return 9;
      case CareLevel.care5:
        return 9;
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
      family.isSingleParent ? 15 : 0,
      family.isPseudoSingleParent ? 12 : 0,
    );

    if (family.isOnWelfare) score += 3;
    if (family.isTransferredAway) score += 2;
    if (family.siblingHasDisability) score += 3;
    if (family.siblingAtFirstChoiceNursery) score += 1;
    if (family.isUsingNinkagai) score += 1;

    // 保育士は基準表では「優先利用」とされ、明確な加点値なし
    // ここでは保育士の場合のみ加点
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 3;
      case NurseryWorkerType.childcareSupporter:
        score += 1;
      case NurseryWorkerType.none:
        break;
    }

    // 育休延長許容
    if (family.acceptsLeaveExtension) score -= 10;

    return score;
  }
}
