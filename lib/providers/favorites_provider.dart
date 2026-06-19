import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._prefs) : super({}) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _key = 'favorite_ad_ids';
  static const _saveDebounce = Duration(milliseconds: 300);

  Timer? _saveTimer;

  void _load() {
    final stored = _prefs.getStringList(_key);
    if (stored != null) {
      state = stored.toSet();
    }
  }

  Future<void> _save() async {
    await _prefs.setStringList(_key, state.toList());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, () {
      _save();
    });
  }

  void toggle(String adId) {
    if (state.contains(adId)) {
      state = Set<String>.from(state)..remove(adId);
    } else {
      state = Set<String>.from(state)..add(adId);
    }
    _scheduleSave();
  }

  bool isFavorite(String adId) => state.contains(adId);

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesNotifier(prefs);
});

/// お気に入り状態を広告 ID 単位で watch（全件トグル時の不要な rebuild を防ぐ）
final isFavoriteProvider = Provider.family<bool, String>((ref, adId) {
  return ref.watch(favoritesProvider.select((ids) => ids.contains(adId)));
});
