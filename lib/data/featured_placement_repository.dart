import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/featured_placements_mock.dart';
import '../models/featured_placement.dart';

/// 注目カルーセル掲載設定の永続化層（現状はインメモリ、将来 DB に差し替え可能）。
abstract class FeaturedPlacementDataSource {
  List<FeaturedPlacement> fetchAll();
  void saveAll(List<FeaturedPlacement> placements);
}

class InMemoryFeaturedPlacementDataSource
    implements FeaturedPlacementDataSource {
  InMemoryFeaturedPlacementDataSource({List<FeaturedPlacement>? seed})
      : _placements = List<FeaturedPlacement>.from(
          seed ?? initialFeaturedPlacements,
        );

  List<FeaturedPlacement> _placements;

  @override
  List<FeaturedPlacement> fetchAll() => List<FeaturedPlacement>.from(_placements);

  @override
  void saveAll(List<FeaturedPlacement> placements) {
    _placements = List<FeaturedPlacement>.from(placements);
  }
}

class FeaturedPlacementRepository extends StateNotifier<List<FeaturedPlacement>> {
  FeaturedPlacementRepository(this._dataSource)
      : super(_dataSource.fetchAll());

  final FeaturedPlacementDataSource _dataSource;

  List<FeaturedPlacement> activeForKey(String placementKey) {
    return state
        .where(
          (placement) =>
              placement.placementKey == placementKey && placement.isActive,
        )
        .toList();
  }

  void upsert(FeaturedPlacement placement) {
    final index = state.indexWhere((item) => item.id == placement.id);
    if (index == -1) {
      state = [...state, placement];
    } else {
      final updated = List<FeaturedPlacement>.from(state);
      updated[index] = placement;
      state = updated;
    }
    _persist();
  }

  void remove(String id) {
    state = state.where((placement) => placement.id != id).toList();
    _persist();
  }

  void replaceForKey({
    required String placementKey,
    required List<FeaturedPlacement> placements,
  }) {
    final others =
        state.where((p) => p.placementKey != placementKey).toList();
    state = [...others, ...placements];
    _persist();
  }

  void _persist() {
    _dataSource.saveAll(state);
  }
}

final featuredPlacementDataSourceProvider =
    Provider<FeaturedPlacementDataSource>((ref) {
  return InMemoryFeaturedPlacementDataSource();
});

final featuredPlacementRepositoryProvider =
    StateNotifierProvider<FeaturedPlacementRepository, List<FeaturedPlacement>>(
  (ref) {
    return FeaturedPlacementRepository(
      ref.watch(featuredPlacementDataSourceProvider),
    );
  },
);
