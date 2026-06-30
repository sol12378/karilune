import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/operator_stats_provider.dart';
import '../common/section_header.dart';
import '../featured/featured_ads_carousel.dart';
import '../distributor_sort_chips.dart';
import '../layout/browse_home_layout.dart';
import 'past_advertiser_pickup_carousel.dart';
import 'past_performance_panel.dart';
import 'distributor_today_tasks.dart';

/// 配信者向けホーム（配信可否の判断画面）。
///
/// - 注目カルーセル
/// - かつて配信した制作元のピックアップ
/// - カテゴリ + 配信候補グリッド
class DistributorBrowseLayout extends ConsumerWidget {
  const DistributorBrowseLayout({
    super.key,
    required this.statsProvider,
    required this.buildMain,
    this.onPickupDistribute,
  });

  final ProviderListenable<PastPerformanceStats> statsProvider;
  final Widget Function(double mainContentWidth) buildMain;
  final void Function(String adId)? onPickupDistribute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrowseHomeLayout(
      featured: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DistributorTodayTasks(),
          FeaturedAdsCarousel(linkFrom: 'distributor'),
        ],
      ),
      pickup: PastAdvertiserPickupCarousel(
        onToggleDistribute: onPickupDistribute == null
            ? null
            : (ad) => onPickupDistribute!(ad.id),
      ),
      showCategorySidebar: true,
      showPrefectureFilter: true,
      mainHeader: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: '配信候補の広告',
            subtitle: 'カテゴリや並び替えで絞り込み、配信するか決められます',
          ),
          DistributorSortChips(),
        ],
      ),
      buildMain: buildMain,
      trailingPanel: PastPerformancePanel(statsProvider: statsProvider),
      compactTrailingPanel: PastPerformancePanel(
        statsProvider: statsProvider,
        compact: true,
      ),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Text(
          '※ 配信に協力頂いた会社を広告主とマッチング。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ),
    );
  }
}
