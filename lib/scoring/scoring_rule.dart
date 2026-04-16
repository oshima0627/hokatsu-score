import 'dart:math' as math;

import '../models/family_profile.dart';
import '../models/parent_profile.dart';
import '../models/score_result.dart';

/// 自治体ごとのスコアリングルールを定義する抽象クラス。
///
/// 各自治体は本クラスを継承し、独自の配点ロジックを実装する。
/// デフォルトでは基本指数 = max(就労, 障害, 介護) を採用。
/// 合算方式の自治体は [calcBaseScore] をオーバーライドする。
abstract class ScoringRule {
  /// 自治体名（UI表示用）
  String get municipalityName;

  /// 公式資料URL
  String get sourceUrl;

  /// 対象年度（例：令和8年度）
  String get fiscalYear;

  /// 就労状況に基づくスコア
  int calcWorkScore(ParentProfile parent);

  /// 障害等級に基づくスコア
  int calcDisabilityScore(ParentProfile parent);

  /// 介護状況に基づくスコア
  int calcCareScore(ParentProfile parent);

  /// 基本指数（デフォルト：就労・障害・介護の最大値）
  ///
  /// 合算方式の自治体はオーバーライドすること。
  int calcBaseScore(ParentProfile parent) {
    return [
      calcWorkScore(parent),
      calcDisabilityScore(parent),
      calcCareScore(parent),
    ].reduce(math.max);
  }

  /// 調整指数（世帯状況に基づく加減点）
  int calcAdjustScore(FamilyProfile family);

  /// 合計指数 = 父の基本指数 + 母の基本指数 + 調整指数
  int calcTotalScore(FamilyProfile family) {
    return calcBaseScore(family.father) +
        calcBaseScore(family.mother) +
        calcAdjustScore(family);
  }

  /// [ScoreResult] を生成する
  ScoreResult calcResult(FamilyProfile family) {
    return ScoreResult(
      municipalityName: municipalityName,
      fiscalYear: fiscalYear,
      fatherBase: calcBaseScore(family.father),
      motherBase: calcBaseScore(family.mother),
      adjustScore: calcAdjustScore(family),
      total: calcTotalScore(family),
    );
  }
}
