import 'package:freezed_annotation/freezed_annotation.dart';

import 'ad_publication_status.dart';

part 'ad.freezed.dart';

@freezed
class Ad with _$Ad {
  const factory Ad({
    required String id,
    required String companyName,
    required String catchCopy,
    required String prText,
    required String thumbnailAssetPath,
    required String category,
    required DateTime startDate,
    required int distributionDays,
    @Default(1000) int dailyFee,
    @Default(false) bool hasSpotlightOption,
    @Default(false) bool hasDistributionRequestNotification,
    @Default(false) bool hasDistributionSettingNotification,
    @Default(0) int distributorCount,
    @Default(0) int viewCount,
    @Default(false) bool isDistributing,
    String? thumbnailUrl,
    @Default('株式会社サンプル') String advertiserCompanyName,
    @Default('https://example.com') String advertiserUrl,
    @Default('052-000-0000') String advertiserTel,
    @Default('担当 太郎') String advertiserContact,
    @Default(false) bool isOwnAd,
    @Default('愛知県') String prefecture,
    @Default(false) bool isAdvertiserAd,
    @Default(false) bool wasDistributed,
    @Default(AdPublicationStatus.published) AdPublicationStatus publicationStatus,
    String? reviewNote,
    DateTime? reviewedAt,
  }) = _Ad;

  const Ad._();

  DateTime get endDate => startDate.add(Duration(days: distributionDays));

  bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(startDate) && now.isBefore(endDate);
  }

  bool get isScheduled => DateTime.now().isBefore(startDate);

  bool get isEnded => !DateTime.now().isBefore(endDate);

  bool get isVisibleToCatalog =>
      publicationStatus == AdPublicationStatus.published;

  bool get isDraft => publicationStatus == AdPublicationStatus.draft;

  bool get isPendingReview =>
      publicationStatus == AdPublicationStatus.pendingReview;

  bool get isRejected => publicationStatus == AdPublicationStatus.rejected;
}
