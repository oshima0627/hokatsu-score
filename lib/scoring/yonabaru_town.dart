import 'dart:math' as math;

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import 'scoring_rule.dart';

/// 与那原町の保育指数スコアリングルール（令和8年度基準）
///
/// 参照: https://www.town.yonabaru.okinawa.jp/soshiki/11/129.html
/// 特徴: 就労は「1日の時間 x 月の日数」マトリクス + 居宅外/内/内職の3類型。
/// 本アプリでは月の就労時間から近似的に点数を算出する。
class YonabaruTownScoringRule extends ScoringRule {
  @override
  String get municipalityName => '与那原町';

  @override
  String get sourceUrl =>
      'https://www.town.yonabaru.okinawa.jp/soshiki/11/129.html';

  @override
  String get fiscalYear => '令和8年度';

  // ---------------------------------------------------------------------------
  // 就労スコア
  // ---------------------------------------------------------------------------

  @override
  int calcWorkScore(ParentProfile parent) {
    switch (parent.workStatus) {
      case WorkStatus.employed:
        // 居宅外労働: 月の就労時間から近似判定
        return _scoreOutsideHome(parent.monthlyWorkHours);
      case WorkStatus.selfEmployedNoProof:
        // 内職・自営業協力者（挙証なし）: 居宅内労働より低い配点
        return _scoreInsideHome(parent.monthlyWorkHours);
      case WorkStatus.employedProspect:
        return 3; // 求職中と同等
      case WorkStatus.pregnant:
        return 8;
      case WorkStatus.pregnantMultiple:
        return 8;
      case WorkStatus.hospitalizedBedridden:
        return 10;
      case WorkStatus.medicalTreatmentSerious:
        return 9;
      case WorkStatus.medicalTreatmentMild:
        return 7;
      case WorkStatus.caregiving:
        return 0;
      case WorkStatus.student:
        // 1日8h x 5日 = 月160h以上 → 10点、それ以外 → 7点
        return parent.monthlyWorkHours >= 160 ? 10 : 7;
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

  /// 居宅外労働: 月の就労時間から近似判定
  /// 1日7h x 月20日 = 140h → 10点を最高とする
  int _scoreOutsideHome(int hours) {
    if (hours >= 140) return 10;
    if (hours >= 120) return 9;
    if (hours >= 100) return 8;
    if (hours >= 80) return 7;
    if (hours >= 64) return 6;
    if (hours >= 48) return 5;
    return 0;
  }

  /// 居宅内労働（自営業等）: 居宅外より1点低い
  int _scoreInsideHome(int hours) {
    if (hours >= 140) return 9;
    if (hours >= 120) return 8;
    if (hours >= 100) return 7;
    if (hours >= 80) return 6;
    if (hours >= 64) return 5;
    if (hours >= 48) return 4;
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
        return 3;
      case CareLevel.support2:
        return 4;
      case CareLevel.care1:
        return 6;
      case CareLevel.care2:
        return 6;
      case CareLevel.care3:
        return 8;
      case CareLevel.care4:
        return 8;
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

    // ひとり親
    score += math.max(
      family.isSingleParent ? 13 : 0,
      family.isPseudoSingleParent ? 13 : 0,
    );

    if (family.isOnWelfare) score += 3;
    if (family.siblingHasDisability) score += 3;

    // 保育士（月120h以上）→ +7
    switch (family.nurseryWorkerType) {
      case NurseryWorkerType.nurseryWorker:
        score += 7;
      case NurseryWorkerType.childcareSupporter:
        score += 3;
      case NurseryWorkerType.none:
        break;
    }

    if (family.siblingAtFirstChoiceNursery) score += 1;
    if (family.twoSiblingsApplyingSameNursery) score += 1;

    // 65歳未満同居祖父母
    if (family.grandparentCanCare) score -= 1;

    // 保育料滞納
    if (family.hasUnpaidFees) score -= 3;

    return score;
  }
}
