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
    required this.active,
    required this.ended,
  });

  final List<Ad> all;
  final List<Ad> active;
  final List<Ad> ended;
}

/// 投稿者向け広告を1回の走査で active / ended に分割
final advertiserAdsSplitProvider = Provider<AdvertiserAdsSplit>((ref) {
  final all = ref
      .watch(adRepositoryProvider)
      .where((ad) => ad.isAdvertiserAd || ad.isOwnAd)
      .toList();
  final active = <Ad>[];
  final ended = <Ad>[];
  for (final ad in all) {
    if (ad.isEnded) {
      ended.add(ad);
    } else {
      active.add(ad);
    }
  }
  return AdvertiserAdsSplit(all: all, active: active, ended: ended);
});

/// 投稿者向け広告（自社・管理対象）
final advertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).all;
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'すべて');

final selectedPrefectureProvider = StateProvider<String>((ref) => 'すべて');

final sortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.newest);

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
  }
  return sorted;
}

/// カテゴリ・地域フィルタのみ適用（会員・配信者で共有）
final categoryPrefectureFilteredAdsProvider = Provider<List<Ad>>((ref) {
  final ads = ref.watch(adListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final prefecture = ref.watch(selectedPrefectureProvider);
  return applyCategoryPrefectureFilter(ads, category, prefecture);
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

final spotlightAdsProvider = Provider<List<Ad>>((ref) {
  final placements = ref
      .watch(featuredPlacementRepositoryProvider)
      .where((p) => p.placementKey == FeaturedPlacementKeys.memberHomeSpotlight)
      .toList();
  return FeaturedCarouselResolver.resolve(
    placements: placements,
    catalog: ref.watch(memberAdsProvider),
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
    catalog: ref.watch(categoryPrefectureFilteredAdsProvider),
  );
});

final endedAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).ended;
});

final activeAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsSplitProvider).active;
});

final distributorHistoryAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(adListProvider)
      .where((ad) => ad.wasDistributed && (ad.isEnded || !ad.isDistributing))
      .toList();
});
