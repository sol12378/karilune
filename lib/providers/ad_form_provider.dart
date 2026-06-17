import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_repository.dart';
import '../models/ad.dart';
import '../models/ad_form_state.dart';

final adFormProvider =
    StateNotifierProvider<AdFormNotifier, AdFormState>((ref) {
  return AdFormNotifier(ref);
});

class AdFormNotifier extends StateNotifier<AdFormState> {
  AdFormNotifier(this._ref) : super(const AdFormState());

  final Ref _ref;

  void startCreate() {
    state = AdFormState(
      isEditMode: false,
      startDate: DateTime.now(),
      currentStep: 0,
      thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
    );
  }

  void startEdit(Ad ad) {
    state = const AdFormState().fromAd(ad);
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updateCompanyName(String value) {
    state = state.copyWith(companyName: value);
  }

  void updateCatchCopy(String value) {
    state = state.copyWith(catchCopy: value);
  }

  void updatePrText(String value) {
    state = state.copyWith(prText: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(category: value);
  }

  void updatePrefecture(String value) {
    state = state.copyWith(prefecture: value);
  }

  void updateDistributionDays(int value) {
    state = state.copyWith(distributionDays: value);
  }

  void updateStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void updateThumbnailAssetPath(String value) {
    state = state.copyWith(thumbnailAssetPath: value);
  }

  void toggleSpotlight(bool value) {
    state = state.copyWith(hasSpotlightOption: value);
  }

  void toggleDistributionRequest(bool value) {
    state = state.copyWith(hasDistributionRequestNotification: value);
  }

  void toggleDistributionSetting(bool value) {
    state = state.copyWith(hasDistributionSettingNotification: value);
  }

  String? validateStep(int step) {
    switch (step) {
      case 0:
        if (state.thumbnailAssetPath.isEmpty) {
          return 'サムネイルを選択してください';
        }
        return null;
      case 1:
        if (state.companyName.trim().isEmpty) {
          return '店舗・会社名を入力してください';
        }
        if (state.catchCopy.trim().isEmpty) {
          return 'キャッチコピーを入力してください';
        }
        if (state.prText.trim().isEmpty) {
          return 'PR文を入力してください';
        }
        return null;
      case 2:
        if (state.distributionDays < 1 || state.distributionDays > 90) {
          return '配信日数は1〜90日の範囲で設定してください';
        }
        return null;
      default:
        return null;
    }
  }

  void submit() {
    final form = state;
    final id = form.isEditMode
        ? form.editingAdId!
        : 'ad-${DateTime.now().millisecondsSinceEpoch}';

    final existing = _ref.read(adRepositoryProvider.notifier).findById(id);

    final ad = Ad(
      id: id,
      companyName: form.companyName.trim(),
      catchCopy: form.catchCopy.trim(),
      prText: form.prText.trim(),
      thumbnailAssetPath: form.thumbnailAssetPath,
      category: form.category,
      prefecture: form.prefecture,
      startDate: form.startDate ?? DateTime.now(),
      distributionDays: form.distributionDays,
      hasSpotlightOption: form.hasSpotlightOption,
      hasDistributionRequestNotification:
          form.hasDistributionRequestNotification,
      hasDistributionSettingNotification:
          form.hasDistributionSettingNotification,
      isOwnAd: true,
      isAdvertiserAd: true,
      distributorCount: existing?.distributorCount ?? 0,
      viewCount: existing?.viewCount ?? 0,
      isDistributing: existing?.isDistributing ?? false,
    );

    _ref.read(adRepositoryProvider.notifier).upsert(ad);
    startCreate();
  }
}
