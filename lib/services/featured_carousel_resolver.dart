import '../models/ad.dart';
import '../models/featured_placement.dart';

/// [FeaturedPlacement] と広告カタログを結合し、表示順の広告リストを生成する。
class FeaturedCarouselResolver {
  const FeaturedCarouselResolver._();

  static List<Ad> resolve({
    required List<FeaturedPlacement> placements,
    required List<Ad> catalog,
    int? limit,
  }) {
    final adsById = {for (final ad in catalog) ad.id: ad};
    final sorted = placements.where((p) => p.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final result = <Ad>[];
    for (final placement in sorted) {
      final ad = adsById[placement.adId];
      if (ad == null) continue;
      result.add(ad);
      if (limit != null && result.length >= limit) break;
    }
    return result;
  }
}
