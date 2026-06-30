import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/ad_card_distributor_visual.dart';
import '../../widgets/distributor_visual_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';
import 'distributor_actions.dart';

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
          : LayoutBuilder(
              builder: (context, constraints) {
                return DistributorVisualGridView.builder(
                  width: constraints.maxWidth,
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return AdCardDistributorVisual(
                      ad: ad,
                      onTap: () =>
                          context.push('/ads/${ad.id}?from=distributor'),
                      onToggleDistribute: ad.isEnded
                          ? null
                          : () => confirmToggleDistributing(
                                context,
                                ref,
                                ad,
                              ),
                    );
                  },
                );
              },
            ),
    );
  }
}
