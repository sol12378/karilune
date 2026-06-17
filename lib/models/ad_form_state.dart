import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/ad.dart';

part 'ad_form_state.freezed.dart';

@freezed
class AdFormState with _$AdFormState {
  const factory AdFormState({
    @Default(false) bool isEditMode,
    String? editingAdId,
    @Default('') String companyName,
    @Default('') String catchCopy,
    @Default('') String prText,
    @Default('飲食店') String category,
    @Default('愛知県') String prefecture,
    @Default(5) int distributionDays,
    DateTime? startDate,
    @Default('assets/images/placeholder_ad_01.png') String thumbnailAssetPath,
    @Default(false) bool hasSpotlightOption,
    @Default(false) bool hasDistributionRequestNotification,
    @Default(false) bool hasDistributionSettingNotification,
    @Default(0) int currentStep,
  }) = _AdFormState;
}

extension AdFormStateX on AdFormState {
  AdFormState fromAd(Ad ad) {
    return copyWith(
      isEditMode: true,
      editingAdId: ad.id,
      companyName: ad.companyName,
      catchCopy: ad.catchCopy,
      prText: ad.prText,
      category: ad.category,
      prefecture: ad.prefecture,
      distributionDays: ad.distributionDays,
      startDate: ad.startDate,
      thumbnailAssetPath: ad.thumbnailAssetPath,
      hasSpotlightOption: ad.hasSpotlightOption,
      hasDistributionRequestNotification: ad.hasDistributionRequestNotification,
      hasDistributionSettingNotification: ad.hasDistributionSettingNotification,
      currentStep: 0,
    );
  }

  Ad toPreviewAd() {
    return Ad(
      id: 'preview',
      companyName: companyName.isEmpty ? '店舗名' : companyName,
      catchCopy: catchCopy.isEmpty ? 'キャッチコピー' : catchCopy,
      prText: prText,
      thumbnailAssetPath: thumbnailAssetPath,
      category: category,
      prefecture: prefecture,
      startDate: startDate ?? DateTime.now(),
      distributionDays: distributionDays,
      hasSpotlightOption: hasSpotlightOption,
    );
  }
}
