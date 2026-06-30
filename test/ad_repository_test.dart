import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/models/ad.dart';
import 'package:carilune/models/ad_publication_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdRepository', () {
    late ProviderContainer container;
    late AdRepository repository;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      repository = container.read(adRepositoryProvider.notifier);
    });

    test('findById returns ad when exists', () {
      final ad = repository.findById('ad-001');
      expect(ad, isNotNull);
      expect(ad!.companyName, '名古屋焼肉 炎');
    });

    test('upsert adds new ad', () {
      final newAd = Ad(
        id: 'test-ad',
        companyName: 'テスト店',
        catchCopy: 'テストコピー',
        prText: 'PR',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '飲食店',
        prefecture: '愛知県',
        startDate: DateTime.now(),
        distributionDays: 10,
        isAdvertiserAd: true,
        isOwnAd: true,
      );
      repository.upsert(newAd);
      expect(repository.findById('test-ad'), isNotNull);
    });

    test('toggleDistributing flips flag and increments distributorCount', () {
      final ad = repository.findById('ad-002')!;
      final beforeCount = ad.distributorCount;
      expect(ad.isDistributing, isFalse);
      repository.toggleDistributing('ad-002');
      final updated = repository.findById('ad-002')!;
      expect(updated.isDistributing, isTrue);
      expect(updated.wasDistributed, isTrue);
      expect(updated.distributorCount, beforeCount + 1);
    });

    test('incrementViewCount increases viewCount', () {
      final before = repository.findById('ad-001')!.viewCount;
      repository.incrementViewCount('ad-001');
      expect(repository.findById('ad-001')!.viewCount, before + 1);
    });

    test('approveReview publishes pending ad', () {
      final pending = repository
          .getAll()
          .firstWhere((ad) => ad.isPendingReview);
      repository.approveReview(pending.id);
      final updated = repository.findById(pending.id)!;
      expect(updated.publicationStatus, AdPublicationStatus.published);
      expect(updated.reviewedAt, isNotNull);
    });

    test('rejectReview sets rejected with note', () {
      final pending = repository
          .getAll()
          .firstWhere((ad) => ad.isPendingReview);
      repository.rejectReview(pending.id, '不適切な表現');
      final updated = repository.findById(pending.id)!;
      expect(updated.isRejected, isTrue);
      expect(updated.reviewNote, '不適切な表現');
    });

    test('returnToDraft sets draft with note', () {
      repository.upsert(
        Ad(
          id: 'return-test',
          companyName: '差戻しテスト',
          catchCopy: 'copy',
          prText: 'pr',
          thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
          category: '飲食店',
          prefecture: '愛知県',
          startDate: DateTime.now(),
          distributionDays: 10,
          publicationStatus: AdPublicationStatus.pendingReview,
          isAdvertiserAd: true,
        ),
      );
      repository.returnToDraft('return-test', '画像が不鮮明');
      final updated = repository.findById('return-test')!;
      expect(updated.isDraft, isTrue);
      expect(updated.reviewNote, '画像が不鮮明');
    });

    test('resubmitForReview moves rejected to pending', () {
      repository.upsert(
        Ad(
          id: 'resubmit-test',
          companyName: '再申請テスト',
          catchCopy: 'copy',
          prText: 'pr',
          thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
          category: '飲食店',
          prefecture: '愛知県',
          startDate: DateTime.now(),
          distributionDays: 10,
          publicationStatus: AdPublicationStatus.rejected,
          reviewNote: '修正してください',
          isAdvertiserAd: true,
        ),
      );
      repository.resubmitForReview('resubmit-test');
      final updated = repository.findById('resubmit-test')!;
      expect(updated.isPendingReview, isTrue);
      expect(updated.reviewNote, isNull);
    });

    test('emergencyStop turns off distribution', () {
      final ad = repository.findById('ad-001')!;
      repository.upsert(ad.copyWith(isDistributing: true));
      repository.emergencyStop('ad-001');
      expect(repository.findById('ad-001')!.isDistributing, isFalse);
    });
  });
}
