import 'nursery_worker_type.dart';
import 'parent_profile.dart';

/// 世帯プロファイル（調整指数の入力項目）
class FamilyProfile {
  const FamilyProfile({
    required this.father,
    required this.mother,
    this.isSingleParent = false,
    this.isPseudoSingleParent = false,
    this.isYoungParent = false,
    this.isOnWelfare = false,
    this.nurseryWorkerType = NurseryWorkerType.none,
    this.returningFromLeave = false,
    this.hasDisabilityAndWorks = false,
    this.isTransferredAway = false,
    this.isUsingNinkagai = false,
    this.siblingAtFirstChoiceNursery = false,
    this.twoSiblingsApplyingSameNursery = false,
    this.siblingHasDisability = false,
    this.isGraduatingFromSmallNursery = false,
    this.grandparentCanCare = false,
    this.acceptsLeaveExtension = false,
    this.hasUnpaidFees = false,
  });

  /// 初期状態
  const FamilyProfile.initial()
      : father = const ParentProfile.initial(),
        mother = const ParentProfile.initial(),
        isSingleParent = false,
        isPseudoSingleParent = false,
        isYoungParent = false,
        isOnWelfare = false,
        nurseryWorkerType = NurseryWorkerType.none,
        returningFromLeave = false,
        hasDisabilityAndWorks = false,
        isTransferredAway = false,
        isUsingNinkagai = false,
        siblingAtFirstChoiceNursery = false,
        twoSiblingsApplyingSameNursery = false,
        siblingHasDisability = false,
        isGraduatingFromSmallNursery = false,
        grandparentCanCare = false,
        acceptsLeaveExtension = false,
        hasUnpaidFees = false;

  /// 父の保護者プロファイル
  final ParentProfile father;

  /// 母の保護者プロファイル
  final ParentProfile mother;

  /// ひとり親世帯
  final bool isSingleParent;

  /// ひとり親みなし（isSingleParentと排他的、高い方を採用）
  final bool isPseudoSingleParent;

  /// 18歳以下での出産
  final bool isYoungParent;

  /// 生活保護受給中
  final bool isOnWelfare;

  /// 保育士・子育て支援員区分（排他的enum）
  final NurseryWorkerType nurseryWorkerType;

  /// 育児休業から復帰予定
  final bool returningFromLeave;

  /// 障害者手帳保持かつ就労中
  final bool hasDisabilityAndWorks;

  /// 単身赴任
  final bool isTransferredAway;

  /// 認可外保育施設を現在利用中
  final bool isUsingNinkagai;

  /// きょうだいが第1希望園に在園中
  final bool siblingAtFirstChoiceNursery;

  /// きょうだい2名同時同園申込
  final bool twoSiblingsApplyingSameNursery;

  /// きょうだいに障害児あり
  final bool siblingHasDisability;

  /// 地域型保育園卒園児
  final bool isGraduatingFromSmallNursery;

  /// 65歳未満の近居祖父母が保育可能（減点）
  final bool grandparentCanCare;

  /// 希望園入れない場合に育休延長許容（大幅減点）
  final bool acceptsLeaveExtension;

  /// 保育料の滞納あり（減点）
  final bool hasUnpaidFees;

  /// JSON シリアライズ（父母プロファイルは含まない）
  Map<String, dynamic> toJson() => {
        'isSingleParent': isSingleParent,
        'isPseudoSingleParent': isPseudoSingleParent,
        'isYoungParent': isYoungParent,
        'isOnWelfare': isOnWelfare,
        'nurseryWorkerType': nurseryWorkerType.name,
        'returningFromLeave': returningFromLeave,
        'hasDisabilityAndWorks': hasDisabilityAndWorks,
        'isTransferredAway': isTransferredAway,
        'isUsingNinkagai': isUsingNinkagai,
        'siblingAtFirstChoiceNursery': siblingAtFirstChoiceNursery,
        'twoSiblingsApplyingSameNursery': twoSiblingsApplyingSameNursery,
        'siblingHasDisability': siblingHasDisability,
        'isGraduatingFromSmallNursery': isGraduatingFromSmallNursery,
        'grandparentCanCare': grandparentCanCare,
        'acceptsLeaveExtension': acceptsLeaveExtension,
        'hasUnpaidFees': hasUnpaidFees,
      };

