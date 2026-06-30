import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';

/// 配信開始・停止の確認ダイアログを表示してから切り替える。
Future<void> confirmToggleDistributing(
  BuildContext context,
  WidgetRef ref,
  Ad ad,
) async {
  final isStop = ad.isDistributing;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isStop ? '配信停止の確認' : '配信開始の確認'),
      content: Text(
        isStop
            ? '「${ad.companyName}」の配信を停止しますか？'
            : '「${ad.companyName}」を配信しますか？',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(isStop ? '停止する' : '配信する'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    ref.read(adRepositoryProvider.notifier).toggleDistributing(ad.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStop
                ? '「${ad.companyName}」の配信を停止しました。会員フィードから非表示になります。'
                : '「${ad.companyName}」を配信しました。会員フィードに表示されます。',
          ),
        ),
      );
    }
  }
}
