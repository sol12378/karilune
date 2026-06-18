import 'package:carilune/models/ad.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:carilune/widgets/featured/featured_ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  final testAd = Ad(
    id: 'featured-test',
    companyName: 'テスト店舗',
    catchCopy: 'テストキャッチコピーが入ります',
    prText: 'PR文',
    thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    category: '飲食店',
    prefecture: '愛知県',
    startDate: DateTime.now(),
    distributionDays: 30,
    hasSpotlightOption: true,
  );

  testWidgets('FeaturedAdCard does not overflow at narrow width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: FeaturedAdCard(ad: testAd),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
