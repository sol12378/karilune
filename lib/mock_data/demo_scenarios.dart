import '../models/ad.dart';
import '../models/ad_publication_status.dart';
import 'ads_mock.dart';

/// デモ用シナリオ ID。
enum DemoScenarioId {
  s1Default,
  s2Pickup,
  s3EmptyMember,
  s4AdvertiserDraft,
}

extension DemoScenarioIdX on DemoScenarioId {
  String get label {
    switch (this) {
      case DemoScenarioId.s1Default:
        return 'S1: 通常運用';
      case DemoScenarioId.s2Pickup:
        return 'S2: 制作元ピックアップ';
      case DemoScenarioId.s3EmptyMember:
        return 'S3: 会員フィード空';
      case DemoScenarioId.s4AdvertiserDraft:
        return 'S4: 下書き・審査中混在';
    }
  }

  String get description {
    switch (this) {
      case DemoScenarioId.s1Default:
        return '現行の mock データ（配信中広告あり）';
      case DemoScenarioId.s2Pickup:
        return '過去配信制作元の新作（未配信）でピックアップ帯を強調';
      case DemoScenarioId.s3EmptyMember:
        return '全広告未配信 — 会員フィード空状態のデモ';
      case DemoScenarioId.s4AdvertiserDraft:
        return '下書き・審査中・公開済みが混在';
    }
  }
}

/// シナリオ ID から広告 seed を生成する。
List<Ad> adsForScenario(DemoScenarioId id) {
  switch (id) {
    case DemoScenarioId.s1Default:
      return List<Ad>.from(mockAds);
    case DemoScenarioId.s2Pickup:
      return _scenarioS2Pickup();
    case DemoScenarioId.s3EmptyMember:
      return mockAds
          .map((ad) => ad.copyWith(isDistributing: false))
          .toList();
    case DemoScenarioId.s4AdvertiserDraft:
      return _scenarioS4AdvertiserDraft();
  }
}

List<Ad> _scenarioS2Pickup() {
  final ads = List<Ad>.from(mockAds);

  // 炎グループ: 過去配信済み + 新作未配信
  final honooPastIndex = ads.indexWhere((ad) => ad.id == 'ad-001');
  if (honooPastIndex != -1) {
    ads[honooPastIndex] = ads[honooPastIndex].copyWith(
      wasDistributed: true,
      isDistributing: false,
    );
  }

  ads.add(
    Ad(
      id: 'ad-pickup-demo',
      companyName: '名古屋焼肉 炎 新店',
      catchCopy: '新店オープン記念！ランチコース半額',
      prText: '名駅に新店オープン。ランチタイム限定の特別コースをご用意。',
      thumbnailAssetPath: assetPath(1),
      category: '飲食店',
      prefecture: '愛知県',
      startDate: DateTime.now(),
      distributionDays: 30,
      hasSpotlightOption: true,
      isAdvertiserAd: true,
      distributorCount: 0,
      viewCount: 0,
      isDistributing: false,
      wasDistributed: false,
      advertiserCompanyName: '株式会社炎グループ',
      advertiserUrl: 'https://honoo-yakiniku.example.com',
      advertiserTel: '052-111-2222',
      advertiserContact: '店長 山田',
    ),
  );

  return ads;
}

List<Ad> _scenarioS4AdvertiserDraft() {
  final ads = List<Ad>.from(mockAds);
  if (ads.isEmpty) return ads;

  ads[0] = ads[0].copyWith(
    publicationStatus: AdPublicationStatus.published,
    isDistributing: true,
  );
  if (ads.length > 1) {
    ads[1] = ads[1].copyWith(
      publicationStatus: AdPublicationStatus.draft,
      isDistributing: false,
    );
  }
  if (ads.length > 2) {
    ads[2] = ads[2].copyWith(
      publicationStatus: AdPublicationStatus.pendingReview,
      isDistributing: false,
    );
  }
  if (ads.length > 3) {
    ads[3] = ads[3].copyWith(
      publicationStatus: AdPublicationStatus.rejected,
      isDistributing: false,
      reviewNote: '掲載画像の解像度が基準を満たしていません',
    );
  }

  return ads;
}
