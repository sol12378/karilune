import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';

class DistributorHistoryPage extends ConsumerWidget {
  const DistributorHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(distributorHistoryAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedNav = navIndexForLocation(distributorNavItems, location);

    return AdminShell(
      currentLocation: location,
      navItems: distributorNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(distributorNavItems[index].location),
      title: '過去履歴',
      child: ads.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: '配信履歴はありません',
              description: '過去に配信した広告がここに表示されます。',
            )
          : AdGridView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return AdCardDistributor(
                  ad: ad,
                  onTap: () => context.push('/ads/${ad.id}?from=distributor'),
                );
              },
            ),
    );
  }
}
