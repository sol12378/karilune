import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/models/ad.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:carilune/screens/ad_detail/ad_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAdRepository extends AdRepository {
  _TestAdRepository(Ref ref, List<Ad> seed) : super(ref: ref) {
    state = seed;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  final testAd = Ad(
    id: 'detail-member-test',
    companyName: 'テスト店舗',
    catchCopy: '会員向けキャッチコピー',
    prText: 'PR本文です',
    thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    category: '飲食店',
    prefecture: '愛知県',
    startDate: DateTime.now(),
    distributionDays: 30,
    isDistributing: true,
  );

  testWidgets('Member detail hides pricing info', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          adRepositoryProvider.overrideWith(
            (ref) => _TestAdRepository(ref, [testAd]),
          ),
        ],
        child: const MaterialApp(
          home: AdDetailPage(adId: 'detail-member-test', fromMode: 'member'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('会員向けキャッチコピー'), findsOneWidget);
    expect(find.text('お店情報'), findsOneWidget);
    expect(find.text('配信情報'), findsNothing);
    expect(find.text('広告料金'), findsNothing);
    expect(find.text('お気に入り'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '電話'), findsOneWidget);
  });
}
