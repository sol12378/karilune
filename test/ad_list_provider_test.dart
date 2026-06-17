import 'package:carilune/models/ad.dart';
import 'package:carilune/providers/ad_list_provider.dart';
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
}
