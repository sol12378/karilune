import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ad.dart';
import 'ad_list_provider.dart';

class PastPerformanceStats {
  const PastPerformanceStats({
    required this.adCount,
    required this.distributorCount,
    required this.viewCount,
    required this.viewRate,
  });

  final int adCount;
  final int distributorCount;
  final int viewCount;
  final double viewRate;
}

PastPerformanceStats _aggregateStats(List<Ad> ads) {
  if (ads.isEmpty) {
    return const PastPerformanceStats(
      adCount: 0,
      distributorCount: 0,
      viewCount: 0,
      viewRate: 0,
    );
  }

  final distributorCount =
      ads.fold<int>(0, (sum, ad) => sum + ad.distributorCount);
  final viewCount = ads.fold<int>(0, (sum, ad) => sum + ad.viewCount);
  final totalDays =
      ads.fold<int>(0, (sum, ad) => sum + ad.distributionDays);
  final viewRate = totalDays > 0 ? (viewCount / totalDays) * 100 : 0.0;

  return PastPerformanceStats(
    adCount: ads.length,
    distributorCount: distributorCount,
    viewCount: viewCount,
    viewRate: viewRate,
  );
}

/// 配信者向け: 過去に配信した広告の集計
final distributorPerformanceProvider = Provider<PastPerformanceStats>((ref) {
  final ads = ref
      .watch(adListProvider)
      .where((ad) => ad.wasDistributed)
      .toList();
  return _aggregateStats(ads);
});

/// 投稿者向け: 自社広告全体の集計
final advertiserPerformanceProvider = Provider<PastPerformanceStats>((ref) {
  final ads = ref.watch(advertiserAdsProvider);
  return _aggregateStats(ads);
});

/// 投稿者ダッシュボード用の統計（HTML stats-grid 相当）。
class AdvertiserDashboardStats {
  const AdvertiserDashboardStats({
    required this.activeAdCount,
    required this.distributorCount,
    required this.viewCount,
    required this.leadCount,
  });

  final int activeAdCount;
  final int distributorCount;
  final int viewCount;
  final int leadCount;
}

int mockLeadCountForAd(Ad ad) => (ad.viewCount * 0.05).round();

final advertiserDashboardStatsProvider = Provider<AdvertiserDashboardStats>((ref) {
  final split = ref.watch(advertiserAdsSplitProvider);
  final activeAds = split.active;
  return AdvertiserDashboardStats(
    activeAdCount: activeAds.length,
    distributorCount: activeAds.fold<int>(0, (s, ad) => s + ad.distributorCount),
    viewCount: activeAds.fold<int>(0, (s, ad) => s + ad.viewCount),
    leadCount: activeAds.fold<int>(0, (s, ad) => s + mockLeadCountForAd(ad)),
  );
});
