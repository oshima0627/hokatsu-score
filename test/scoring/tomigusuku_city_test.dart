import 'package:hokatsu_score/models/care_level.dart';
import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/nursery_worker_type.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/tomigusuku_city.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TomigusukuCityScoringRule rule;

  setUp(() {
    rule = TomigusukuCityScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '豊見城市');
    expect(rule.fiscalYear, '令和8年度');
  });

  group('calcWorkScore - 就労時間境界値', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('63h → 0点', () => expect(rule.calcWorkScore(_emp(63)), 0));
    test('64h → 10点', () => expect(rule.calcWorkScore(_emp(64)), 10));
    test('80h → 12点', () => expect(rule.calcWorkScore(_emp(80)), 12));
    test('100h → 14点', () => expect(rule.calcWorkScore(_emp(100)), 14));
    test('120h → 16点', () => expect(rule.calcWorkScore(_emp(120)), 16));
    test('140h → 18点', () => expect(rule.calcWorkScore(_emp(140)), 18));
    test('160h → 20点', () => expect(rule.calcWorkScore(_emp(160)), 20));
  });

  group('calcWorkScore - 特殊ステータス', () {
    test('自営業（挙証なし） → 一律10点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.selfEmployedNoProof,
          monthlyWorkHours: 160)), 10);
    });
    test('求職中 → 9点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 9);
    });
    test('妊娠 → 20点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 20);
    });
    test('入院 → 20点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 20);
    });
  });

  group('calcDisabilityScore', () {
    test('身体1-2級 → 20点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical1to2)), 20);
    });
    test('身体3級 → 15点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical3)), 15);
    });
    test('身体4-6級 → 10点', () {
      expect(rule.calcDisabilityScore(const ParentProfile(
          disabilityGrade: DisabilityGrade.physical4to6)), 10);
    });
  });

  group('calcCareScore', () {
    test('介護中 + 要介護5 → 18点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care5)), 18);
    });
    test('介護中 + 要介護3 → 16点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care3)), 16);
    });
    test('介護中 + 要介護1 → 12点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care1)), 12);
    });
  });

  group('calcAdjustScore', () {
    FamilyProfile _family({
      bool isSingleParent = false,
      bool isPseudoSingleParent = false,
      bool isOnWelfare = false,
      NurseryWorkerType nurseryWorkerType = NurseryWorkerType.none,
      bool returningFromLeave = false,
      bool isUsingNinkagai = false,
      bool siblingAtFirstChoiceNursery = false,
      bool isGraduatingFromSmallNursery = false,
      bool grandparentCanCare = false,
      bool acceptsLeaveExtension = false,
      bool hasUnpaidFees = false,
    }) {
      return FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: isSingleParent,
        isPseudoSingleParent: isPseudoSingleParent,
        isOnWelfare: isOnWelfare,
        nurseryWorkerType: nurseryWorkerType,
        returningFromLeave: returningFromLeave,
        isUsingNinkagai: isUsingNinkagai,
        siblingAtFirstChoiceNursery: siblingAtFirstChoiceNursery,
        isGraduatingFromSmallNursery: isGraduatingFromSmallNursery,
        grandparentCanCare: grandparentCanCare,
        acceptsLeaveExtension: acceptsLeaveExtension,
        hasUnpaidFees: hasUnpaidFees,
      );
    }

    test('初期状態 → 0点', () {
      expect(rule.calcAdjustScore(_family()), 0);
    });
    test('ひとり親 → +12点', () {
      expect(rule.calcAdjustScore(_family(isSingleParent: true)), 12);
    });
    test('ひとり親みなし → +10点', () {
      expect(rule.calcAdjustScore(_family(isPseudoSingleParent: true)), 10);
    });
    test('両方true → 12点（高い方）', () {
      expect(rule.calcAdjustScore(_family(
          isSingleParent: true, isPseudoSingleParent: true)), 12);
    });
    test('生活保護 → +7点', () {
      expect(rule.calcAdjustScore(_family(isOnWelfare: true)), 7);
    });
    test('保育士（市内） → +15点', () {
      expect(rule.calcAdjustScore(
          _family(nurseryWorkerType: NurseryWorkerType.nurseryWorker)), 15);
    });
    test('きょうだい在園 → +11点', () {
      expect(rule.calcAdjustScore(
          _family(siblingAtFirstChoiceNursery: true)), 11);
    });
    test('育休延長 → -150点', () {
      expect(rule.calcAdjustScore(
          _family(acceptsLeaveExtension: true)), -150);
    });
    test('滞納 → -15点', () {
      expect(rule.calcAdjustScore(_family(hasUnpaidFees: true)), -15);
    });
  });

  group('ゴールデンテスト', () {
    test('共働き(父160h母120h) + ひとり親 + 認可外', () {
      // 父: 160h → 20点, 母: 120h → 16点
      // 調整: ひとり親(+12) + 認可外(+3) = +15
      // 合計: 20 + 16 + 15 = 51点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 160),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 120),
        isSingleParent: true,
        isUsingNinkagai: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 20);
      expect(result.motherBase, 16);
      expect(result.adjustScore, 15);
      expect(result.total, 51);
    });
  });
}
