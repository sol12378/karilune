import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_repository.dart';
import '../data/featured_placement_repository.dart';
import '../models/ad.dart';
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
  final placements = ref
      .watch(featuredPlacementRepositoryProvider)
      .where(
        (p) => p.placementKey == FeaturedPlacementKeys.distributorHomeSpotlight,
      )
      .toList();
  return FeaturedCarouselResolver.resolve(
    placements: placements,
    catalog: ref.watch(activeDistributingAdsProvider),
  );
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
