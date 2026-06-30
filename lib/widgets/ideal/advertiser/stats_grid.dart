import 'package:flutter/material.dart';

import '../../../providers/operator_stats_provider.dart';
import '../../../theme/app_theme.dart';
import '../ideal_theme.dart';

/// 作成元ダッシュボード上部の統計4枚（HTML `.stats-grid` 相当）。
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final AdvertiserDashboardStats stats;

  String _formatCount(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}k'
          .replaceAll('.0k', 'k');
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.55,
          children: [
            _StatCard(
              label: '配信中の広告',
              value: '${stats.activeAdCount}',
              delta: '+1 今月',
              accentColor: AppColors.primary,
            ),
            _StatCard(
              label: '配信者数（合計）',
              value: '${stats.distributorCount}',
              delta: '12% 先月比',
              accentColor: AppColors.accent,
            ),
            _StatCard(
              label: '参照数（合計）',
              value: _formatCount(stats.viewCount),
              delta: '23% 先月比',
              accentColor: AppColors.primary,
            ),
            _StatCard(
              label: 'リード数',
              value: '${stats.leadCount}',
              delta: '8% 先月比',
              accentColor: AppColors.distributing,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String delta;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: IdealShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IdealRadii.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '↑ $delta',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.distributing,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
