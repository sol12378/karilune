import 'package:carilune/models/ad.dart';
import 'package:carilune/models/ad_publication_status.dart';
import 'package:carilune/providers/ad_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final catalog = [
    Ad(
      id: 'pub-1',
      companyName: 'A',
      catchCopy: 'copy',
      prText: 'pr',
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
      category: '飲食店',
      prefecture: '愛知県',
      startDate: now.subtract(const Duration(days: 1)),
      distributionDays: 30,
      hasSpotlightOption: true,
      isDistributing: false,
    ),
    Ad(
      id: 'pub-2',
      companyName: 'B',
      catchCopy: 'copy',
      prText: 'pr',
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
      category: '飲食店',
      prefecture: '愛知県',
      startDate: now.subtract(const Duration(days: 2)),
      distributionDays: 30,
      isDistributing: true,
    ),
    Ad(
      id: 'draft-1',
      companyName: 'Draft',
      catchCopy: 'copy',
      prText: 'pr',
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
      category: '飲食店',
      prefecture: '愛知県',
      startDate: now,
      distributionDays: 30,
      publicationStatus: AdPublicationStatus.draft,
    ),
  ];

  test('publishedCatalogAds excludes drafts and ended', () {
    final result = publishedCatalogAds(catalog);
    expect(result.map((a) => a.id), containsAll(['pub-1', 'pub-2']));
    expect(result.map((a) => a.id), isNot(contains('draft-1')));
  });

  test('applySort recommended prioritizes spotlight', () {
    final result = applySort(catalog.where((a) => a.isVisibleToCatalog).toList(),
        SortOrder.recommended);
    expect(result.first.hasSpotlightOption, isTrue);
  });

  test('applyDistributorDistributionFilter filters distributing', () {
    final published = publishedCatalogAds(catalog);
    final result = applyDistributorDistributionFilter(
      published,
      DistributorDistributionFilter.distributing,
    );
    expect(result, hasLength(1));
    expect(result.first.id, 'pub-2');
  });
}
