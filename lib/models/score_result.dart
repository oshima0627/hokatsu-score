/// スコア計算結果
class ScoreResult {
  const ScoreResult({
    required this.municipalityName,
    required this.fiscalYear,
    required this.fatherBase,
    required this.motherBase,
    required this.adjustScore,
    required this.total,
  });

  /// 自治体名
  final String municipalityName;

  /// 対象年度（例：令和8年度）
  final String fiscalYear;

  /// 父の基本指数
  final int fatherBase;

  /// 母の基本指数
  final int motherBase;

  /// 調整指数
  final int adjustScore;

  /// 合計指数
  final int total;
}
