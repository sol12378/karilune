import 'package:carilune/models/ad.dart';
import 'package:carilune/models/carousel_viewport_config.dart';
import 'package:carilune/models/featured_placement.dart';
import 'package:carilune/services/featured_carousel_resolver.dart';
import 'package:carilune/widgets/featured/carousel_layout_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarouselLayoutEngine', () {
    const engine = CarouselLayoutEngine();

    test('index 0 and 1 have distinct centering offsets', () {
      const viewportWidth = 1200.0;
      final layout = engine.compute(viewportWidth);

      final offset0 =
          layout.scrollOffsetForFocusIndex(0, itemCount: 5);
      final offset1 =
          layout.scrollOffsetForFocusIndex(1, itemCount: 5);

      expect(offset0, 0);
      expect(offset1, layout.itemStride);
      expect(offset1, greaterThan(offset0));
    });

    test('focus index resolves correctly at first two positions', () {
      const viewportWidth = 1200.0;
      final layout = engine.compute(viewportWidth);

      expect(
        layout.focusIndexForScrollOffset(0, itemCount: 5),
        0,
      );
      expect(
        layout.focusIndexForScrollOffset(
          layout.itemStride * 0.4,
          itemCount: 5,
        ),
        0,
      );
      expect(
        layout.focusIndexForScrollOffset(
          layout.itemStride * 0.6,
          itemCount: 5,
        ),
        1,
      );
      expect(
        layout.focusIndexForScrollOffset(
          layout.itemStride,
          itemCount: 5,
        ),
        1,
      );
    });

    test('last index can scroll to center', () {
      const viewportWidth = 1200.0;
      const itemCount = 5;
      final layout = engine.compute(viewportWidth);
      final lastOffset = layout.scrollOffsetForFocusIndex(
        itemCount - 1,
        itemCount: itemCount,
      );

      expect(
        layout.focusIndexForScrollOffset(lastOffset, itemCount: itemCount),
        itemCount - 1,
      );
    });

    test('visible column count changes item width', () {
      const wideEngine = CarouselLayoutEngine();
      const narrowEngine = CarouselLayoutEngine(
        config: CarouselViewportConfig(visibleColumnCount: 5),
      );

      final wide = wideEngine.compute(1200);
      final narrow = narrowEngine.compute(1200);

      expect(narrow.itemWidth, lessThan(wide.itemWidth));
    });

    test('three slot layout peeks neighbors at center focus', () {
      const engine = CarouselLayoutEngine(
        config: CarouselViewportConfig(visibleColumnCount: 3),
      );
      final layout = engine.compute(1200);
      const itemCount = 8;
      const centerIndex = 4;
      final offset = layout.scrollOffsetForFocusIndex(
        centerIndex,
        itemCount: itemCount,
      );

      expect(layout.itemWidth, greaterThan(260));
      expect(
        layout.focusIndexForScrollOffset(offset, itemCount: itemCount),
        centerIndex,
      );
    });

    test('initial focus index is centered in the list', () {
      expect(CarouselLayoutMetrics.initialFocusIndex(8), 4);
      expect(CarouselLayoutMetrics.initialFocusIndex(5), 2);
      expect(CarouselLayoutMetrics.initialFocusIndex(1), 0);
    });
  });

  group('FeaturedCarouselResolver', () {
    final catalog = [
      Ad(
        id: 'a',
        companyName: 'A',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '飲食店',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
      ),
      Ad(
        id: 'b',
        companyName: 'B',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '生活雑貨',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
      ),
      Ad(
        id: 'c',
        companyName: 'C',
        catchCopy: 'copy',
        prText: 'pr',
        thumbnailAssetPath: 'assets/images/placeholder_ad_01.png',
        category: '生活雑貨',
        startDate: DateTime(2026, 1, 1),
        distributionDays: 10,
      ),
    ];

    test('returns ads in sort order and skips missing ids', () {
      final placements = [
        const FeaturedPlacement(
          id: '1',
          placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
          adId: 'c',
          sortOrder: 2,
        ),
        const FeaturedPlacement(
          id: '2',
          placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
          adId: 'missing',
          sortOrder: 0,
        ),
        const FeaturedPlacement(
          id: '3',
          placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
          adId: 'a',
          sortOrder: 1,
        ),
      ];

      final result = FeaturedCarouselResolver.resolve(
        placements: placements,
        catalog: catalog,
      );

      expect(result.map((ad) => ad.id).toList(), ['a', 'c']);
    });

    test('respects limit', () {
      final placements = [
        for (var i = 0; i < 3; i++)
          FeaturedPlacement(
            id: '$i',
            placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
            adId: catalog[i].id,
            sortOrder: i,
          ),
      ];

      final result = FeaturedCarouselResolver.resolve(
        placements: placements,
        catalog: catalog,
        limit: 2,
      );

      expect(result, hasLength(2));
    });
  });
}
