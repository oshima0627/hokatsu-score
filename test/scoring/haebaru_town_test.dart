import 'package:hokatsu_score/models/care_level.dart';
import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/haebaru_town.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HaebaruTownScoringRule rule;

  setUp(() {
    rule = HaebaruTownScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '南風原町');
    expect(rule.fiscalYear, '令和8年度');
  });

  group('calcWorkScore - 就労時間境界値', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('63h → 0点', () => expect(rule.calcWorkScore(_emp(63)), 0));
    test('64h → 5点', () => expect(rule.calcWorkScore(_emp(64)), 5));
    test('80h → 6点', () => expect(rule.calcWorkScore(_emp(80)), 6));
    test('100h → 7点', () => expect(rule.calcWorkScore(_emp(100)), 7));
    test('135h → 8点', () => expect(rule.calcWorkScore(_emp(135)), 8));
    test('155h → 9点', () => expect(rule.calcWorkScore(_emp(155)), 9));
    test('170h → 10点', () => expect(rule.calcWorkScore(_emp(170)), 10));
  });

  group('calcWorkScore - 固定値', () {
    test('妊娠 → 10点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 10);
    });
    test('求職中 → 4点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 4);
    });
  });

  group('calcDisabilityScore', () {
    test('身体1-2級 → 10点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical1to2)), 10);
    });
    test('身体3級 → 8点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical3)), 8);
    });
    test('身体4-6級 → 6点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical4to6)), 6);
    });
  });

  group('calcCareScore', () {
    test('介護中 + 要介護5 → 10点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care5)), 10);
    });
    test('介護中 + 要支援1 → 5点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.support1)), 5);
    });
  });

  group('calcTotalScore - 初期状態', () {
    test('初期状態 → 0点', () {
      expect(rule.calcTotalScore(FamilyProfile.initial()), 0);
    });
  });

  group('calcAdjustScore', () {
    test('ひとり親(単独) → +14点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 14);
    });
    test('生活保護 → +4点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isOnWelfare: true,
      );
      expect(rule.calcAdjustScore(f), 4);
    });
    test('滞納 → -8点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        hasUnpaidFees: true,
      );
      expect(rule.calcAdjustScore(f), -8);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父170h母135h) + ひとり親', () {
      // 父: 170h→10点, 母: 135h→8点, 調整: ひとり親+14 = 32点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 170),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 135),
        isSingleParent: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 10);
      expect(result.motherBase, 8);
      expect(result.adjustScore, 14);
      expect(result.total, 32);
    });
  });
}
