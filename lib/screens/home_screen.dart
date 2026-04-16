import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/family_provider.dart';
import '../providers/municipality_provider.dart';
import '../providers/parent_provider.dart';
import '../scoring/municipality.dart';
import '../scoring/scoring_rule_factory.dart';
import 'parent_input_screen.dart';
import 'settings_screen.dart';

/// ホーム画面（自治体選択）
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMunicipalityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホカツスコア'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 免責文言
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '※計算結果はあくまで目安です。実際の選考結果を保証するものではありません。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // 自治体リスト
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: Municipality.values.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final municipality = Municipality.values[index];
                final isImplemented = _isImplemented(municipality);
                final isSelected = municipality == selected;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.location_city,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(municipality.displayName),
                  subtitle: isImplemented
                      ? Text(
                          ScoringRuleFactory.of(municipality).fiscalYear,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Text(
                          '準備中',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                  trailing:
                      isImplemented ? const Icon(Icons.chevron_right) : null,
                  enabled: isImplemented,
                  selected: isSelected,
                  onTap: isImplemented
                      ? () => _onMunicipalityTap(context, ref, municipality)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isImplemented(Municipality municipality) {
    try {
      ScoringRuleFactory.of(municipality);
      return true;
    } on UnimplementedError {
      return false;
    }
  }

  void _onMunicipalityTap(
    BuildContext context,
    WidgetRef ref,
    Municipality municipality,
  ) {
    ref.read(selectedMunicipalityProvider.notifier).select(municipality);

    // 入力状態をリセット
    ref.read(fatherProfileProvider.notifier).reset();
    ref.read(motherProfileProvider.notifier).reset();
    ref.read(familyProfileProvider.notifier).reset();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentInputScreen(isFather: true),
      ),
    );
  }
}
