import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/models/ad.dart';
import 'package:carilune/screens/distributor/distributor_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAdRepository extends AdRepository {
  _TestAdRepository(Ref ref, List<Ad> seed) : super(ref: ref) {
    state = seed;
  }
}

void main() {
  final testAd = Ad(
    id: 'toggle-test',
    companyName: 'テスト広告社',
    catchCopy: 'キャッチ',
    prText: 'PR',
    thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    category: '飲食店',
    prefecture: '愛知県',
    startDate: DateTime.now(),
    distributionDays: 30,
    isDistributing: false,
  );

  testWidgets('confirmToggleDistributing shows member feed snackbar on start',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRepositoryProvider.overrideWith(
            (ref) => _TestAdRepository(ref, [testAd]),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () =>
                      confirmToggleDistributing(context, ref, testAd),
                  child: const Text('toggle'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('配信する'));
    await tester.pumpAndSettle();

    expect(
      find.text('「テスト広告社」を配信しました。会員フィードに表示されます。'),
      findsOneWidget,
    );
  });

  testWidgets('confirmToggleDistributing shows member feed snackbar on stop',
      (tester) async {
    final distributingAd = testAd.copyWith(isDistributing: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRepositoryProvider.overrideWith(
            (ref) => _TestAdRepository(ref, [distributingAd]),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => confirmToggleDistributing(
                    context,
                    ref,
                    distributingAd,
                  ),
                  child: const Text('toggle'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('停止する'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '「テスト広告社」の配信を停止しました。会員フィードから非表示になります。',
      ),
      findsOneWidget,
    );
  });
}
