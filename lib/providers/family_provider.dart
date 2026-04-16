import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_profile.dart';
import '../models/nursery_worker_type.dart';
import '../models/parent_profile.dart';
import '../storage/secure_storage.dart';

/// 世帯プロファイル（調整指数の入力項目）
class FamilyProfileNotifier extends Notifier<FamilyProfile> {
  @override
  FamilyProfile build() => FamilyProfile.initial();

  Future<void> loadFromStorage() async {
    state = await SecureStorage.loadFamily();
  }

  void _save() => unawaited(SecureStorage.saveFamily(state));

  void updateSingleParent(bool value) {
    state = state.copyWith(isSingleParent: value);
    _save();
  }

  void updatePseudoSingleParent(bool value) {
    state = state.copyWith(isPseudoSingleParent: value);
    _save();
  }

  void updateYoungParent(bool value) {
    state = state.copyWith(isYoungParent: value);
    _save();
  }

  void updateOnWelfare(bool value) {
    state = state.copyWith(isOnWelfare: value);
    _save();
  }

  void updateNurseryWorkerType(NurseryWorkerType type) {
    state = state.copyWith(nurseryWorkerType: type);
    _save();
  }

  void updateReturningFromLeave(bool value) {
    state = state.copyWith(returningFromLeave: value);
    _save();
  }

  void updateHasDisabilityAndWorks(bool value) {
    state = state.copyWith(hasDisabilityAndWorks: value);
    _save();
  }

  void updateTransferredAway(bool value) {
    state = state.copyWith(isTransferredAway: value);
    _save();
  }

  void updateUsingNinkagai(bool value) {
    state = state.copyWith(isUsingNinkagai: value);
    _save();
  }

  void updateSiblingAtFirstChoiceNursery(bool value) {
    state = state.copyWith(siblingAtFirstChoiceNursery: value);
    _save();
  }

  void updateTwoSiblingsApplyingSameNursery(bool value) {
    state = state.copyWith(twoSiblingsApplyingSameNursery: value);
    _save();
  }

  void updateSiblingHasDisability(bool value) {
    state = state.copyWith(siblingHasDisability: value);
    _save();
  }

  void updateGraduatingFromSmallNursery(bool value) {
    state = state.copyWith(isGraduatingFromSmallNursery: value);
    _save();
  }

  void updateGrandparentCanCare(bool value) {
    state = state.copyWith(grandparentCanCare: value);
    _save();
  }

  void updateAcceptsLeaveExtension(bool value) {
    state = state.copyWith(acceptsLeaveExtension: value);
    _save();
  }

  void updateUnpaidFees(bool value) {
    state = state.copyWith(hasUnpaidFees: value);
    _save();
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
