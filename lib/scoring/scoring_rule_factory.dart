import 'haebaru_town.dart';
import 'itoman_city.dart';
import 'municipality.dart';
import 'naha_city.dart';
import 'nanjo_city.dart';
import 'scoring_rule.dart';
import 'tomigusuku_city.dart';
import 'urasoe_city.dart';
import 'yaese_town.dart';
import 'yonabaru_town.dart';

/// 自治体に対応する [ScoringRule] を生成するファクトリ。
class ScoringRuleFactory {
  ScoringRuleFactory._();

  static ScoringRule of(Municipality municipality) {
    switch (municipality) {
      case Municipality.naha:
        return NahaCityScoringRule();
      case Municipality.urasoe:
        return UrasoeCityScoringRule();
      case Municipality.tomigusuku:
        return TomigusukuCityScoringRule();
      case Municipality.itoman:
        return ItomanCityScoringRule();
      case Municipality.nanjo:
        return NanjoCityScoringRule();
      case Municipality.haebaru:
        return HaebaruTownScoringRule();
      case Municipality.yonabaru:
        return YonabaruTownScoringRule();
      case Municipality.yaese:
        return YaeseTownScoringRule();
    }
  }
}
