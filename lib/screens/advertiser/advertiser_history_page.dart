import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../providers/operator_stats_provider.dart';
import '../../widgets/ad_card_advertiser.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_home_layout.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class AdvertiserHistoryPage extends ConsumerWidget {
  const AdvertiserHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(endedAdvertiserAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.advertiser,
      navItems: advertiserNavItems,
      child: OperatorHomeLayout(
        showRecommended: false,
        showCategorySidebar: false,
        statsProvider: advertiserPerformanceProvider,
        buildMain: (width) {
          if (ads.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: EmptyState(
                icon: Icons.history,
                title: '過去の広告はありません',
                description: '配信が終了した広告がここに表示されます。',
              ),
            );
          }

          return AdGridView.builder(
            width: width,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return AdCardAdvertiser(
                ad: ad,
                variant: AdCardAdvertiserVariant.history,
                onDetail: () =>
                    context.push('/ads/${ad.id}?from=advertiser'),
              );
            },
          );
        },
      ),
    );
  }
}
