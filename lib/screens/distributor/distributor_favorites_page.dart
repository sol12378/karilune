import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class DistributorFavoritesPage extends ConsumerWidget {
  const DistributorFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final ads = ref
        .watch(filteredAdsProvider)
        .where((ad) => favoriteIds.contains(ad.id))
        .toList();
    final location = GoRouterState.of(context).matchedLocation;

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.distributor,
      navItems: distributorNavItems,
      child: ads.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'お気に入りはまだありません',
              description: '配信候補の広告をお気に入りに追加できます。',
            )
          : AdGridView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return AdCardDistributor(
                  ad: ad,
                  onTap: () => context.push('/ads/${ad.id}?from=distributor'),
                  onToggleDistribute: () => ref
                      .read(adRepositoryProvider.notifier)
                      .toggleDistributing(ad.id),
                );
              },
            ),
    );
  }
}
