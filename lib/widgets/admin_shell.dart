import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import 'app_shell.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    required this.currentLocation,
    this.navItems = const [],
    this.selectedNavIndex = 0,
    this.onNavTap,
    this.title = '広告管理',
    this.showNavigation = true,
  });

  final Widget child;
  final String currentLocation;
  final List<AppNavItem> navItems;
  final int selectedNavIndex;
  final ValueChanged<int>? onNavTap;
  final String title;
  final bool showNavigation;

  bool get isDashboard => currentLocation.startsWith('/admin/dashboard');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = showNavigation &&
            navItems.isNotEmpty &&
            Responsive.useNavigationRail(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.campaign_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            leading: isDashboard
                ? null
                : IconButton(
                    tooltip: 'ダッシュボードに戻る',
                    icon: const Icon(Icons.dashboard_outlined),
                    onPressed: () => context.go('/admin/dashboard'),
                  ),
            actions: [
              if (!isDashboard)
                TextButton.icon(
                  onPressed: () => context.go('/admin/dashboard'),
                  icon: const Icon(Icons.dashboard_outlined, size: 20),
                  label: const Text('ダッシュボード'),
                ),
              TextButton.icon(
                onPressed: () => context.go('/member/home'),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: const Text('会員サイトへ'),
              ),
              const SizedBox(width: 8),
            ],
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
          bottomNavigationBar: useRail || !showNavigation || navItems.isEmpty
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
