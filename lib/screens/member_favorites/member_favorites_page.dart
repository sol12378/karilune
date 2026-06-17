import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/ad_card_consumer.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';

class MemberFavoritesPage extends ConsumerWidget {
  const MemberFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final memberAds = ref.watch(memberAdsProvider);
    final favorites =
        memberAds.where((ad) => favoriteIds.contains(ad.id)).toList();

    final selectedNav = navIndexForLocation(
      memberNavItems,
      GoRouterState.of(context).matchedLocation,
    );

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: memberNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(memberNavItems[index].location),
      child: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'お気に入りはまだありません',
              description: '気になる広告をお気に入りに追加できます。',
            )
          : AdGridView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final ad = favorites[index];
                return AdCardConsumer(
                  ad: ad,
                  onTap: () => context.push('/ads/${ad.id}?from=member'),
                );
              },
            ),
    );
  }
}
