import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/ads_mock.dart';
import '../models/ad.dart';

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
          (ad) => ad.id == adId
              ? ad.copyWith(
                  isDistributing: !ad.isDistributing,
                  wasDistributed:
                      ad.isDistributing ? ad.wasDistributed : true,
                )
              : ad,
        )
        .toList();
  }
}

final adRepositoryProvider =
    StateNotifierProvider<AdRepository, List<Ad>>((ref) {
  return AdRepository();
});
