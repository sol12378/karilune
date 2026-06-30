import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/models/ad.dart';
import 'package:carilune/models/ad_publication_status.dart';
import 'package:carilune/widgets/admin/admin_review_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pendingAd = Ad(
    id: 'review-pending',
    companyName: '審査待ち店',
    catchCopy: 'キャッチ',
    prText: 'PR',
    thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    category: '飲食店',
    prefecture: '愛知県',
    startDate: DateTime.now(),
    distributionDays: 30,
    publicationStatus: AdPublicationStatus.pendingReview,
    isAdvertiserAd: true,
  );

  testWidgets('AdminReviewQueue shows approve reject return buttons',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRepositoryProvider.overrideWith(
            (ref) => AdRepository(ref: ref)..state = [pendingAd],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AdminReviewQueue()),
        ),
      ),
    );

    expect(find.text('審査待ち店'), findsOneWidget);
    expect(find.text('承認'), findsOneWidget);
    expect(find.text('却下'), findsOneWidget);
    expect(find.text('差戻し'), findsOneWidget);
  });
}
