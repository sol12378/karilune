import 'package:carilune/models/ad.dart';
import 'package:carilune/models/featured_placement.dart';
import 'package:carilune/providers/ad_list_provider.dart';
import 'package:carilune/services/featured_carousel_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleAds = [
    Ad(
      id: '1',
      companyName: 'A',
      catchCopy: 'copy',
      prText: 'pr',
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
      category: '飲食店',
      prefecture: '愛知県',
      startDate: DateTime(2026, 1, 1),
      distributionDays: 10,
      viewCount: 100,
    ),
    Ad(
      id: '2',
      companyName: 'B',
      catchCopy: 'copy',
      prText: 'pr',
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
      category: '生活雑貨',
      prefecture: '岐阜県',
      startDate: DateTime(2026, 2, 1),
      distributionDays: 10,
      viewCount: 200,
      isDistributing: true,
    ),
  ];

  test('applyCategoryPrefectureFilter filters by category', () {
    final result = applyCategoryPrefectureFilter(
      sampleAds,
      '飲食店',
      'すべて',
    );
    expect(result, hasLength(1));
    expect(result.first.id, '1');
  });

  test('applyCategoryPrefectureFilter filters by prefecture', () {
    final result = applyCategoryPrefectureFilter(
      sampleAds,
      'すべて',
      '岐阜県',
    );
    expect(result, hasLength(1));
    expect(result.first.id, '2');
  });

  test('applySort sorts by popularity', () {
    final result = applySort(sampleAds, SortOrder.popular);
    expect(result.first.viewCount, 200);
  });

  test('spotlight resolve is independent of category filter', () {
    final catalog = [
      Ad(
        id: 'spot-a',
        companyName: 'A',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '飲食店',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
        isDistributing: true,
      ),
      Ad(
        id: 'spot-b',
        companyName: 'B',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '生活雑貨',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
        isDistributing: true,
      ),
    ];
    final placements = [
      const FeaturedPlacement(
        id: '1',
        placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
        adId: 'spot-a',
        sortOrder: 0,
      ),
      const FeaturedPlacement(
        id: '2',
        placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
        adId: 'spot-b',
        sortOrder: 1,
      ),
    ];

    final allCategory = FeaturedCarouselResolver.resolve(
      placements: placements,
      catalog: catalog,
    );
    final foodOnly = FeaturedCarouselResolver.resolve(
      placements: placements,
      catalog: applyCategoryPrefectureFilter(catalog, '飲食店', 'すべて'),
    );

    expect(allCategory, hasLength(2));
    expect(foodOnly, hasLength(1));
  });

  test('pastAdvertiserNamesFrom collects names from distributed history', () {
    final ads = [
      sampleAds[0].copyWith(
        wasDistributed: true,
        advertiserCompanyName: '株式会社A',
      ),
      sampleAds[1].copyWith(
        wasDistributed: true,
        advertiserCompanyName: '株式会社A',
      ),
      sampleAds[0].copyWith(
        id: '3',
        wasDistributed: false,
        advertiserCompanyName: '株式会社B',
      ),
    ];
    expect(pastAdvertiserNamesFrom(ads), {'株式会社A'});
  });

  test('filterPastAdvertiserPickup returns new ads from past advertisers', () {
    final now = DateTime.now();
    final all = [
      sampleAds[0].copyWith(
        id: 'hist',
        wasDistributed: true,
        advertiserCompanyName: '株式会社匠',
        isDistributing: false,
        startDate: now.subtract(const Duration(days: 60)),
        distributionDays: 30,
      ),
      sampleAds[1].copyWith(
        id: 'new-ad',
        advertiserCompanyName: '株式会社匠',
        isDistributing: false,
        isAdvertiserAd: true,
        startDate: now.subtract(const Duration(days: 2)),
        distributionDays: 30,
      ),
      sampleAds[0].copyWith(
        id: 'other',
        advertiserCompanyName: '別会社',
        isDistributing: false,
        startDate: now.subtract(const Duration(days: 2)),
        distributionDays: 30,
      ),
    ];
    final filtered = all;

    final pickup = filterPastAdvertiserPickup(
      allAds: all,
      categoryFiltered: filtered,
    );

    expect(pickup, hasLength(1));
    expect(pickup.first.id, 'new-ad');
  });
}
