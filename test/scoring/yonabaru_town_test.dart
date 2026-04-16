import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/yonabaru_town.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late YonabaruTownScoringRule rule;

  setUp(() {
    rule = YonabaruTownScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '与那原町');
    expect(rule.fiscalYear, '令和8年度');
  });

  group('calcWorkScore - 居宅外就労', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('140h → 10点', () => expect(rule.calcWorkScore(_emp(140)), 10));
    test('120h → 9点', () => expect(rule.calcWorkScore(_emp(120)), 9));
    test('100h → 8点', () => expect(rule.calcWorkScore(_emp(100)), 8));
    test('80h → 7点', () => expect(rule.calcWorkScore(_emp(80)), 7));
    test('64h → 6点', () => expect(rule.calcWorkScore(_emp(64)), 6));
    test('48h → 5点', () => expect(rule.calcWorkScore(_emp(48)), 5));
    test('47h → 0点', () => expect(rule.calcWorkScore(_emp(47)), 0));
  });

  group('calcWorkScore - 居宅内（自営業）', () {
    test('140h → 9点（居宅外より-1）', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.selfEmployedNoProof,
          monthlyWorkHours: 140)), 9);
    });
  });

  group('calcWorkScore - 固定値', () {
    test('求職中 → 3点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 3);
    });
    test('入院 → 10点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 10);
    });
  });

  group('calcAdjustScore', () {
    test('ひとり親 → +13点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 13);
    });
    test('滞納 → -3点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        hasUnpaidFees: true,
      );
      expect(rule.calcAdjustScore(f), -3);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父140h母100h) + ひとり親', () {
      // 父: 140h→10点, 母: 100h→8点, 調整: ひとり親+13 = 31点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 140),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 100),
        isSingleParent: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 10);
      expect(result.motherBase, 8);
      expect(result.adjustScore, 13);
      expect(result.total, 31);
    });
  });
}
