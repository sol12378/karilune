import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_repository.dart';
import '../data/ad_report_repository.dart';
import '../data/audit_log_repository.dart';
import '../data/featured_placement_repository.dart';
import '../models/ad.dart';
import '../models/ad_publication_status.dart';
import '../models/featured_placement.dart';
import '../services/featured_carousel_resolver.dart';

enum SortOrder {
  newest,
  endingSoon,
  popular,
  recommended,
}

enum DistributorDistributionFilter {
  all,
  distributing,
  notDistributing,
}

/// 全広告リスト（Repository のエイリアス）
final adListProvider = Provider<List<Ad>>((ref) {
  return ref.watch(adRepositoryProvider);
});

/// ID 指定で単一広告を取得（詳細画面などで Repository 全体の watch を避ける）
final adByIdProvider = Provider.family<Ad?, String>((ref, adId) {
  final ads = ref.watch(adRepositoryProvider);
  for (final ad in ads) {
    if (ad.id == adId) {
      return ad;
    }
  }
  return null;
});

class AdvertiserAdsSplit {
  const AdvertiserAdsSplit({
    required this.all,
    required this.drafts,
    required this.pending,
    required this.active,
    required this.ended,
    required this.rejected,
  });

  final List<Ad> all;
  final List<Ad> drafts;
  final List<Ad> pending;
  final List<Ad> active;
  final List<Ad> ended;
  final List<Ad> rejected;
}

/// 投稿者向け広告を1回の走査で分割
final advertiserAdsSplitProvider = Provider<AdvertiserAdsSplit>((ref) {
  final all = ref
      .watch(adRepositoryProvider)
      .where((ad) => ad.isAdvertiserAd || ad.isOwnAd)
      .toList();
  final drafts = <Ad>[];
  final pending = <Ad>[];
  final active = <Ad>[];
  final ended = <Ad>[];
  final rejected = <Ad>[];
  for (final ad in all) {
    if (ad.isDraft) {
      drafts.add(ad);
    } else if (ad.isPendingReview) {
      pending.add(ad);
    } else if (ad.isRejected) {
      rejected.add(ad);
    } else if (ad.isEnded) {
      ended.add(ad);
    } else {
      active.add(ad);
    }
  }
  return AdvertiserAdsSplit(
    all: all,
    drafts: drafts,
    pending: pending,
    active: active,
    ended: ended,
    rejected: rejected,
  );
});

/// 投稿者向け広告（自社・管理対象）
final advertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).all;
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'すべて');

final selectedPrefectureProvider = StateProvider<String>((ref) => 'すべて');

final sortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.newest);

final distributorSortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.newest);

final distributorDistributionFilterProvider =
    StateProvider<DistributorDistributionFilter>(
  (ref) => DistributorDistributionFilter.all,
);

List<Ad> applyCategoryPrefectureFilter(
  List<Ad> ads,
  String category,
  String prefecture,
) {
  return ads.where((ad) {
    final categoryMatch = category == 'すべて' || ad.category == category;
    final prefectureMatch =
        prefecture == 'すべて' || ad.prefecture == prefecture;
    return categoryMatch && prefectureMatch;
  }).toList();
}

List<Ad> applySort(List<Ad> ads, SortOrder order) {
  final sorted = List<Ad>.from(ads);
  switch (order) {
    case SortOrder.newest:
      sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    case SortOrder.endingSoon:
      sorted.sort((a, b) => a.endDate.compareTo(b.endDate));
    case SortOrder.popular:
      sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    case SortOrder.recommended:
      sorted.sort((a, b) {
        if (a.hasSpotlightOption != b.hasSpotlightOption) {
          return a.hasSpotlightOption ? -1 : 1;
        }
        return b.startDate.compareTo(a.startDate);
      });
  }
  return sorted;
}

List<Ad> applyDistributorDistributionFilter(
  List<Ad> ads,
  DistributorDistributionFilter filter,
) {
  switch (filter) {
    case DistributorDistributionFilter.all:
      return ads;
    case DistributorDistributionFilter.distributing:
      return ads.where((ad) => ad.isDistributing).toList();
    case DistributorDistributionFilter.notDistributing:
      return ads.where((ad) => !ad.isDistributing).toList();
  }
}

List<Ad> publishedCatalogAds(List<Ad> ads) {
  return ads
      .where((ad) => ad.isVisibleToCatalog && !ad.isEnded)
      .toList();
}

