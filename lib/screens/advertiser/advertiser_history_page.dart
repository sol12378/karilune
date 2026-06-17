import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_advertiser.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';

class AdvertiserHistoryPage extends ConsumerWidget {
  const AdvertiserHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(endedAdvertiserAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedNav = navIndexForLocation(advertiserNavItems, location);

    return AdminShell(
      currentLocation: location,
      navItems: advertiserNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(advertiserNavItems[index].location),
      title: '過去履歴',
      child: ads.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: '過去の広告はありません',
              description: '配信が終了した広告がここに表示されます。',
            )
          : AdGridView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return AdCardAdvertiser(
                  ad: ad,
                  onDetail: () =>
                      context.push('/ads/${ad.id}?from=advertiser'),
                  onEdit: () =>
                      context.push('/advertiser/ads/${ad.id}/edit'),
                );
              },
            ),
    );
  }
}

class AdvertiserAdGrid extends ConsumerWidget {
  const AdvertiserAdGrid({
    super.key,
    required this.ads,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 88),
  });

  final List<Ad> ads;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdGridView.builder(
      padding: padding,
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return AdCardAdvertiser(
          ad: ad,
          onDetail: () => context.push('/ads/${ad.id}?from=advertiser'),
          onEdit: () => context.push('/advertiser/ads/${ad.id}/edit'),
        );
      },
    );
  }
}
