import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/nursery_worker_type.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/yaese_town.dart';
import 'package:test/test.dart';

void main() {
  late YaeseTownScoringRule rule;

  setUp(() {
    rule = YaeseTownScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '八重瀬町');
    expect(rule.fiscalYear, '令和8年度');
  });

  group('calcWorkScore - 就労時間境界値', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('63h → 0点', () => expect(rule.calcWorkScore(_emp(63)), 0));
    test('64h → 5点', () => expect(rule.calcWorkScore(_emp(64)), 5));
    test('80h → 6点', () => expect(rule.calcWorkScore(_emp(80)), 6));
    test('100h → 7点', () => expect(rule.calcWorkScore(_emp(100)), 7));
    test('120h → 8点', () => expect(rule.calcWorkScore(_emp(120)), 8));
    test('140h → 9点', () => expect(rule.calcWorkScore(_emp(140)), 9));
    test('150h → 10点', () => expect(rule.calcWorkScore(_emp(150)), 10));
  });

  group('calcWorkScore - 固定値', () {
    test('妊娠 → 9点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 9);
    });
    test('入院 → 10点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 10);
    });
    test('求職中 → 3点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 3);
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
    test('保育士 → +10点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        nurseryWorkerType: NurseryWorkerType.nurseryWorker,
      );
      expect(rule.calcAdjustScore(f), 10);
    });
    test('きょうだい在園 → +5点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        siblingAtFirstChoiceNursery: true,
      );
      expect(rule.calcAdjustScore(f), 5);
    });
    test('同居者保育可能 → -3点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        grandparentCanCare: true,
      );
      expect(rule.calcAdjustScore(f), -3);
    });
    test('滞納 → -5点', () {
      final f = FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        hasUnpaidFees: true,
      );
      expect(rule.calcAdjustScore(f), -5);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父150h母120h) + ひとり親 + 保育士', () {
      // 父: 150h→10点, 母: 120h→8点
      // 調整: ひとり親(+14) + 保育士(+10) = +24
      // 合計: 10 + 8 + 24 = 42点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 150),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 120),
        isSingleParent: true,
        nurseryWorkerType: NurseryWorkerType.nurseryWorker,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 10);
      expect(result.motherBase, 8);
      expect(result.adjustScore, 24);
      expect(result.total, 42);
    });
  });
}
