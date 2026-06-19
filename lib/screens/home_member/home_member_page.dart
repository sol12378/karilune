import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/ad_card_consumer.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/ad_grid_skeleton.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/demo_async_wrapper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/member/member_home_layout.dart';
import '../../widgets/member_filter_bar.dart';

class HomeMemberPage extends ConsumerWidget {
  const HomeMemberPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              MemberHomeLayout(
                buildMain: (width) => DemoAsyncWrapper(
                  cacheKey: 'member-home-grid',
                  loading: AdGridSkeleton(
                    crossAxisCount: width >= Breakpoints.desktop ? 3 : 2,
                  ),
                  builder: () => MemberAdsGrid(
                    width: width,
                    bottomPadding: showFilterBar ? 80 : 24,
                  ),
                ),
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

class MemberAdsGrid extends ConsumerWidget {
  const MemberAdsGrid({
    super.key,
    required this.width,
    required this.bottomPadding,
  });

  final double width;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(memberAdsProvider);

    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: EmptyState(
          icon: Icons.campaign_outlined,
          title: '現在配信中の広告はありません',
          description: 'カテゴリや地域の条件を変更してみてください。',
        ),
      );
    }

    return AdGridView.builder(
      width: width,
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return RepaintBoundary(
          key: ValueKey(ad.id),
          child: AdCardConsumer(
            ad: ad,
            onTap: () => context.push('/ads/${ad.id}?from=member'),
          ),
        );
      },
    );
  }
}
