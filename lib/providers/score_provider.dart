import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/score_result.dart';
import '../scoring/scoring_rule_factory.dart';
import 'family_provider.dart';
import 'municipality_provider.dart';
import 'parent_provider.dart';

/// スコア計算結果（リアクティブに再計算される）
final scoreResultProvider = Provider<ScoreResult>((ref) {
  final father = ref.watch(fatherProfileProvider);
  final mother = ref.watch(motherProfileProvider);
  final familyBase = ref.watch(familyProfileProvider);
  final municipality = ref.watch(selectedMunicipalityProvider);

  final rule = ScoringRuleFactory.of(municipality);
  final family = familyBase.copyWith(father: father, mother: mother);

  return rule.calcResult(family);
});
