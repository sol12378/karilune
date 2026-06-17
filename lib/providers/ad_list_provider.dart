import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_repository.dart';
import '../models/ad.dart';

enum SortOrder {
  newest,
  endingSoon,
  popular,
}

/// 全広告リスト（Repository のエイリアス）
final adListProvider = Provider<List<Ad>>((ref) {
  return ref.watch(adRepositoryProvider);
});

/// 投稿者向け広告（自社・管理対象）
final advertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(adRepositoryProvider)
      .where((ad) => ad.isAdvertiserAd || ad.isOwnAd)
      .toList();
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

final filteredAdsProvider = Provider<List<Ad>>((ref) {
  final ads = ref.watch(adListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final prefecture = ref.watch(selectedPrefectureProvider);

  return applyCategoryPrefectureFilter(ads, category, prefecture);
});

final memberAdsProvider = Provider<List<Ad>>((ref) {
  final ads = ref.watch(adListProvider);
  final category = ref.watch(selectedCategoryProvider);
  final prefecture = ref.watch(selectedPrefectureProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  final filtered = applyCategoryPrefectureFilter(ads, category, prefecture)
      .where((ad) => ad.isDistributing && ad.isActive)
      .toList();

  return applySort(filtered, sortOrder);
});

final spotlightAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(memberAdsProvider)
      .where((ad) => ad.hasSpotlightOption)
      .toList();
});

final distributorSpotlightAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(filteredAdsProvider)
      .where((ad) => ad.hasSpotlightOption)
      .toList();
});

final endedAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsProvider).where((ad) => ad.isEnded).toList();
});

final activeAdvertiserAdsProvider = Provider<List<Ad>>((ref) {
  return ref.watch(advertiserAdsProvider).where((ad) => !ad.isEnded).toList();
});

final distributorHistoryAdsProvider = Provider<List<Ad>>((ref) {
  return ref
      .watch(adListProvider)
      .where((ad) => ad.wasDistributed && (ad.isEnded || !ad.isDistributing))
      .toList();
});
