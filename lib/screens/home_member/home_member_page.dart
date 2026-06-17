import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/ad_filter_section.dart';
import '../../widgets/ad_card_consumer.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/member_admin_entry_banner.dart';
import '../../widgets/member_filter_bar.dart';
import '../../widgets/spotlight_banner.dart';

class HomeMemberPage extends ConsumerWidget {
  const HomeMemberPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(memberAdsProvider);
    final selectedNav = navIndexForLocation(
      memberNavItems,
      GoRouterState.of(context).matchedLocation,
    );

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: memberNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(memberNavItems[index].location),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showFilterBar = constraints.maxWidth < Breakpoints.mobile;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: MemberAdminEntryBanner(),
                  ),
                  const SliverToBoxAdapter(
                    child: SpotlightBanner(linkFrom: 'member'),
                  ),
                  SliverToBoxAdapter(child: AdFilterSection()),
                  if (ads.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.campaign_outlined,
                        title: '現在配信中の広告はありません',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        showFilterBar ? 80 : 24,
                      ),
                      sliver: AdGridSliver(
                        width: constraints.maxWidth,
                        itemCount: ads.length,
                        itemBuilder: (context, index) {
                          final ad = ads[index];
                          return AdCardConsumer(
                            ad: ad,
                            onTap: () =>
                                context.push('/ads/${ad.id}?from=member'),
                          );
                        },
                      ),
                    ),
                ],
              ),
              if (showFilterBar)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MemberFilterBar(),
                ),
            ],
          );
        },
      ),
    );
  }
}
