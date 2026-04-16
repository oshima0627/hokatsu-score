import 'package:hokatsu_score/models/care_level.dart';
import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/nursery_worker_type.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/urasoe_city.dart';
import 'package:test/test.dart';

void main() {
  late UrasoeCityScoringRule rule;

  setUp(() {
    rule = UrasoeCityScoringRule();
  });

  test('メタ情報', () {
    expect(rule.municipalityName, '浦添市');
    expect(rule.fiscalYear, '令和8年度');
  });

  // ===========================================================================
  // 就労時間 境界値テスト（employed）
  // ===========================================================================

  group('calcWorkScore - 就労時間境界値', () {
    ParentProfile _emp(int h) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: h);

    test('63h → 0点', () => expect(rule.calcWorkScore(_emp(63)), 0));
    test('64h → 10点', () => expect(rule.calcWorkScore(_emp(64)), 10));
    test('79h → 10点', () => expect(rule.calcWorkScore(_emp(79)), 10));
    test('80h → 12点', () => expect(rule.calcWorkScore(_emp(80)), 12));
    test('99h → 12点', () => expect(rule.calcWorkScore(_emp(99)), 12));
    test('100h → 14点', () => expect(rule.calcWorkScore(_emp(100)), 14));
    test('119h → 14点', () => expect(rule.calcWorkScore(_emp(119)), 14));
    test('120h → 16点', () => expect(rule.calcWorkScore(_emp(120)), 16));
    test('139h → 16点', () => expect(rule.calcWorkScore(_emp(139)), 16));
    test('140h → 18点', () => expect(rule.calcWorkScore(_emp(140)), 18));
    test('159h → 18点', () => expect(rule.calcWorkScore(_emp(159)), 18));
    test('160h → 20点', () => expect(rule.calcWorkScore(_emp(160)), 20));
  });

  // ===========================================================================
  // 自営業テスト
  // ===========================================================================

  group('calcWorkScore - 自営業（挙証資料なし）', () {
    ParentProfile _self(int h) => ParentProfile(
        workStatus: WorkStatus.selfEmployedNoProof, monthlyWorkHours: h);

    test('64h → 9点', () => expect(rule.calcWorkScore(_self(64)), 9));
    test('80h → 10点', () => expect(rule.calcWorkScore(_self(80)), 10));
    test('100h → 11点', () => expect(rule.calcWorkScore(_self(100)), 11));
    test('120h → 12点', () => expect(rule.calcWorkScore(_self(120)), 12));
    test('140h → 13点', () => expect(rule.calcWorkScore(_self(140)), 13));
    test('160h → 14点', () => expect(rule.calcWorkScore(_self(160)), 14));
  });

  // ===========================================================================
  // 固定値ステータス
  // ===========================================================================

  group('calcWorkScore - 固定値', () {
    test('妊娠 → 20点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.pregnant)), 20);
    });
    test('入院 → 20点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.hospitalizedBedridden)), 20);
    });
    test('療養重度 → 18点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.medicalTreatmentSerious)), 18);
    });
    test('療養軽度 → 14点', () {
      expect(rule.calcWorkScore(const ParentProfile(
          workStatus: WorkStatus.medicalTreatmentMild)), 14);
    });
    test('求職中 → 3点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.jobSeeking)), 3);
    });
    test('育休中 → 8点', () {
      expect(rule.calcWorkScore(
          const ParentProfile(workStatus: WorkStatus.parentalLeave)), 8);
    });
  });

  // ===========================================================================
  // 障害スコア
  // ===========================================================================

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

  // ===========================================================================
  // 介護スコア
  // ===========================================================================

  group('calcCareScore', () {
    test('介護中 + 要介護5 → 20点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care5)), 20);
    });
    test('介護中 + 要介護2 → 15点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.care2)), 15);
    });
    test('介護中 + 要支援1 → 10点', () {
      expect(rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving, careLevel: CareLevel.support1)),
          10);
    });
  });

  // ===========================================================================
  // 調整指数
  // ===========================================================================

  group('calcAdjustScore', () {
    FamilyProfile _family({
      bool isSingleParent = false,
      bool isOnWelfare = false,
      NurseryWorkerType nurseryWorkerType = NurseryWorkerType.none,
      bool returningFromLeave = false,
      bool isTransferredAway = false,
      bool isUsingNinkagai = false,
      bool siblingAtFirstChoiceNursery = false,
      bool twoSiblingsApplyingSameNursery = false,
      bool isGraduatingFromSmallNursery = false,
      bool acceptsLeaveExtension = false,
      bool hasUnpaidFees = false,
    }) {
      return FamilyProfile(
        father: const ParentProfile.initial(),
        mother: const ParentProfile.initial(),
        isSingleParent: isSingleParent,
        isOnWelfare: isOnWelfare,
        nurseryWorkerType: nurseryWorkerType,
        returningFromLeave: returningFromLeave,
        isTransferredAway: isTransferredAway,
        isUsingNinkagai: isUsingNinkagai,
        siblingAtFirstChoiceNursery: siblingAtFirstChoiceNursery,
        twoSiblingsApplyingSameNursery: twoSiblingsApplyingSameNursery,
        isGraduatingFromSmallNursery: isGraduatingFromSmallNursery,
        acceptsLeaveExtension: acceptsLeaveExtension,
        hasUnpaidFees: hasUnpaidFees,
      );
    }

    test('初期状態 → 0点', () {
      expect(rule.calcAdjustScore(_family()), 0);
    });
    test('ひとり親 → +26点', () {
      expect(rule.calcAdjustScore(_family(isSingleParent: true)), 26);
    });
    test('生活保護 → +3点', () {
      expect(rule.calcAdjustScore(_family(isOnWelfare: true)), 3);
    });
    test('保育士 → +12点', () {
      expect(rule.calcAdjustScore(
          _family(nurseryWorkerType: NurseryWorkerType.nurseryWorker)), 12);
    });
    test('育休復帰 → +8点', () {
      expect(rule.calcAdjustScore(_family(returningFromLeave: true)), 8);
    });
    test('認可外利用 → +5点', () {
      expect(rule.calcAdjustScore(_family(isUsingNinkagai: true)), 5);
    });
    test('地域型卒園 → +300点', () {
      expect(rule.calcAdjustScore(
          _family(isGraduatingFromSmallNursery: true)), 300);
    });
    test('育休延長許容 → -300点', () {
      expect(rule.calcAdjustScore(
          _family(acceptsLeaveExtension: true)), -300);
    });
    test('滞納 → -10点', () {
      expect(rule.calcAdjustScore(_family(hasUnpaidFees: true)), -10);
    });
  });

  // ===========================================================================
  // ゴールデンテスト
  // ===========================================================================

  group('ゴールデンテスト', () {
    test('共働き(父160h母120h) + ひとり親 + きょうだい在園', () {
      // 父: 160h → 20点, 母: 120h → 16点
      // 調整: ひとり親(+26) + きょうだい(+3) = +29
      // 合計: 20 + 16 + 29 = 65点
      final family = FamilyProfile(
        father: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 160),
        mother: const ParentProfile(
            workStatus: WorkStatus.employed, monthlyWorkHours: 120),
        isSingleParent: true,
        siblingAtFirstChoiceNursery: true,
      );
      final result = rule.calcResult(family);
      expect(result.fatherBase, 20);
      expect(result.motherBase, 16);
      expect(result.adjustScore, 29);
      expect(result.total, 65);
    });
  });
}
