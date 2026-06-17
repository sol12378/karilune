import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.adCount,
    required this.distributorCount,
    required this.viewCount,
  });

  final int adCount;
  final int distributorCount;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: '広告数',
              value: '$adCount',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '配信者数',
              value: '$distributorCount',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '参照数',
              value: '$viewCount',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
