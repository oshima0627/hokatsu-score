import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';

/// 父の保護者プロファイル
class FatherProfileNotifier extends Notifier<ParentProfile> {
  @override
  ParentProfile build() => const ParentProfile.initial();

  void updateWorkStatus(WorkStatus status) {
    state = state.copyWith(workStatus: status);
  }

  void updateMonthlyWorkHours(int hours) {
    state = state.copyWith(monthlyWorkHours: hours);
  }

  void updateDisabilityGrade(DisabilityGrade grade) {
    state = state.copyWith(disabilityGrade: grade);
  }

  void updateCareLevel(CareLevel level) {
    state = state.copyWith(careLevel: level);
  }

  void updateIsLeaveTarget(bool value) {
    state = state.copyWith(isLeaveTarget: value);
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

  void updateWorkStatus(WorkStatus status) {
    state = state.copyWith(workStatus: status);
  }

  void updateMonthlyWorkHours(int hours) {
    state = state.copyWith(monthlyWorkHours: hours);
  }

  void updateDisabilityGrade(DisabilityGrade grade) {
    state = state.copyWith(disabilityGrade: grade);
  }

  void updateCareLevel(CareLevel level) {
    state = state.copyWith(careLevel: level);
  }

  void updateIsLeaveTarget(bool value) {
    state = state.copyWith(isLeaveTarget: value);
  }

  void reset() {
    state = const ParentProfile.initial();
  }
}

final motherProfileProvider =
    NotifierProvider<MotherProfileNotifier, ParentProfile>(
  MotherProfileNotifier.new,
);
