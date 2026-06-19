import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';

/// 会員向け AppShell。モード切替なし（[ScreenRoleConfig] 参照）。
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
    required this.navItems,
    required this.selectedNavIndex,
    required this.onNavTap,
  });

  final Widget child;
  final String currentLocation;
  final List<AppNavItem> navItems;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = Responsive.useNavigationRail(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.campaign_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'カリルネ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: '通知',
                onPressed: () => context.push('/member/notifications'),
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                tooltip: 'アカウント',
                onPressed: () => context.push('/member/account'),
                icon: const Icon(Icons.account_circle_outlined),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: selectedNavIndex,
                  onDestinationSelected: onNavTap,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: selectedNavIndex,
                  onDestinationSelected: onNavTap,
                  destinations: [
                    for (final item in navItems)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final String location;
}

int navIndexForLocation(List<AppNavItem> items, String location) {
  final index = items.indexWhere((item) => location.startsWith(item.location));
  return index == -1 ? 0 : index;
}

final memberNavItems = <AppNavItem>[
  const AppNavItem(
    label: 'ホーム',
    icon: Icons.home_outlined,
    location: '/member/home',
  ),
  const AppNavItem(
    label: 'お気に入り',
    icon: Icons.favorite_outline,
    location: '/member/favorites',
  ),
];

final distributorNavItems = <AppNavItem>[
  const AppNavItem(
    label: 'ホーム',
    icon: Icons.home_outlined,
    location: '/distributor/home',
  ),
  const AppNavItem(
    label: 'お気に入り',
    icon: Icons.favorite_outline,
    location: '/distributor/favorites',
  ),
  const AppNavItem(
    label: 'クラブ',
    icon: Icons.groups_outlined,
    location: '/distributor/club-team',
  ),
  const AppNavItem(
    label: '履歴',
    icon: Icons.history,
    location: '/distributor/history',
  ),
];

final advertiserNavItems = <AppNavItem>[
  const AppNavItem(
    label: 'ホーム',
    icon: Icons.home_outlined,
    location: '/advertiser/home',
  ),
  const AppNavItem(
    label: '履歴',
    icon: Icons.history,
    location: '/advertiser/history',
  ),
];
