import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class DistributorHistoryPage extends ConsumerWidget {
  const DistributorHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(distributorHistoryAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;

    return OperatorShell(
      currentLocation: location,
      mode: OperatorMode.distributor,
      navItems: distributorNavItems,
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
                  onToggleDistribute: () async {
                    if (!ad.isDistributing && !ad.isEnded) {
                      ref
                          .read(adRepositoryProvider.notifier)
                          .toggleDistributing(ad.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('「${ad.companyName}」を再配信しました'),
                        ),
                      );
                    }
                  },
                  distributeLabel: ad.isDistributing ? '配信中' : '再配信',
                );
              },
            ),
    );
  }
}
