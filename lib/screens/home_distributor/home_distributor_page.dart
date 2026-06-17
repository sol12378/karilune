import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_distributor.dart';
import '../../widgets/ad_filter_section.dart';
import '../../widgets/ad_grid.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/spotlight_banner.dart';

Future<void> confirmToggleDistributing(
  BuildContext context,
  WidgetRef ref,
  Ad ad,
) async {
  final isStop = ad.isDistributing;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isStop ? '配信停止の確認' : '配信開始の確認'),
      content: Text(
        isStop
            ? '「${ad.companyName}」の配信を停止しますか？'
            : '「${ad.companyName}」を配信しますか？',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(isStop ? '停止する' : '配信する'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    ref.read(adRepositoryProvider.notifier).toggleDistributing(ad.id);
  }
}

class HomeDistributorPage extends ConsumerWidget {
  const HomeDistributorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(filteredAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedNav = navIndexForLocation(distributorNavItems, location);

    return AdminShell(
      currentLocation: location,
      navItems: distributorNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(distributorNavItems[index].location),
      title: '広告配信',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SpotlightBanner(
                  linkFrom: 'distributor',
                  useMemberAds: false,
                ),
              ),
              const SliverToBoxAdapter(
                child: AdFilterSection(showSort: false),
              ),
              if (ads.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_outlined,
                    title: '該当する広告はありません',
                    description: 'カテゴリや地域の条件を変更してみてください。',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: AdGridSliver(
                    width: constraints.maxWidth,
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return AdCardDistributor(
                        ad: ad,
                        onTap: () => context.push(
                          '/ads/${ad.id}?from=distributor',
                        ),
                        onToggleDistribute: () =>
                            confirmToggleDistributing(context, ref, ad),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
