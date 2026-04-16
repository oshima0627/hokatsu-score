import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/itoman_city.dart';
import 'package:test/test.dart';

void main() {
  late ItomanCityScoringRule rule;

  setUp(() {
    rule = ItomanCityScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '糸満市');
    expect(rule.fiscalYear, '令和8年度');
  });

  // 糸満市は週単位。月→週換算: 月÷4.33
  // 週38h≈月164.5h, 週35h≈月151.6h, 週30h≈月129.9h
  // 週25h≈月108.3h, 週20h≈月86.6h, 週16h≈月69.3h

  group('calcWorkScore - 就労時間（週換算）', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('165h(≈週38h) → 10点', () => expect(rule.calcWorkScore(_emp(165)), 10));
    test('152h(≈週35h) → 9点', () => expect(rule.calcWorkScore(_emp(152)), 9));
    test('130h(≈週30h) → 8点', () => expect(rule.calcWorkScore(_emp(130)), 8));
    test('109h(≈週25h) → 7点', () => expect(rule.calcWorkScore(_emp(109)), 7));
    test('87h(≈週20h) → 6点', () => expect(rule.calcWorkScore(_emp(87)), 6));
    test('70h(≈週16h) → 5点', () => expect(rule.calcWorkScore(_emp(70)), 5));
    test('60h(≈週14h) → 4点', () => expect(rule.calcWorkScore(_emp(60)), 4));
  });

  group('calcWorkScore - 自営業（根拠書類なし）→ -1', () {
    test('165h → 10-1=9点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.selfEmployedNoProof,
          monthlyWorkHours: 165)), 9);
    });
    test('70h → 5-1=4点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.selfEmployedNoProof,
          monthlyWorkHours: 70)), 4);
    });
  });

  group('calcWorkScore - 固定値', () {
    test('妊娠 → 12点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 12);
    });
    test('入院 → 10点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 10);
    });
    test('求職中 → 4点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 4);
    });
    test('育休中 → 2点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.parentalLeave)), 2);
    });
  });

  group('calcDisabilityScore', () {
    test('身体1-2級 → 10点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical1to2)), 10);
    });
    test('身体3級 → 9点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical3)), 9);
    });
    test('身体4-6級 → 7点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical4to6)), 7);
    });
  });

  group('calcAdjustScore', () {
    test('ひとり親 → +15点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 15);
    });

    test('ひとり親みなし → +12点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isPseudoSingleParent: true,
      );
      expect(rule.calcAdjustScore(f), 12);
    });

    test('育休延長 → -10点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        acceptsLeaveExtension: true,
      );
      expect(rule.calcAdjustScore(f), -10);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父165h母130h) + ひとり親 + きょうだい在園', () {
      // 父: 165h ≈ 週38h → 10点, 母: 130h ≈ 週30h → 8点
      // 調整: ひとり親(+15) + きょうだい(+1) = +16
      // 合計: 10 + 8 + 16 = 34点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 165),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 130),
        isSingleParent: true,
        siblingAtFirstChoiceNursery: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 10);
      expect(result.motherBase, 8);
      expect(result.adjustScore, 16);
      expect(result.total, 34);
    });
  });
}
