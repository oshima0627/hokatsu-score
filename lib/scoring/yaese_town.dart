import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 八重瀬町の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.town.yaese.lg.jp/docs/2025091600012/
/// 特徴: 月間時間6段階（150h以上→10, 64h以上→5）。保育士加点が+10と高い。
class YaeseTownScoringRule extends ScoringRule {
  @override
  String get municipalityName => '八重瀬町';

  @override
  String get sourceUrl =>
      'https://www.town.yaese.lg.jp/docs/2025091600012/';

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
        return 9;
      case WorkStatus.pregnantMultiple:
        return 9;
      case WorkStatus.hospitalizedBedridden:
        return 10;
      case WorkStatus.medicalTreatmentSerious:
        return 9;
      case WorkStatus.medicalTreatmentMild:
        return 5;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        return _scoreByHours(parent.monthlyWorkHours);
      case WorkStatus.jobSeeking:
        return 3;
      case WorkStatus.parentalLeave:
        return 5;
      case WorkStatus.pseudoParentalLeave:
        return 5;
      case WorkStatus.notSpecified:
        return 0;
    }
  }

  /// 月の就労時間から点数（八重瀬町の6段階）
  int _scoreByHours(int hours) {
    if (hours >= 150) return 10;
    if (hours >= 140) return 9;
    if (hours >= 120) return 8;
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
      case DisabilityGrade.nursingB:
        return 8;
      case DisabilityGrade.pensionB:
        return 8;
      case DisabilityGrade.physical4to6:
        return 6;
      case DisabilityGrade.mental3:
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
        return 6;
      case CareLevel.support2:
        return 6;
      case CareLevel.care1:
        return 6;
      case CareLevel.care2:
        return 6;
      case CareLevel.care3:
        return 8;
      case CareLevel.care4:
        return 8;
      case CareLevel.care5:
        return 8;
    }
  }

  // ---------------------------------------------------------------------------
  // 調整指数
  // ---------------------------------------------------------------------------

  @override
  int calcAdjustScore(FamilyProfile family) {
    int score = 0;

    // ひとり親（単独14, 祖父母同居12）
    score += math.max(
      family.isSingleParent ? 14 : 0,
      family.isPseudoSingleParent ? 12 : 0,
    );

    if (family.isOnWelfare) score += 3;
    if (family.siblingHasDisability) score += 3;

    // 保育士: +10点
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 10;
      case NurseryWorkerType.childcareSupporter:
        score += 5;
      case NurseryWorkerType.none:
        break;
    }

    // きょうだいが希望園に在園 → +5
    if (family.siblingAtFirstChoiceNursery) score += 5;
    if (family.twoSiblingsApplyingSameNursery) score += 1;

    // 同居者が保育可能
    if (family.grandparentCanCare) score -= 3;

    // 保育料滞納
    if (family.hasUnpaidFees) score -= 5;

    return score;
  }
}
