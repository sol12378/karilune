import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_distributor_visual.dart';
import '../../widgets/distributor_visual_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';
import 'distributor_actions.dart';

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
          : LayoutBuilder(
              builder: (context, constraints) {
                return DistributorVisualGridView.builder(
                  width: constraints.maxWidth,
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    final canRedistribute = !ad.isEnded;
                    return AdCardDistributorVisual(
                      ad: ad,
                      onTap: () =>
                          context.push('/ads/${ad.id}?from=distributor'),
                      onToggleDistribute: canRedistribute
                          ? () => confirmToggleDistributing(
                                context,
                                ref,
                                ad,
                              )
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}
