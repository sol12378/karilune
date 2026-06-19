/// 注目カルーセル等への広告掲載設定（DB テーブルのドメインモデル）。
class FeaturedPlacement {
  const FeaturedPlacement({
    required this.id,
    required this.placementKey,
    required this.adId,
    required this.sortOrder,
    this.isActive = true,
  });

  final String id;
  final String placementKey;
  final String adId;
  final int sortOrder;
  final bool isActive;

  FeaturedPlacement copyWith({
    String? id,
    String? placementKey,
    String? adId,
    int? sortOrder,
    bool? isActive,
  }) {
    return FeaturedPlacement(
      id: id ?? this.id,
      placementKey: placementKey ?? this.placementKey,
      adId: adId ?? this.adId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 掲載先スロット識別子。DB の placement_key に相当。
abstract final class FeaturedPlacementKeys {
  static const memberHomeSpotlight = 'member_home_spotlight';
  static const distributorHomeSpotlight = 'distributor_home_spotlight';
}