/// カテゴリ・地域フィルタのみ適用（会員・配信者で共有）
final categoryPrefectureFilteredAdsProvider = Provider<List<Ad>>((ref) {
  final ads = ref.watch(adListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final prefecture = ref.watch(selectedPrefectureProvider);
  return applyCategoryPrefectureFilter(
    publishedCatalogAds(ads),
    category,
    prefecture,
  );
});

final filteredAdsProvider = categoryPrefectureFilteredAdsProvider;

final memberAdsProvider = Provider<List<Ad>>((ref) {
  final filtered = ref.watch(categoryPrefectureFilteredAdsProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  final active = filtered
      .where((ad) => ad.isDistributing && ad.isActive)
      .toList();

  return applySort(active, sortOrder);
});

class DistributorAdsSplit {
  const DistributorAdsSplit({
    required this.ownDistributing,
    required this.candidates,
    required this.all,
  });

  final List<Ad> ownDistributing;
  final List<Ad> candidates;
  final List<Ad> all;
}

final distributorAdsSplitProvider = Provider<DistributorAdsSplit>((ref) {
  final filtered = ref.watch(categoryPrefectureFilteredAdsProvider);
  final sortOrder = ref.watch(distributorSortOrderProvider);
  final distributionFilter = ref.watch(distributorDistributionFilterProvider);

  final filteredByDistribution =
      applyDistributorDistributionFilter(filtered, distributionFilter);
  final sorted = applySort(filteredByDistribution, sortOrder);

  final ownDistributing = sorted
      .where((ad) => ad.isOwnAd && ad.isDistributing && ad.isActive)
      .toList();
  final candidates = sorted
      .where((ad) => !(ad.isOwnAd && ad.isDistributing && ad.isActive))
      .toList();

  return DistributorAdsSplit(
    ownDistributing: ownDistributing,
    candidates: candidates,
    all: sorted,
  );
});

final distributorAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(distributorAdsSplitProvider).all;
});

/// 配信中かつ有効な広告（カテゴリ・地域フィルタなし）。
/// 注目カルーセル等、フィルタ独立の掲載枠向け。
final activeDistributingAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(adListProvider)
      .where((ad) =>
          ad.isVisibleToCatalog && ad.isDistributing && ad.isActive)
      .toList();
});

final spotlightAdsProvider = Provider<List<Ad>>((ref) {
  final placements = ref
      .watch(featuredPlacementRepositoryProvider)
      .where((p) => p.placementKey == FeaturedPlacementKeys.memberHomeSpotlight)
      .toList();
  return FeaturedCarouselResolver.resolve(
    placements: placements,
    catalog: ref.watch(activeDistributingAdsProvider),
  );
});

final distributorSpotlightAdsProvider = Provider<List<Ad>>((ref) {
  // 会員ホームと同一の注目カルーセル実装・掲載枠を共有
  return ref.watch(spotlightAdsProvider);
});

final endedAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).ended;
});

final activeAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).active;
});

final draftAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).drafts;
});

final pendingAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).pending;
});

final distributorHistoryAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(adListProvider)
      .where((ad) => ad.wasDistributed && (ad.isEnded || !ad.isDistributing))
      .toList();
});

/// この配信者が過去に配信したことのある制作元（advertiserCompanyName）の集合。
Set<String> pastAdvertiserNamesFrom(List<Ad> ads) {
  return ads
      .where((ad) => ad.wasDistributed)
      .map((ad) => ad.advertiserCompanyName)
      .toSet();
}

/// かつて配信した制作元の新作・再配信候補（未配信の公開広告）。
List<Ad> filterPastAdvertiserPickup({
  required List<Ad> allAds,
  required List<Ad> categoryFiltered,
}) {
  final pastAdvertisers = pastAdvertiserNamesFrom(allAds);
  if (pastAdvertisers.isEmpty) return const [];

  return categoryFiltered.where((ad) {
    return pastAdvertisers.contains(ad.advertiserCompanyName) &&
        !ad.isOwnAd &&
        !ad.isDistributing &&
        ad.isVisibleToCatalog &&
        !ad.isEnded;
  }).toList();
}

final distributorPastAdvertiserPickupProvider = Provider<List<Ad>>((ref) {
  final all = ref.watch(adListProvider);
  final filtered = ref.watch(categoryPrefectureFilteredAdsProvider);
  final sortOrder = ref.watch(distributorSortOrderProvider);

  return applySort(
    filterPastAdvertiserPickup(allAds: all, categoryFiltered: filtered),
    sortOrder,
  );
});

