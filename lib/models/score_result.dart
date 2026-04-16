/// スコア計算結果
class ScoreResult {
  const ScoreResult({
    required this.municipalityName,
    required this.fiscalYear,
    required this.fatherBase,
    required this.motherBase,
    required this.adjustScore,
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

  /// 合計指数（算出値）
  int get total => fatherBase + motherBase + adjustScore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreResult &&
          runtimeType == other.runtimeType &&
          municipalityName == other.municipalityName &&
          fiscalYear == other.fiscalYear &&
          fatherBase == other.fatherBase &&
          motherBase == other.motherBase &&
          adjustScore == other.adjustScore;

  @override
  int get hashCode => Object.hash(
        municipalityName,
        fiscalYear,
        fatherBase,
        motherBase,
        adjustScore,
      );
}
