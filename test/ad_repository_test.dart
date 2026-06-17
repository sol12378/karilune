import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/models/ad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdRepository', () {
    late AdRepository repository;

    setUp(() {
      repository = AdRepository();
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

    test('toggleDistributing flips flag', () {
      final ad = repository.findById('ad-002')!;
      expect(ad.isDistributing, isFalse);
      repository.toggleDistributing('ad-002');
      expect(repository.findById('ad-002')!.isDistributing, isTrue);
      expect(repository.findById('ad-002')!.wasDistributed, isTrue);
    });
  });
}
