import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nursery_worker_type.dart';
import '../providers/family_provider.dart';
import 'result_screen.dart';

/// 世帯状況入力画面（調整指数）
class FamilyInputScreen extends ConsumerWidget {
  const FamilyInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProfileProvider);
    final notifier = ref.read(familyProfileProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('世帯状況')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 加点項目 ─────────────────────────
          _SectionHeader('加点項目'),

          SwitchListTile(
            title: const Text('ひとり親世帯'),
            subtitle: const Text('+50点'),
            value: family.isSingleParent,
            onChanged: (v) => notifier.updateSingleParent(v),
          ),
          SwitchListTile(
            title: const Text('ひとり親みなし'),
            subtitle: const Text('+35点（ひとり親世帯と排他・高い方を採用）'),
            value: family.isPseudoSingleParent,
            onChanged: (v) => notifier.updatePseudoSingleParent(v),
          ),
          SwitchListTile(
            title: const Text('18歳以下での出産'),
            subtitle: const Text('+15点'),
            value: family.isYoungParent,
            onChanged: (v) => notifier.updateYoungParent(v),
          ),
          SwitchListTile(
            title: const Text('生活保護受給中'),
            subtitle: const Text('+3点'),
            value: family.isOnWelfare,
            onChanged: (v) => notifier.updateOnWelfare(v),
          ),

          const SizedBox(height: 8),

          // 保育士・支援員
          ListTile(
            title: const Text('市内認可保育所での就労'),
            subtitle: DropdownButtonFormField<NurseryWorkerType>(
              value: family.nurseryWorkerType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: NurseryWorkerType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_nurseryWorkerLabel(t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) notifier.updateNurseryWorkerType(v);
              },
            ),
          ),

          SwitchListTile(
            title: const Text('育児休業から復帰予定'),
            subtitle: const Text('+9点'),
            value: family.returningFromLeave,
            onChanged: (v) => notifier.updateReturningFromLeave(v),
          ),
          SwitchListTile(
            title: const Text('障害者手帳保持かつ就労中'),
            subtitle: const Text('+5点'),
            value: family.hasDisabilityAndWorks,
            onChanged: (v) => notifier.updateHasDisabilityAndWorks(v),
          ),
          SwitchListTile(
            title: const Text('単身赴任'),
            subtitle: const Text('+5点'),
            value: family.isTransferredAway,
            onChanged: (v) => notifier.updateTransferredAway(v),
          ),
          SwitchListTile(
            title: const Text('認可外保育施設を現在利用中'),
            subtitle: const Text('+11点'),
            value: family.isUsingNinkagai,
            onChanged: (v) => notifier.updateUsingNinkagai(v),
          ),
          SwitchListTile(
            title: const Text('きょうだいが第1希望園に在園中'),
            subtitle: const Text('+7点'),
            value: family.siblingAtFirstChoiceNursery,
            onChanged: (v) => notifier.updateSiblingAtFirstChoiceNursery(v),
          ),
          SwitchListTile(
            title: const Text('きょうだい2名同時同園申込'),
            subtitle: const Text('+6点'),
            value: family.twoSiblingsApplyingSameNursery,
            onChanged: (v) =>
                notifier.updateTwoSiblingsApplyingSameNursery(v),
          ),
          SwitchListTile(
            title: const Text('きょうだいに障害児あり'),
            subtitle: const Text('+5点'),
            value: family.siblingHasDisability,
            onChanged: (v) => notifier.updateSiblingHasDisability(v),
          ),
          SwitchListTile(
            title: const Text('地域型保育園卒園児'),
            subtitle: const Text('+100点'),
            value: family.isGraduatingFromSmallNursery,
            onChanged: (v) => notifier.updateGraduatingFromSmallNursery(v),
          ),

          const Divider(height: 32),

          // ── 減点項目 ─────────────────────────
          _SectionHeader('減点項目', isNegative: true),

          SwitchListTile(
            title: const Text('65歳未満の近居祖父母が保育可能'),
            subtitle: const Text('-3点'),
            value: family.grandparentCanCare,
            onChanged: (v) => notifier.updateGrandparentCanCare(v),
          ),
          SwitchListTile(
            title: const Text('保育料の滞納あり'),
            subtitle: const Text('-20点'),
            value: family.hasUnpaidFees,
            onChanged: (v) => notifier.updateUnpaidFees(v),
          ),
          SwitchListTile(
            title: const Text('希望園に入れない場合、育休延長を許容する'),
            subtitle: Text(
              '-500点（事実上の辞退扱い）',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            value: family.acceptsLeaveExtension,
            onChanged: (v) => notifier.updateAcceptsLeaveExtension(v),
          ),

          const SizedBox(height: 32),

          // 計算ボタン
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResultScreen()),
            ),
            icon: const Icon(Icons.calculate),
            label: const Text('スコアを計算する'),
          ),
        ],
      ),
    );
  }

  String _nurseryWorkerLabel(NurseryWorkerType type) {
    switch (type) {
      case NurseryWorkerType.none:
        return '該当なし';
      case NurseryWorkerType.nurseryWorker:
        return '保育士（+50点）';
      case NurseryWorkerType.childcareSupporter:
        return '子育て支援員（+20点）';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.isNegative = false});
  final String text;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isNegative
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
