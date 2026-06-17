import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stats_row.dart';
import '../advertiser/advertiser_history_page.dart';

class HomeAdvertiserPage extends ConsumerStatefulWidget {
  const HomeAdvertiserPage({super.key});

  @override
  ConsumerState<HomeAdvertiserPage> createState() =>
      _HomeAdvertiserPageState();
}

class _HomeAdvertiserPageState extends ConsumerState<HomeAdvertiserPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(advertiserAdsProvider);
    final activeAds = ref.watch(activeAdvertiserAdsProvider);
    final historyAds = ref.watch(endedAdvertiserAdsProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedNav = navIndexForLocation(advertiserNavItems, location);

    final distributorCount =
        ads.fold<int>(0, (sum, ad) => sum + ad.distributorCount);
    final viewCount = ads.fold<int>(0, (sum, ad) => sum + ad.viewCount);

    return AdminShell(
      currentLocation: location,
      navItems: advertiserNavItems,
      selectedNavIndex: selectedNav,
      onNavTap: (index) => context.go(advertiserNavItems[index].location),
      title: '広告投稿',
      child: Stack(
        children: [
          Column(
            children: [
              StatsRow(
                adCount: ads.length,
                distributorCount: distributorCount,
                viewCount: viewCount,
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'ホーム'),
                  Tab(text: '過去履歴'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AdList(
                      ads: activeAds,
                      emptyMessage: '配信中・予定の広告はありません',
                    ),
                    _AdList(
                      ads: historyAds,
                      emptyMessage: '過去の広告はありません',
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => context.push('/advertiser/ads/new'),
              icon: const Icon(Icons.add),
              label: const Text('新規作成'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdList extends StatelessWidget {
  const _AdList({
    required this.ads,
    required this.emptyMessage,
  });

  final List<Ad> ads;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (ads.isEmpty) {
      return EmptyState(
        icon: Icons.campaign_outlined,
        title: emptyMessage,
      );
    }

    return AdvertiserAdGrid(ads: ads);
  }
}
