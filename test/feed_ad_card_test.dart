import 'package:carilune/models/ad.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:carilune/providers/favorites_provider.dart';
import 'package:carilune/widgets/ideal/consumer/feed_ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  final testAd = Ad(
    id: 'feed-test',
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

  Future<ProviderScope> scopedApp(Widget child) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('FeedAdCard renders without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await scopedApp(
        SizedBox(
          width: 360,
          child: FeedAdCard(ad: testAd),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('テストキャッチコピーが入ります'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FeedAdCard toggles favorite', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: FeedAdCard(ad: testAd),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(favoritesProvider), isEmpty);
    await tester.tap(find.text('お気に入り'));
    await tester.pumpAndSettle();
    expect(container.read(favoritesProvider), contains('feed-test'));
  });
}
