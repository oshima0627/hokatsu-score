import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/nursery_worker_type.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/nanjo_city.dart';
import 'package:test/test.dart';

void main() {
  late NanjoCityScoringRule rule;

  setUp(() {
    rule = NanjoCityScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '南城市');
    expect(rule.fiscalYear, '令和8年度');
  });

  // 南城市は週単位。月→週換算: 月÷4.33
  // 週38h = 月164.5h, 週35h = 月151.6h, 週30h = 月129.9h
  // 週25h = 月108.3h, 週20h = 月86.6h, 週16h = 月69.3h

  group('calcWorkScore - 就労時間（週換算）', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('165h(≈週38h) → 20点', () => expect(rule.calcWorkScore(_emp(165)), 20));
    test('152h(≈週35h) → 19点', () => expect(rule.calcWorkScore(_emp(152)), 19));
    test('130h(≈週30h) → 18点', () => expect(rule.calcWorkScore(_emp(130)), 18));
    test('109h(≈週25h) → 17点', () => expect(rule.calcWorkScore(_emp(109)), 17));
    test('87h(≈週20h) → 16点', () => expect(rule.calcWorkScore(_emp(87)), 16));
    test('70h(≈週16h) → 15点', () => expect(rule.calcWorkScore(_emp(70)), 15));
    test('60h(≈週14h) → 0点', () => expect(rule.calcWorkScore(_emp(60)), 0));
  });

  group('calcWorkScore - 固定値', () {
    test('妊娠 → 18点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 18);
    });
    test('入院 → 20点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 20);
    });
    test('求職中 → 10点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 10);
    });
  });

  group('calcDisabilityScore', () {
    test('身体1-2級 → 20点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical1to2)), 20);
    });
    test('身体3級 → 18点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical3)), 18);
    });
    test('身体4-6級 → 16点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical4to6)), 16);
    });
  });

  group('calcAdjustScore', () {
    test('ひとり親 → +25点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 25);
    });

    test('ひとり親みなし → +19点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isPseudoSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 19);
    });

    test('自営業の減点 → -2点', () {
      final f = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.selfEmployedNoProof, monthlyWorkHours: 160),
        mother: const ParentProfile.initial(),
      );
      expect(rule.calcAdjustScore(f), -2);
    });

    test('保育士 → +7点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        nurseryWorkerType: NurseryWorkerType.nurseryWorker,
      );
      expect(rule.calcAdjustScore(f), 7);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父165h母130h) + ひとり親 + きょうだい在園', () {
      // 父: 165h ≈ 週38h → 20点, 母: 130h ≈ 週30h → 18点
      // 調整: ひとり親(+25) + きょうだい(+2) = +27
      // 合計: 20 + 18 + 27 = 65点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 165),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 130),
        isSingleParent: true,
        siblingAtFirstChoiceNursery: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 20);
      expect(result.motherBase, 18);
      expect(result.adjustScore, 27);
      expect(result.total, 65);
    });
  });
}
