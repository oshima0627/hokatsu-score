import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';

/// 世帯プロファイル（調整指数の入力項目）
class FamilyProfileNotifier extends Notifier<FamilyProfile> {
  @override
  FamilyProfile build() => FamilyProfile.initial();

  void updateSingleParent(bool value) {
    state = state.copyWith(isSingleParent: value);
  }

  void updatePseudoSingleParent(bool value) {
    state = state.copyWith(isPseudoSingleParent: value);
  }

  void updateYoungParent(bool value) {
    state = state.copyWith(isYoungParent: value);
  }

  void updateOnWelfare(bool value) {
    state = state.copyWith(isOnWelfare: value);
  }

  void updateNurseryWorkerType(NurseryWorkerType type) {
    state = state.copyWith(nurseryWorkerType: type);
  }

  void updateReturningFromLeave(bool value) {
    state = state.copyWith(returningFromLeave: value);
  }

  void updateHasDisabilityAndWorks(bool value) {
    state = state.copyWith(hasDisabilityAndWorks: value);
  }

  void updateTransferredAway(bool value) {
    state = state.copyWith(isTransferredAway: value);
  }

  void updateUsingNinkagai(bool value) {
    state = state.copyWith(isUsingNinkagai: value);
  }

  void updateSiblingAtFirstChoiceNursery(bool value) {
    state = state.copyWith(siblingAtFirstChoiceNursery: value);
  }

  void updateTwoSiblingsApplyingSameNursery(bool value) {
    state = state.copyWith(twoSiblingsApplyingSameNursery: value);
  }

  void updateSiblingHasDisability(bool value) {
    state = state.copyWith(siblingHasDisability: value);
  }

  void updateGraduatingFromSmallNursery(bool value) {
    state = state.copyWith(isGraduatingFromSmallNursery: value);
  }

  void updateGrandparentCanCare(bool value) {
    state = state.copyWith(grandparentCanCare: value);
  }

  void updateAcceptsLeaveExtension(bool value) {
    state = state.copyWith(acceptsLeaveExtension: value);
  }

  void updateUnpaidFees(bool value) {
    state = state.copyWith(hasUnpaidFees: value);
  }

  /// 父母プロファイルを反映した FamilyProfile を返す
  FamilyProfile withParents(ParentProfile father, ParentProfile mother) {
    return state.copyWith(father: father, mother: mother);
  }

  void reset() {
    state = FamilyProfile.initial();
  }
}

final familyProfileProvider =
    NotifierProvider<FamilyProfileNotifier, FamilyProfile>(
  FamilyProfileNotifier.new,
);