/// 運営ダッシュボード用の集計。
class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalAds,
    required this.distributingAds,
    required this.memberVisibleAds,
    required this.pendingReviewAds,
    required this.draftAds,
    required this.totalViews,
    required this.advertiserCount,
    required this.pendingReports,
    required this.zeroDistributionAds,
    required this.rejectedAds,
    required this.recentActivities,
  });

  final int totalAds;
  final int distributingAds;
  final int memberVisibleAds;
  final int pendingReviewAds;
  final int draftAds;
  final int totalViews;
  final int advertiserCount;
  final int pendingReports;
  final int zeroDistributionAds;
  final int rejectedAds;
  final List<String> recentActivities;
}

final adminDashboardStatsProvider = Provider<AdminDashboardStats>((ref) {
  final all = ref.watch(adListProvider);
  final split = ref.watch(advertiserAdsSplitProvider);
  final reports = ref.watch(adReportRepositoryProvider);
  final auditLogs = ref.watch(auditLogRepositoryProvider);

  final distributing =
      all.where((ad) => ad.isDistributing && ad.isActive).length;
  final memberVisible = all
      .where(
        (ad) =>
            ad.isDistributing &&
            ad.isActive &&
            ad.isVisibleToCatalog,
      )
      .length;
  final totalViews = all.fold<int>(0, (sum, ad) => sum + ad.viewCount);
  final zeroDistribution = all
      .where(
        (ad) =>
            ad.isVisibleToCatalog &&
            ad.isActive &&
            !ad.isDistributing,
      )
      .length;

  final activities = auditLogs.take(10).map((e) {
    final time = '${e.timestamp.hour.toString().padLeft(2, '0')}:'
        '${e.timestamp.minute.toString().padLeft(2, '0')}';
    return '[$time] ${e.actor}: ${e.summary}';
  }).toList();
  if (activities.isEmpty) {
    activities.add('現在、表示する活動はありません');
  }

  return AdminDashboardStats(
    totalAds: all.length,
    distributingAds: distributing,
    memberVisibleAds: memberVisible,
    pendingReviewAds: split.pending.length,
    draftAds: split.drafts.length,
    totalViews: totalViews,
    advertiserCount: split.all.length,
    pendingReports: reports.length,
    zeroDistributionAds: zeroDistribution,
    rejectedAds: split.rejected.length,
    recentActivities: activities,
  );
});

final adminAdsSearchProvider = StateProvider<String>((ref) => '');

final adminAdsStatusFilterProvider =
    StateProvider<AdPublicationStatus?>((ref) => null);

final adminAdsProvider = Provider<List<Ad>>((ref) {
  final all = ref.watch(adListProvider);
  final query = ref.watch(adminAdsSearchProvider).trim().toLowerCase();
  final status = ref.watch(adminAdsStatusFilterProvider);

  return all.where((ad) {
    if (status != null && ad.publicationStatus != status) return false;
    if (query.isEmpty) return true;
    return ad.companyName.toLowerCase().contains(query) ||
        ad.catchCopy.toLowerCase().contains(query);
  }).toList();
});

class DistributorTodayTasks {
  const DistributorTodayTasks({
    required this.newlyPublished,
    required this.endingSoon,
    required this.spotlightNotDistributed,
  });

  final List<Ad> newlyPublished;
  final List<Ad> endingSoon;
  final List<Ad> spotlightNotDistributed;

  bool get isEmpty =>
      newlyPublished.isEmpty &&
      endingSoon.isEmpty &&
      spotlightNotDistributed.isEmpty;
}

final distributorTodayTasksProvider = Provider<DistributorTodayTasks>((ref) {
  final all = ref.watch(categoryPrefectureFilteredAdsProvider);
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final threeDaysLater = now.add(const Duration(days: 3));

  final newlyPublished = all
      .where(
        (ad) =>
            !ad.isDistributing &&
            ad.isVisibleToCatalog &&
            !ad.isEnded &&
            !ad.startDate.isBefore(sevenDaysAgo),
      )
      .take(3)
      .toList();

  final endingSoon = all
      .where(
        (ad) =>
            ad.isVisibleToCatalog &&
            !ad.isEnded &&
            ad.endDate.isBefore(threeDaysLater) &&
            !ad.endDate.isBefore(now),
      )
      .take(3)
      .toList();

  final spotlightNotDistributed = all
      .where(
        (ad) =>
            ad.hasSpotlightOption &&
            !ad.isDistributing &&
            ad.isVisibleToCatalog &&
            !ad.isEnded,
      )
      .take(3)
      .toList();

  return DistributorTodayTasks(
    newlyPublished: newlyPublished,
    endingSoon: endingSoon,
    spotlightNotDistributed: spotlightNotDistributed,
  );
});
