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

  NotifierProvider<dynamic, ParentProfile> get _provider =>
      widget.isFather ? fatherProfileProvider : motherProfileProvider;

  String get _title => widget.isFather ? '父の情報' : '母の情報';

  @override
  void initState() {
    super.initState();
    // 既存値があれば反映
    final current = ref.read(_provider);
    if (current.monthlyWorkHours > 0) {
      _hoursController.text = current.monthlyWorkHours.toString();
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  dynamic get _notifier => widget.isFather
      ? ref.read(fatherProfileProvider.notifier)
      : ref.read(motherProfileProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(_provider);
    final showHoursField = _needsHoursInput(profile.workStatus);

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 就労状況
          _SectionLabel('就労状況'),
          DropdownButtonFormField<WorkStatus>(
            value: profile.workStatus,
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
              if (value != null) _notifier.updateWorkStatus(value);
            },
          ),

          // 月の就労時間（条件付き表示）
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
                _notifier.updateMonthlyWorkHours(hours);
              },
            ),
          ],

          const SizedBox(height: 24),

          // 障害の有無・等級
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
              if (value != null) _notifier.updateDisabilityGrade(value);
            },
          ),

          const SizedBox(height: 24),

          // 介護の状況
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
              if (value != null) _notifier.updateCareLevel(value);
            },
          ),

          const SizedBox(height: 24),

          // 育休対象児との関係
          SwitchListTile(
            title: const Text('育休給付の対象児である'),
            value: profile.isLeaveTarget,
            onChanged: (value) => _notifier.updateIsLeaveTarget(value),
          ),

          const SizedBox(height: 32),

          // 次へボタン
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
