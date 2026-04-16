import 'package:flutter/material.dart';

/// セクション見出しウィジェット（入力画面共通）
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.isNegative = false});

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
