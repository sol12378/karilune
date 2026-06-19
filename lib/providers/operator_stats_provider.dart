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
