import '../models/featured_placement.dart';

/// 注目カルーセル掲載の初期データ（DB シード相当）。
///
/// 任意件数・任意順序で adId を指定できる。
final initialFeaturedPlacements = <FeaturedPlacement>[
  const FeaturedPlacement(
    id: 'fp-member-01',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-003',
    sortOrder: 0,
  ),
  const FeaturedPlacement(
    id: 'fp-member-02',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-001',
    sortOrder: 1,
  ),
  const FeaturedPlacement(
    id: 'fp-member-03',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-007',
    sortOrder: 2,
  ),
  const FeaturedPlacement(
    id: 'fp-member-04',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-005',
    sortOrder: 3,
  ),
  const FeaturedPlacement(
    id: 'fp-member-05',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-010',
    sortOrder: 4,
  ),
  const FeaturedPlacement(
    id: 'fp-member-06',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-012',
    sortOrder: 5,
  ),
  const FeaturedPlacement(
    id: 'fp-member-07',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-013',
    sortOrder: 6,
  ),
  const FeaturedPlacement(
    id: 'fp-member-08',
    placementKey: FeaturedPlacementKeys.memberHomeSpotlight,
    adId: 'ad-014',
    sortOrder: 7,
  ),
  const FeaturedPlacement(
    id: 'fp-distributor-01',
    placementKey: FeaturedPlacementKeys.distributorHomeSpotlight,
    adId: 'ad-003',
    sortOrder: 0,
  ),
  const FeaturedPlacement(
    id: 'fp-distributor-02',
    placementKey: FeaturedPlacementKeys.distributorHomeSpotlight,
    adId: 'ad-007',
    sortOrder: 1,
  ),
  const FeaturedPlacement(
    id: 'fp-distributor-03',
    placementKey: FeaturedPlacementKeys.distributorHomeSpotlight,
    adId: 'ad-006',
    sortOrder: 2,
  ),
];
