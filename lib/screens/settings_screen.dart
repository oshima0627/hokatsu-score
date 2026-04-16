import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/family_provider.dart';
import '../providers/parent_provider.dart';

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
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: プライバシーポリシーURLを開く
            },
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
            onPressed: () {
              ref.read(fatherProfileProvider.notifier).reset();
              ref.read(motherProfileProvider.notifier).reset();
              ref.read(familyProfileProvider.notifier).reset();
              // TODO: flutter_secure_storage のデータも削除
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データを削除しました')),
              );
            },
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}
