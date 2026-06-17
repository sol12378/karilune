import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._prefs) : super({}) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _key = 'favorite_ad_ids';

  void _load() {
    final stored = _prefs.getStringList(_key);
    if (stored != null) {
      state = stored.toSet();
    }
  }

  Future<void> _save() async {
    await _prefs.setStringList(_key, state.toList());
  }

  void toggle(String adId) {
    if (state.contains(adId)) {
      state = Set<String>.from(state)..remove(adId);
    } else {
      state = Set<String>.from(state)..add(adId);
    }
    _save();
  }

  bool isFavorite(String adId) => state.contains(adId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesNotifier(prefs);
});
