import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/score_provider.dart';

/// 結果表示画面
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(scoreResultProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算結果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '結果をシェア',
            onPressed: () => _share(result.municipalityName, result.fiscalYear,
                result.fatherBase, result.motherBase, result.adjustScore,
                result.total),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 自治体・年度
            Text(
              '${result.municipalityName}（${result.fiscalYear}基準）',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            // 合計スコア（大きく表示）
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Text('合計指数', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(
                      '${result.total}点',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 内訳
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ScoreRow(
                      label: '父の基本指数',
                      score: result.fatherBase,
                    ),
                    const Divider(),
                    _ScoreRow(
                      label: '母の基本指数',
                      score: result.motherBase,
                    ),
                    const Divider(),
                    _ScoreRow(
                      label: '調整指数',
                      score: result.adjustScore,
                      showSign: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // シェアボタン
            OutlinedButton.icon(
              onPressed: () => _share(
                  result.municipalityName,
                  result.fiscalYear,
                  result.fatherBase,
                  result.motherBase,
                  result.adjustScore,
                  result.total),
              icon: const Icon(Icons.share),
              label: const Text('結果をシェアする'),
            ),

            const SizedBox(height: 24),

            // 免責文言
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '※本結果はあくまで目安です。実際の選考結果を保証するものではありません。',
                style: theme.textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 16),

            // ホームに戻る
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    );
  }

  void _share(
    String municipalityName,
    String fiscalYear,
    int fatherBase,
    int motherBase,
    int adjustScore,
    int total,
  ) {
    final text = '''
【保活スコア計算結果】
自治体：$municipalityName（${fiscalYear}基準）
合計指数：${total}点
\u3000父の基本指数：${fatherBase}点
\u3000母の基本指数：${motherBase}点
\u3000調整指数：${adjustScore}点

※本結果はあくまで目安です。実際の選考結果を保証するものではありません。
保活スコア計算アプリ'''
        .trim();

    SharePlus.instance.share(ShareParams(text: text));
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.score,
    this.showSign = false,
  });

  final String label;
  final int score;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final scoreText =
        showSign && score >= 0 ? '+$score点' : '$score点';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            scoreText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
