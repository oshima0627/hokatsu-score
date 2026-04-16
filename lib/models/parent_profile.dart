import 'care_level.dart';
import 'disability_grade.dart';
import 'work_status.dart';

/// 保護者（父または母）の個人プロファイル
class ParentProfile {
  const ParentProfile({
    this.workStatus = WorkStatus.notSpecified,
    this.monthlyWorkHours = 0,
    this.disabilityGrade = DisabilityGrade.none,
    this.careLevel = CareLevel.none,
    this.isLeaveTarget = false,
  });

  /// 初期状態
  const ParentProfile.initial()
      : workStatus = WorkStatus.notSpecified,
        monthlyWorkHours = 0,
        disabilityGrade = DisabilityGrade.none,
        careLevel = CareLevel.none,
        isLeaveTarget = false;

  /// 就労状況
  final WorkStatus workStatus;

  /// 月の就労時間（0〜999）
  final int monthlyWorkHours;

  /// 障害等級
  final DisabilityGrade disabilityGrade;

  /// 介護の要介護・要支援度
  final CareLevel careLevel;

  /// 育休対象児との関係（育休給付対象か）
  final bool isLeaveTarget;

  ParentProfile copyWith({
    WorkStatus? workStatus,
    int? monthlyWorkHours,
    DisabilityGrade? disabilityGrade,
    CareLevel? careLevel,
    bool? isLeaveTarget,
  }) {
    return ParentProfile(
      workStatus: workStatus ?? this.workStatus,
      monthlyWorkHours: monthlyWorkHours ?? this.monthlyWorkHours,
      disabilityGrade: disabilityGrade ?? this.disabilityGrade,
      careLevel: careLevel ?? this.careLevel,
      isLeaveTarget: isLeaveTarget ?? this.isLeaveTarget,
    );
  }
}
