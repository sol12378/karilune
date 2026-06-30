import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../ideal/ideal_theme.dart';

class AdminReviewQueue extends ConsumerWidget {
  const AdminReviewQueue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(advertiserAdsSplitProvider).pending;

    if (pending.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(IdealSpacing.lg),
          child: Text('審査待ちの広告はありません'),
        ),
      );
    }

    return Column(
      children: [
        for (final ad in pending)
          Padding(
            padding: const EdgeInsets.only(bottom: IdealSpacing.sm),
            child: _ReviewCard(ad: ad),
          ),
      ],
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.ad});

  final Ad ad;

  Future<String?> _askReason(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '理由（必須）',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, text);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(adRepositoryProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(IdealSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ad.companyName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: IdealSpacing.xs),
            Text(
              ad.catchCopy,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: IdealSpacing.sm),
            Wrap(
              spacing: IdealSpacing.sm,
              runSpacing: IdealSpacing.xs,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    repo.approveReview(ad.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${ad.companyName}」を承認しました')),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('承認'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final note = await _askReason(context, '却下理由');
                    if (note == null || !context.mounted) return;
                    repo.rejectReview(ad.id, note);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${ad.companyName}」を却下しました')),
                    );
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('却下'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final note = await _askReason(context, '差戻し理由');
                    if (note == null || !context.mounted) return;
                    repo.returnToDraft(ad.id, note);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「${ad.companyName}」を差戻ししました')),
                    );
                  },
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('差戻し'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
