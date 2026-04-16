import 'package:hokatsu_score/models/care_level.dart';
import 'package:hokatsu_score/models/disability_grade.dart';
import 'package:hokatsu_score/models/family_profile.dart';
import 'package:hokatsu_score/models/nursery_worker_type.dart';
import 'package:hokatsu_score/models/parent_profile.dart';
import 'package:hokatsu_score/models/work_status.dart';
import 'package:hokatsu_score/scoring/naha_city.dart';
import 'package:test/test.dart';

void main() {
  late NahaCityScoringRule rule;

  setUp(() {
    rule = NahaCityScoringRule();
  });

  // ===========================================================================
  // メタ情報
  // ===========================================================================

  test('municipalityName / fiscalYear / sourceUrl が正しい', () {
    expect(rule.municipalityName, '那覇市');
    expect(rule.fiscalYear, '令和8年度');
    expect(rule.sourceUrl, contains('naha.okinawa.jp'));
  });

  // ===========================================================================
  // 就労時間 境界値テスト（employed）
  // ===========================================================================

  group('calcWorkScore - 就労時間境界値（employed）', () {
    ParentProfile _employed(int hours) =>
        ParentProfile(workStatus: WorkStatus.employed, monthlyWorkHours: hours);

    test('63h → 0点（64h未満）', () {
      expect(rule.calcWorkScore(_employed(63)), 0);
    });

    test('64h → 15点（≥64h）', () {
      expect(rule.calcWorkScore(_employed(64)), 15);
    });

    test('89h → 15点（90h未満）', () {
      expect(rule.calcWorkScore(_employed(89)), 15);
    });

    test('90h → 19点（≥90h）', () {
      expect(rule.calcWorkScore(_employed(90)), 19);
    });

    test('119h → 19点（120h未満）', () {
      expect(rule.calcWorkScore(_employed(119)), 19);
    });

    test('120h → 22点（≥120h）', () {
      expect(rule.calcWorkScore(_employed(120)), 22);
    });

    test('139h → 22点（140h未満）', () {
      expect(rule.calcWorkScore(_employed(139)), 22);
    });

    test('140h → 26点（≥140h）', () {
      expect(rule.calcWorkScore(_employed(140)), 26);
    });

    test('159h → 26点（160h未満）', () {
      expect(rule.calcWorkScore(_employed(159)), 26);
    });

    test('160h → 30点（≥160h）', () {
      expect(rule.calcWorkScore(_employed(160)), 30);
    });

    test('200h → 30点（上限なし）', () {
      expect(rule.calcWorkScore(_employed(200)), 30);
    });

    test('0h → 0点', () {
      expect(rule.calcWorkScore(_employed(0)), 0);
    });
  });

  // ===========================================================================
  // 自営業キャップテスト
  // ===========================================================================

  group('calcWorkScore - 自営業（証明書なし）キャップ', () {
    ParentProfile _self(int hours) => ParentProfile(
          workStatus: WorkStatus.selfEmployedNoProof,
          monthlyWorkHours: hours,
        );

    test('64h → 9点（15点が9にキャップ）', () {
      expect(rule.calcWorkScore(_self(64)), 9);
    });

    test('160h → 9点（30点が9にキャップ）', () {
      expect(rule.calcWorkScore(_self(160)), 9);
    });

    test('63h → 0点（0点はキャップ影響なし）', () {
      expect(rule.calcWorkScore(_self(63)), 0);
    });
  });

  // ===========================================================================
  // 就労状況 固定値テスト
  // ===========================================================================

  group('calcWorkScore - 固定値ステータス', () {
    test('採用予定 → 15点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.employedProspect)),
        15,
      );
    });

    test('妊娠中（単胎） → 18点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.pregnant)),
        18,
      );
    });

    test('妊娠中（多胎） → 23点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.pregnantMultiple)),
        23,
      );
    });

    test('入院・常時臥床 → 32点', () {
      expect(
        rule.calcWorkScore(const ParentProfile(
            workStatus: WorkStatus.hospitalizedBedridden)),
        32,
      );
    });

    test('療養中（重度） → 23点', () {
      expect(
        rule.calcWorkScore(const ParentProfile(
            workStatus: WorkStatus.medicalTreatmentSerious)),
        23,
      );
    });

    test('療養中（軽度） → 12点', () {
      expect(
        rule.calcWorkScore(const ParentProfile(
            workStatus: WorkStatus.medicalTreatmentMild)),
        12,
      );
    });

    test('求職中 → 9点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.jobSeeking)),
        9,
      );
    });

    test('育休中 → 15点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.parentalLeave)),
        15,
      );
    });

    test('みなし育休中 → 7点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.pseudoParentalLeave)),
        7,
      );
    });

    test('介護中 → 0点（就労スコアは0）', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.caregiving)),
        0,
      );
    });

    test('未選択 → 0点', () {
      expect(
        rule.calcWorkScore(
            const ParentProfile(workStatus: WorkStatus.notSpecified)),
        0,
      );
    });
  });

  // ===========================================================================
  // 就学・職業訓練（時間ベース）
  // ===========================================================================

  group('calcWorkScore - 就学・職業訓練', () {
    ParentProfile _student(int hours) =>
        ParentProfile(workStatus: WorkStatus.student, monthlyWorkHours: hours);

    test('120h → 22点（時間ベースで計算）', () {
      expect(rule.calcWorkScore(_student(120)), 22);
    });

    test('63h → 0点', () {
      expect(rule.calcWorkScore(_student(63)), 0);
    });
  });

  // ===========================================================================
  // 障害スコア
  // ===========================================================================

  group('calcDisabilityScore', () {
    test('なし → 0点', () {
      expect(
        rule.calcDisabilityScore(const ParentProfile()),
        0,
      );
    });

    test('身体1〜2級 → 32点', () {
      expect(
        rule.calcDisabilityScore(const ParentProfile(
            disabilityGrade: DisabilityGrade.physical1to2)),
        32,
      );
    });

    test('身体3級 → 23点', () {
      expect(
        rule.calcDisabilityScore(const ParentProfile(
            disabilityGrade: DisabilityGrade.physical3)),
        23,
      );
    });

    test('身体4〜6級 → 12点', () {
      expect(
        rule.calcDisabilityScore(const ParentProfile(
            disabilityGrade: DisabilityGrade.physical4to6)),
        12,
      );
    });

    test('精神1級 → 32点', () {
      expect(
        rule.calcDisabilityScore(
            const ParentProfile(disabilityGrade: DisabilityGrade.mental1)),
        32,
      );
    });

    test('療育手帳A → 32点', () {
      expect(
        rule.calcDisabilityScore(
            const ParentProfile(disabilityGrade: DisabilityGrade.nursingA)),
        32,
      );
    });

    test('療育手帳B → 12点', () {
      expect(
        rule.calcDisabilityScore(
            const ParentProfile(disabilityGrade: DisabilityGrade.nursingB)),
        12,
      );
    });
  });

  // ===========================================================================
  // 介護スコア
  // ===========================================================================

  group('calcCareScore', () {
    test('介護中でない場合 → 0点', () {
      expect(
        rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.employed,
          careLevel: CareLevel.care5,
        )),
        0,
      );
    });

    test('介護中 + 要介護5 → 32点', () {
      expect(
        rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving,
          careLevel: CareLevel.care5,
        )),
        32,
      );
    });

    test('介護中 + 要介護1 → 19点', () {
      expect(
        rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving,
          careLevel: CareLevel.care1,
        )),
        19,
      );
    });

    test('介護中 + 要支援1 → 12点', () {
      expect(
        rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving,
          careLevel: CareLevel.support1,
        )),
        12,
      );
    });

    test('介護中 + なし → 0点', () {
      expect(
        rule.calcCareScore(const ParentProfile(
          workStatus: WorkStatus.caregiving,
          careLevel: CareLevel.none,
        )),
        0,
      );
    });
  });

  // ===========================================================================
  // 基本指数（max方式）
  // ===========================================================================

  group('calcBaseScore', () {
    test('就労30 > 障害0 > 介護0 → 30', () {
      expect(
        rule.calcBaseScore(const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        )),
        30,
      );
    });

    test('障害32 > 就労9 → 32（障害が高い場合）', () {
      expect(
        rule.calcBaseScore(const ParentProfile(
          workStatus: WorkStatus.jobSeeking,
          disabilityGrade: DisabilityGrade.physical1to2,
        )),
        32,
      );
    });

    test('介護32 > 就労0 > 障害0 → 32', () {
      expect(
        rule.calcBaseScore(const ParentProfile(
          workStatus: WorkStatus.caregiving,
          careLevel: CareLevel.care5,
        )),
        32,
      );
    });
  });

  // ===========================================================================
  // 調整指数
  // ===========================================================================

  group('calcAdjustScore', () {
    FamilyProfile _family({
      bool isSingleParent = false,
      bool isPseudoSingleParent = false,
      bool isYoungParent = false,
      bool isOnWelfare = false,
      NurseryWorkerType nurseryWorkerType = NurseryWorkerType.none,
      bool returningFromLeave = false,
      bool hasDisabilityAndWorks = false,
      bool isTransferredAway = false,
      bool isUsingNinkagai = false,
      bool siblingAtFirstChoiceNursery = false,
      bool twoSiblingsApplyingSameNursery = false,
      bool siblingHasDisability = false,
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
        isYoungParent: isYoungParent,
        isOnWelfare: isOnWelfare,
        nurseryWorkerType: nurseryWorkerType,
        returningFromLeave: returningFromLeave,
        hasDisabilityAndWorks: hasDisabilityAndWorks,
        isTransferredAway: isTransferredAway,
        isUsingNinkagai: isUsingNinkagai,
        siblingAtFirstChoiceNursery: siblingAtFirstChoiceNursery,
        twoSiblingsApplyingSameNursery: twoSiblingsApplyingSameNursery,
        siblingHasDisability: siblingHasDisability,
        isGraduatingFromSmallNursery: isGraduatingFromSmallNursery,
        grandparentCanCare: grandparentCanCare,
        acceptsLeaveExtension: acceptsLeaveExtension,
        hasUnpaidFees: hasUnpaidFees,
      );
    }

    test('初期状態（全false） → 0点', () {
      expect(rule.calcAdjustScore(_family()), 0);
    });

    test('ひとり親 → +50点', () {
      expect(rule.calcAdjustScore(_family(isSingleParent: true)), 50);
    });

    test('ひとり親みなし → +35点', () {
      expect(rule.calcAdjustScore(_family(isPseudoSingleParent: true)), 35);
    });

    test('ひとり親 + ひとり親みなし 両方true → 50点（高い方を採用）', () {
      expect(
        rule.calcAdjustScore(_family(
          isSingleParent: true,
          isPseudoSingleParent: true,
        )),
        50,
      );
    });

    test('18歳以下での出産 → +15点', () {
      expect(rule.calcAdjustScore(_family(isYoungParent: true)), 15);
    });

    test('生活保護受給中 → +3点', () {
      expect(rule.calcAdjustScore(_family(isOnWelfare: true)), 3);
    });

    test('保育士 → +50点', () {
      expect(
        rule.calcAdjustScore(
            _family(nurseryWorkerType: NurseryWorkerType.nurseryWorker)),
        50,
      );
    });

    test('子育て支援員 → +20点', () {
      expect(
        rule.calcAdjustScore(
            _family(nurseryWorkerType: NurseryWorkerType.childcareSupporter)),
        20,
      );
    });

    test('育児休業から復帰予定 → +9点', () {
      expect(rule.calcAdjustScore(_family(returningFromLeave: true)), 9);
    });

    test('障害者手帳保持かつ就労中 → +5点', () {
      expect(rule.calcAdjustScore(_family(hasDisabilityAndWorks: true)), 5);
    });

    test('単身赴任 → +5点', () {
      expect(rule.calcAdjustScore(_family(isTransferredAway: true)), 5);
    });

    test('認可外保育施設利用中 → +11点', () {
      expect(rule.calcAdjustScore(_family(isUsingNinkagai: true)), 11);
    });

    test('きょうだいが第1希望園に在園中 → +7点', () {
      expect(
          rule.calcAdjustScore(_family(siblingAtFirstChoiceNursery: true)), 7);
    });

    test('きょうだい2名同時同園申込 → +6点', () {
      expect(
        rule.calcAdjustScore(_family(twoSiblingsApplyingSameNursery: true)),
        6,
      );
    });

    test('きょうだいに障害児あり → +5点', () {
      expect(rule.calcAdjustScore(_family(siblingHasDisability: true)), 5);
    });

    test('地域型保育園卒園児 → +100点', () {
      expect(
        rule.calcAdjustScore(_family(isGraduatingFromSmallNursery: true)),
        100,
      );
    });

    test('65歳未満の近居祖父母が保育可能 → −3点', () {
      expect(rule.calcAdjustScore(_family(grandparentCanCare: true)), -3);
    });

    test('育休延長許容 → −500点', () {
      expect(
          rule.calcAdjustScore(_family(acceptsLeaveExtension: true)), -500);
    });

    test('保育料の滞納あり → −20点', () {
      expect(rule.calcAdjustScore(_family(hasUnpaidFees: true)), -20);
    });

    test('加点複数組み合わせ: ひとり親 + 認可外利用 + 育休復帰 = 50+11+9 = 70', () {
      expect(
        rule.calcAdjustScore(_family(
          isSingleParent: true,
          isUsingNinkagai: true,
          returningFromLeave: true,
        )),
        70,
      );
    });
  });

  // ===========================================================================
  // 合計指数（calcTotalScore）
  // ===========================================================================

  group('calcTotalScore', () {
    test('初期状態 → 0点', () {
      final family = FamilyProfile.initial();
      expect(rule.calcTotalScore(family), 0);
    });

    test('父160h就労 + 母160h就労 + 調整0 = 30+30+0 = 60点', () {
      final family = FamilyProfile(
        father: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        ),
        mother: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        ),
      );
      expect(rule.calcTotalScore(family), 60);
    });
  });

  // ===========================================================================
  // calcResult
  // ===========================================================================

  group('calcResult', () {
    test('ScoreResult の各フィールドが正しく設定される', () {
      final family = FamilyProfile(
        father: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 120,
        ),
        mother: const ParentProfile(
          workStatus: WorkStatus.parentalLeave,
        ),
        isSingleParent: false,
        isUsingNinkagai: true,
      );

      final result = rule.calcResult(family);

      expect(result.municipalityName, '那覇市');
      expect(result.fiscalYear, '令和8年度');
      expect(result.fatherBase, 22); // 120h → 22点
      expect(result.motherBase, 15); // 育休 → 15点
      expect(result.adjustScore, 11); // 認可外利用 → +11
      expect(result.total, 22 + 15 + 11); // 48点
    });
  });

  // ===========================================================================
  // ゴールデンテスト（典型的な共働き世帯）
  // ===========================================================================

  group('ゴールデンテスト', () {
    test('典型ケース: 共働き(父160h母120h) + ひとり親みなし + きょうだい在園', () {
      // 父: フルタイム就労160h → 基本30点
      // 母: パート就労120h → 基本22点
      // 調整: ひとり親みなし(+35) + きょうだい第1希望在園(+7) = +42
      // 合計: 30 + 22 + 42 = 94点

      final family = FamilyProfile(
        father: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        ),
        mother: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 120,
        ),
        isPseudoSingleParent: true,
        siblingAtFirstChoiceNursery: true,
      );

      final result = rule.calcResult(family);

      expect(result.fatherBase, 30);
      expect(result.motherBase, 22);
      expect(result.adjustScore, 42);
      expect(result.total, 94);
    });

    test('最高点ケース: 両親フルタイム + 地域型卒園 + ひとり親 + 保育士', () {
      // 父: フルタイム160h → 30点
      // 母: フルタイム160h → 30点
      // 調整: ひとり親(+50) + 保育士(+50) + 地域型卒園(+100) = +200
      // 合計: 30 + 30 + 200 = 260点

      final family = FamilyProfile(
        father: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        ),
        mother: const ParentProfile(
          workStatus: WorkStatus.employed,
          monthlyWorkHours: 160,
        ),
        isSingleParent: true,
        nurseryWorkerType: NurseryWorkerType.nurseryWorker,
        isGraduatingFromSmallNursery: true,
      );

      final result = rule.calcResult(family);

      expect(result.fatherBase, 30);
      expect(result.motherBase, 30);
      expect(result.adjustScore, 200);
      expect(result.total, 260);
    });

    test('減点ケース: 両親求職中 + 育休延長許容 + 滞納あり', () {
      // 父: 求職中 → 9点
      // 母: 求職中 → 9点
      // 調整: 育休延長許容(-500) + 滞納(-20) = -520
      // 合計: 9 + 9 + (-520) = -502点

      final family = FamilyProfile(
        father: const ParentProfile(
          workStatus: WorkStatus.jobSeeking,
        ),
        mother: const ParentProfile(
          workStatus: WorkStatus.jobSeeking,
        ),
        acceptsLeaveExtension: true,
        hasUnpaidFees: true,
      );

      final result = rule.calcResult(family);

      expect(result.fatherBase, 9);
      expect(result.motherBase, 9);
      expect(result.adjustScore, -520);
      expect(result.total, -502);
    });
  });
}
