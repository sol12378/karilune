import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/operator_stats_provider.dart';
import '../../theme/app_theme.dart';

class PastPerformancePanel extends ConsumerWidget {
  const PastPerformancePanel({
    super.key,
    required this.statsProvider,
    this.compact = false,
  });

  final ProviderListenable<PastPerformanceStats> statsProvider;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final rateFormat = NumberFormat('#,##0.0');

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '過去の実績効果',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        _StatItem(label: '広告数', value: '${stats.adCount}'),
        const SizedBox(height: 10),
        _StatItem(label: '配信者数', value: '${stats.distributorCount}'),
        const SizedBox(height: 10),
        _StatItem(label: '参照数', value: '${stats.viewCount}'),
        const SizedBox(height: 10),
        _StatItem(
          label: '参照数/配信日数',
          value: '${rateFormat.format(stats.viewRate)}%',
        ),
      ],
    );

    if (compact) {
      return Card(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: ExpansionTile(
          title: Text(
            '過去の実績効果',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: content,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}
