import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/ads_mock.dart';
import '../models/ad.dart';
import '../models/ad_publication_status.dart';

class AdRepository extends StateNotifier<List<Ad>> {
  AdRepository() : super(List<Ad>.from(initialAds));

  List<Ad> getAll() => state;

  Ad? findById(String id) {
    try {
      return state.firstWhere((ad) => ad.id == id);
    } catch (_) {
      return null;
    }
  }

  void upsert(Ad ad) {
    final index = state.indexWhere((item) => item.id == ad.id);
    if (index == -1) {
      state = [ad, ...state];
      return;
    }
    final updated = List<Ad>.from(state);
    updated[index] = ad;
    state = updated;
  }

  void toggleDistributing(String adId) {
    state = state
        .map(
          (ad) {
            if (ad.id != adId) return ad;
            final turningOn = !ad.isDistributing;
            return ad.copyWith(
              isDistributing: turningOn,
              wasDistributed: turningOn ? true : ad.wasDistributed,
              distributorCount: turningOn
                  ? ad.distributorCount + 1
                  : ad.distributorCount,
            );
          },
        )
        .toList();
  }

  void incrementViewCount(String adId) {
    state = state
        .map(
          (ad) => ad.id == adId
              ? ad.copyWith(viewCount: ad.viewCount + 1)
              : ad,
        )
        .toList();
  }

  void publishAfterPayment(Ad ad) {
    upsert(ad.copyWith(publicationStatus: AdPublicationStatus.published));
  }
}

final adRepositoryProvider =
    StateNotifierProvider<AdRepository, List<Ad>>((ref) {
  return AdRepository();
});
