import 'package:carilune/models/ad.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:carilune/widgets/ad_card_consumer.dart';
import 'package:carilune/widgets/ad_card_distributor.dart';
import 'package:carilune/widgets/ad_card_distributor_visual.dart';
import 'package:carilune/widgets/ad_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderScope> scopedApp(Widget child) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  final testAd = Ad(
    id: 'overflow-test',
    companyName: 'テスト店舗名',
    catchCopy: 'テストキャッチコピーが入ります',
    prText: 'PR文',
    thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    category: '飲食店',
    prefecture: '愛知県',
    startDate: DateTime.now(),
    distributionDays: 30,
  );

  testWidgets('AdCardConsumer does not overflow at narrow width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(240, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final app = await scopedApp(
      SizedBox(
        width: 220,
        height: 300,
        child: AdCardConsumer(ad: testAd),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdGridView renders without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final app = await scopedApp(
      AdGridView.builder(
        itemCount: 2,
        itemBuilder: (context, index) => AdCardConsumer(ad: testAd),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdCardDistributorVisual opens detail on image tap', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 440));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var tapped = false;
    final app = await scopedApp(
      SizedBox(
        width: 300,
        height: 420,
        child: AdCardDistributorVisual(
          ad: testAd,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('詳細を見る'), findsOneWidget);
    await tester.tap(find.text('詳細を見る'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('AdCardDistributorVisual shows status button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 440));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final distributingAd = testAd.copyWith(isDistributing: true);
    final app = await scopedApp(
      SizedBox(
        width: 300,
        height: 420,
        child: AdCardDistributorVisual(ad: distributingAd),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('配信中'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final pendingAd = testAd.copyWith(isDistributing: false);
    await tester.pumpWidget(
      await scopedApp(
        SizedBox(
          width: 300,
          height: 420,
          child: AdCardDistributorVisual(ad: pendingAd),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('未配信'), findsOneWidget);
  });

  testWidgets('AdCardDistributor shows recommended badge for spotlight ads', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 420));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final spotlightAd = testAd.copyWith(
      hasSpotlightOption: true,
      isDistributing: true,
    );
    final app = await scopedApp(
      SizedBox(
        width: 280,
        height: 380,
        child: AdCardDistributor(ad: spotlightAd),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('お勧め'), findsOneWidget);
    expect(find.text('配信中'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
