import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import '../storage/secure_storage.dart';

/// 父の保護者プロファイル
class FatherProfileNotifier extends Notifier<ParentProfile> {
  @override
  ParentProfile build() => const ParentProfile.initial();

  Future<void> loadFromStorage() async {
    state = await SecureStorage.loadFather();
  }

  void updateWorkStatus(WorkStatus status) {
    state = state.copyWith(workStatus: status);
    SecureStorage.saveFather(state);
  }

  void updateMonthlyWorkHours(int hours) {
    state = state.copyWith(monthlyWorkHours: hours);
    SecureStorage.saveFather(state);
  }

  void updateDisabilityGrade(DisabilityGrade grade) {
    state = state.copyWith(disabilityGrade: grade);
    SecureStorage.saveFather(state);
  }

  void updateCareLevel(CareLevel level) {
    state = state.copyWith(careLevel: level);
    SecureStorage.saveFather(state);
  }

  void updateIsLeaveTarget(bool value) {
    state = state.copyWith(isLeaveTarget: value);
    SecureStorage.saveFather(state);
  }

  void reset() {
    state = const ParentProfile.initial();
  }
}

final fatherProfileProvider =
    NotifierProvider<FatherProfileNotifier, ParentProfile>(
  FatherProfileNotifier.new,
);

/// 母の保護者プロファイル
class MotherProfileNotifier extends Notifier<ParentProfile> {
  @override
  ParentProfile build() => const ParentProfile.initial();

  Future<void> loadFromStorage() async {
    state = await SecureStorage.loadMother();
  }

  void updateWorkStatus(WorkStatus status) {
    state = state.copyWith(workStatus: status);
    SecureStorage.saveMother(state);
  }

  void updateMonthlyWorkHours(int hours) {
    state = state.copyWith(monthlyWorkHours: hours);
    SecureStorage.saveMother(state);
  }

  void updateDisabilityGrade(DisabilityGrade grade) {
    state = state.copyWith(disabilityGrade: grade);
    SecureStorage.saveMother(state);
  }

  void updateCareLevel(CareLevel level) {
    state = state.copyWith(careLevel: level);
    SecureStorage.saveMother(state);
  }

  void updateIsLeaveTarget(bool value) {
    state = state.copyWith(isLeaveTarget: value);
    SecureStorage.saveMother(state);
  }

  void reset() {
    state = const ParentProfile.initial();
  }
}

final motherProfileProvider =
    NotifierProvider<MotherProfileNotifier, ParentProfile>(
  MotherProfileNotifier.new,
);
