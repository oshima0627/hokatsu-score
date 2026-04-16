import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/family_provider.dart';
import '../providers/parent_provider.dart';
import '../storage/secure_storage.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // 保存データ削除
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('保存データを削除'),
            subtitle: const Text('入力した情報をすべて削除します'),
            onTap: () => _confirmDelete(context, ref),
          ),

          const Divider(),

          // プライバシーポリシー
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.chevron_right, size: 16),
            onTap: () => _showPrivacyPolicy(context),
          ),

          // ライセンス
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('ライセンス情報'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'ホカツスコア',
              applicationVersion: '1.0.0',
            ),
          ),

          const Divider(),

          // アプリ情報
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('バージョン'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  static const _privacyPolicyUrl =
      'https://oshima0627.github.io/android-hokatsu-score/privacy-policy/';

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'ホカツスコア',
        applicationVersion: '1.0.0',
        children: [
          const Text('プライバシーポリシーは以下のURLでご確認いただけます。'),
          const SizedBox(height: 8),
          SelectableText(
            _privacyPolicyUrl,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ削除'),
        content: const Text('入力した情報をすべて削除しますか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              ref.read(fatherProfileProvider.notifier).reset();
              ref.read(motherProfileProvider.notifier).reset();
              ref.read(familyProfileProvider.notifier).reset();
              await SecureStorage.deleteAll();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('データを削除しました')),
                );
              }
            },
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}
