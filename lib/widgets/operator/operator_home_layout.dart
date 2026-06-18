import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/operator_stats_provider.dart';
import '../layout/browse_home_layout.dart';
import 'past_performance_panel.dart';
import 'recommended_carousel.dart';

/// オペレーター（配信/投稿）向けホームレイアウト。
/// 設計原則は [ScreenRoleConfig]（screen_roles.dart）を参照。
class OperatorHomeLayout extends ConsumerWidget {
  const OperatorHomeLayout({
    super.key,
    this.showRecommended = false,
    this.showPerformancePanel = true,
    this.showCategorySidebar = true,
    this.showPrefectureFilter = false,
    required this.statsProvider,
    required this.buildMain,
  });

  final bool showRecommended;
  final bool showPerformancePanel;
  final bool showCategorySidebar;
  final bool showPrefectureFilter;
  final ProviderListenable<PastPerformanceStats> statsProvider;
  final Widget Function(double mainContentWidth) buildMain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrowseHomeLayout(
      featured: showRecommended ? const RecommendedCarousel() : null,
      showCategorySidebar: showCategorySidebar,
      showPrefectureFilter: showPrefectureFilter,
      buildMain: buildMain,
      trailingPanel: showPerformancePanel
          ? PastPerformancePanel(statsProvider: statsProvider)
          : null,
      compactTrailingPanel: showPerformancePanel
          ? PastPerformancePanel(
              statsProvider: statsProvider,
              compact: true,
            )
          : null,
    );
  }
}
