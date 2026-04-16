import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care_level.dart';
import '../models/disability_grade.dart';
import '../models/parent_profile.dart';
import '../models/work_status.dart';
import '../providers/parent_provider.dart';
import 'family_input_screen.dart';

/// 保護者情報入力画面（父・母で共通利用）
class ParentInputScreen extends ConsumerStatefulWidget {
  const ParentInputScreen({super.key, required this.isFather});

  final bool isFather;

  @override
  ConsumerState<ParentInputScreen> createState() => _ParentInputScreenState();
}

class _ParentInputScreenState extends ConsumerState<ParentInputScreen> {
  final _hoursController = TextEditingController();

  String get _title => widget.isFather ? '父の情報' : '母の情報';

  ParentProfile _watchProfile() {
    return widget.isFather
        ? ref.watch(fatherProfileProvider)
        : ref.watch(motherProfileProvider);
  }

  void _updateWorkStatus(WorkStatus value) {
    if (widget.isFather) {
      ref.read(fatherProfileProvider.notifier).updateWorkStatus(value);
    } else {
      ref.read(motherProfileProvider.notifier).updateWorkStatus(value);
    }
  }

  void _updateMonthlyWorkHours(int hours) {
    if (widget.isFather) {
      ref.read(fatherProfileProvider.notifier).updateMonthlyWorkHours(hours);
    } else {
      ref.read(motherProfileProvider.notifier).updateMonthlyWorkHours(hours);
    }
  }

  void _updateDisabilityGrade(DisabilityGrade grade) {
    if (widget.isFather) {
      ref.read(fatherProfileProvider.notifier).updateDisabilityGrade(grade);
    } else {
      ref.read(motherProfileProvider.notifier).updateDisabilityGrade(grade);
    }
  }

  void _updateCareLevel(CareLevel level) {
    if (widget.isFather) {
      ref.read(fatherProfileProvider.notifier).updateCareLevel(level);
    } else {
      ref.read(motherProfileProvider.notifier).updateCareLevel(level);
    }
  }

  void _updateIsLeaveTarget(bool value) {
    if (widget.isFather) {
      ref.read(fatherProfileProvider.notifier).updateIsLeaveTarget(value);
    } else {
      ref.read(motherProfileProvider.notifier).updateIsLeaveTarget(value);
    }
  }

  @override
  void initState() {
    super.initState();
    final current = widget.isFather
        ? ref.read(fatherProfileProvider)
        : ref.read(motherProfileProvider);
    if (current.monthlyWorkHours > 0) {
      _hoursController.text = current.monthlyWorkHours.toString();
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _watchProfile();
    final showHoursField = _needsHoursInput(profile.workStatus);
    final isNotSpecified = profile.workStatus == WorkStatus.notSpecified;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('就労状況'),
          DropdownButtonFormField<WorkStatus>(
            value: isNotSpecified ? null : profile.workStatus,
            hint: const Text('就労状況を選択してください'),
            decoration: const InputDecoration(
              labelText: '就労状況を選択',
              border: OutlineInputBorder(),
            ),
            items: WorkStatus.values
                .where((s) => s != WorkStatus.notSpecified)
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) _updateWorkStatus(value);
            },
          ),

          if (showHoursField) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursController,
              decoration: const InputDecoration(
                labelText: '月の就労時間（時間）',
                hintText: '例: 160',
                border: OutlineInputBorder(),
                suffixText: '時間/月',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (value) {
                final hours = int.tryParse(value) ?? 0;
                _updateMonthlyWorkHours(hours);
              },
            ),
          ],

          const SizedBox(height: 24),

          _SectionLabel('障害の有無・等級'),
          DropdownButtonFormField<DisabilityGrade>(
            value: profile.disabilityGrade,
            decoration: const InputDecoration(
              labelText: '障害等級を選択',
              border: OutlineInputBorder(),
            ),
            items: DisabilityGrade.values
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) _updateDisabilityGrade(value);
            },
          ),

          const SizedBox(height: 24),

          _SectionLabel('介護の状況'),
          DropdownButtonFormField<CareLevel>(
            value: profile.careLevel,
            decoration: const InputDecoration(
              labelText: '要介護・要支援度を選択',
              border: OutlineInputBorder(),
            ),
            items: CareLevel.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) _updateCareLevel(value);
            },
          ),

          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('育休給付の対象児である'),
            value: profile.isLeaveTarget,
            onChanged: (value) => _updateIsLeaveTarget(value),
          ),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _canProceed(profile) ? _onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text(widget.isFather ? '母の情報へ' : '世帯状況へ'),
          ),
        ],
      ),
    );
  }

  bool _needsHoursInput(WorkStatus status) {
    return status == WorkStatus.employed ||
        status == WorkStatus.selfEmployedNoProof ||
        status == WorkStatus.employedProspect ||
        status == WorkStatus.student;
  }

  bool _canProceed(ParentProfile profile) {
    return profile.workStatus != WorkStatus.notSpecified;
  }

  void _onNext() {
    if (widget.isFather) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ParentInputScreen(isFather: false),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FamilyInputScreen()),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
