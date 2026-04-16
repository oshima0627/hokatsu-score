import 'municipality.dart';
import 'naha_city.dart';
import 'scoring_rule.dart';

/// 自治体に対応する [ScoringRule] を生成するファクトリ。
class ScoringRuleFactory {
  ScoringRuleFactory._();

  static ScoringRule of(Municipality municipality) {
    switch (municipality) {
      case Municipality.naha:
        return NahaCityScoringRule();
      case Municipality.urasoe:
      case Municipality.tomigusuku:
      case Municipality.itoman:
      case Municipality.nanjo:
      case Municipality.haebaru:
      case Municipality.yonabaru:
      case Municipality.yaese:
        // TODO: 各自治体の実装を追加
        throw UnimplementedError(
          '${municipality.displayName}のスコアリングルールは未実装です',
        );
    }
  }
}