  /// JSON デシリアライズ（父母は別途復元してcopyWithで差し込む）
  factory FamilyProfile.fromJson(Map<String, dynamic> json) {
    return FamilyProfile(
      father: const ParentProfile.initial(),
      mother: const ParentProfile.initial(),
      isSingleParent: json['isSingleParent'] as bool? ?? false,
      isPseudoSingleParent: json['isPseudoSingleParent'] as bool? ?? false,
      isYoungParent: json['isYoungParent'] as bool? ?? false,
      isOnWelfare: json['isOnWelfare'] as bool? ?? false,
      nurseryWorkerType: NurseryWorkerType.values.byName(
        json['nurseryWorkerType'] as String? ?? NurseryWorkerType.none.name,
      ),
      returningFromLeave: json['returningFromLeave'] as bool? ?? false,
      hasDisabilityAndWorks: json['hasDisabilityAndWorks'] as bool? ?? false,
      isTransferredAway: json['isTransferredAway'] as bool? ?? false,
      isUsingNinkagai: json['isUsingNinkagai'] as bool? ?? false,
      siblingAtFirstChoiceNursery:
          json['siblingAtFirstChoiceNursery'] as bool? ?? false,
      twoSiblingsApplyingSameNursery:
          json['twoSiblingsApplyingSameNursery'] as bool? ?? false,
      siblingHasDisability: json['siblingHasDisability'] as bool? ?? false,
      isGraduatingFromSmallNursery:
          json['isGraduatingFromSmallNursery'] as bool? ?? false,
      grandparentCanCare: json['grandparentCanCare'] as bool? ?? false,
      acceptsLeaveExtension:
          json['acceptsLeaveExtension'] as bool? ?? false,
      hasUnpaidFees: json['hasUnpaidFees'] as bool? ?? false,
    );
  }

  FamilyProfile copyWith({
    ParentProfile? father,
    ParentProfile? mother,
    bool? isSingleParent,
    bool? isPseudoSingleParent,
    bool? isYoungParent,
    bool? isOnWelfare,
    NurseryWorkerType? nurseryWorkerType,
    bool? returningFromLeave,
    bool? hasDisabilityAndWorks,
    bool? isTransferredAway,
    bool? isUsingNinkagai,
    bool? siblingAtFirstChoiceNursery,
    bool? twoSiblingsApplyingSameNursery,
    bool? siblingHasDisability,
    bool? isGraduatingFromSmallNursery,
    bool? grandparentCanCare,
    bool? acceptsLeaveExtension,
    bool? hasUnpaidFees,
  }) {
    return FamilyProfile(
      father: father ?? this.father,
      mother: mother ?? this.mother,
      isSingleParent: isSingleParent ?? this.isSingleParent,
      isPseudoSingleParent:
          isPseudoSingleParent ?? this.isPseudoSingleParent,
      isYoungParent: isYoungParent ?? this.isYoungParent,
      isOnWelfare: isOnWelfare ?? this.isOnWelfare,
      nurseryWorkerType: nurseryWorkerType ?? this.nurseryWorkerType,
      returningFromLeave: returningFromLeave ?? this.returningFromLeave,
      hasDisabilityAndWorks:
          hasDisabilityAndWorks ?? this.hasDisabilityAndWorks,
      isTransferredAway: isTransferredAway ?? this.isTransferredAway,
      isUsingNinkagai: isUsingNinkagai ?? this.isUsingNinkagai,
      siblingAtFirstChoiceNursery:
          siblingAtFirstChoiceNursery ?? this.siblingAtFirstChoiceNursery,
      twoSiblingsApplyingSameNursery:
          twoSiblingsApplyingSameNursery ??
              this.twoSiblingsApplyingSameNursery,
      siblingHasDisability:
          siblingHasDisability ?? this.siblingHasDisability,
      isGraduatingFromSmallNursery:
          isGraduatingFromSmallNursery ?? this.isGraduatingFromSmallNursery,
      grandparentCanCare: grandparentCanCare ?? this.grandparentCanCare,
      acceptsLeaveExtension:
          acceptsLeaveExtension ?? this.acceptsLeaveExtension,
      hasUnpaidFees: hasUnpaidFees ?? this.hasUnpaidFees,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyProfile &&
          runtimeType == other.runtimeType &&
          father == other.father &&
          mother == other.mother &&
          isSingleParent == other.isSingleParent &&
          isPseudoSingleParent == other.isPseudoSingleParent &&
          isYoungParent == other.isYoungParent &&
          isOnWelfare == other.isOnWelfare &&
          nurseryWorkerType == other.nurseryWorkerType &&
          returningFromLeave == other.returningFromLeave &&
          hasDisabilityAndWorks == other.hasDisabilityAndWorks &&
          isTransferredAway == other.isTransferredAway &&
          isUsingNinkagai == other.isUsingNinkagai &&
          siblingAtFirstChoiceNursery == other.siblingAtFirstChoiceNursery &&
          twoSiblingsApplyingSameNursery ==
              other.twoSiblingsApplyingSameNursery &&
          siblingHasDisability == other.siblingHasDisability &&
          isGraduatingFromSmallNursery ==
              other.isGraduatingFromSmallNursery &&
          grandparentCanCare == other.grandparentCanCare &&
          acceptsLeaveExtension == other.acceptsLeaveExtension &&
          hasUnpaidFees == other.hasUnpaidFees;

  @override
  int get hashCode => Object.hash(
        father,
        mother,
        isSingleParent,
        isPseudoSingleParent,
        isYoungParent,
        isOnWelfare,
        nurseryWorkerType,
        returningFromLeave,
        hasDisabilityAndWorks,
        isTransferredAway,
        isUsingNinkagai,
        siblingAtFirstChoiceNursery,
        twoSiblingsApplyingSameNursery,
        siblingHasDisability,
        isGraduatingFromSmallNursery,
        grandparentCanCare,
        acceptsLeaveExtension,
        hasUnpaidFees,
      );
}
