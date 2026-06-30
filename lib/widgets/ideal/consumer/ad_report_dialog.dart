import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/ad_report_repository.dart';

const adReportReasons = [
  '虚偽・誤解を招く内容',
  '不適切な表現',
  'スパム・繰り返し投稿',
  'その他',
];

Future<void> showAdReportDialog(
  BuildContext context,
  WidgetRef ref, {
  required String adId,
}) async {
  String? selected = adReportReasons.first;
  final otherController = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('この広告を通報'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('通報理由を選択してください（mock）'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selected,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: adReportReasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (value) => setState(() => selected = value),
            ),
            if (selected == 'その他') ...[
              const SizedBox(height: 12),
              TextField(
                controller: otherController,
                decoration: const InputDecoration(
                  labelText: '詳細',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('通報する'),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final reason = selected == 'その他'
      ? otherController.text.trim().isEmpty
          ? 'その他'
          : otherController.text.trim()
      : selected!;

  ref.read(adReportRepositoryProvider.notifier).reportAd(
        adId: adId,
        reason: reason,
      );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通報を受け付けました。運営が確認します。')),
    );
  }
}
