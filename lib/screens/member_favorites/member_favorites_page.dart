import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/ideal/consumer/favorite_ad_card.dart';
import '../../widgets/ideal/consumer/member_content_frame.dart';
import '../../widgets/ideal/ideal_theme.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= Breakpoints.desktop;
          final crossAxisCount = isDesktop ? 4 : 2;
          final frameStyle = isDesktop
              ? MemberFrameStyle.favoritesDesktop
              : MemberFrameStyle.favoritesMobile;

          if (favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'お気に入りはまだありません',
              description: '気になる広告をお気に入りに追加できます。',
            );
          }

          return MemberContentFrame(
            style: frameStyle,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'お気に入り',
                    subtitle: '気になる広告を保存しています（${favorites.length}件）',
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    IdealSpacing.lg,
                    0,
                    IdealSpacing.lg,
                    isDesktop ? 24 : IdealSpacing.bottomNavClearance,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isDesktop ? 0.85 : 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ad = favorites[index];
                        return RepaintBoundary(
                          key: ValueKey(ad.id),
                          child: FavoriteAdCard(ad: ad),
                        );
                      },
                      childCount: favorites.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
