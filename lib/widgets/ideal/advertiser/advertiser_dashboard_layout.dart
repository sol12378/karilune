import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/operator_stats_provider.dart';
import 'stats_grid.dart';

/// 作成元ダッシュボード：統計 + 広告一覧。
class AdvertiserDashboardLayout extends ConsumerWidget {
  const AdvertiserDashboardLayout({
    super.key,
    required this.buildAdsSection,
  });

  final Widget Function(double width) buildAdsSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(advertiserDashboardStatsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsGrid(stats: stats),
              const SizedBox(height: 8),
              buildAdsSection(width),
            ],
          ),
        );
      },
    );
  }
}
