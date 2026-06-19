import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/ad_repository.dart';
import 'providers/ad_form_provider.dart';
import 'providers/account_provider.dart';
import 'screens/account/account_page.dart';
import 'screens/ad_detail/ad_detail_page.dart';
import 'screens/ad_post/ad_post_page.dart';
import 'screens/admin/admin_dashboard_page.dart';
import 'screens/advertiser/advertiser_history_page.dart';
import 'screens/distributor/club_team_page.dart';
import 'screens/distributor/distributor_favorites_page.dart';
import 'screens/distributor/distributor_history_page.dart';
import 'screens/home_advertiser/home_advertiser_page.dart';
import 'screens/home_distributor/home_distributor_page.dart';
import 'screens/home_member/home_member_page.dart';
import 'screens/member_favorites/member_favorites_page.dart';
import 'screens/notifications/notifications_page.dart';
import 'widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/member/home',
  routes: [
    GoRoute(
      path: '/member/home',
      builder: (context, state) => const HomeMemberPage(),
    ),
    GoRoute(
      path: '/member/favorites',
      builder: (context, state) => const MemberFavoritesPage(),
    ),
    GoRoute(
      path: '/member/notifications',
      builder: (context, state) => NotificationsPage(
        role: 'member',
        homeRoute: '/member/home',
        navItems: memberNavItems,
        selectedNavIndex:
            navIndexForLocation(memberNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(memberNavItems[index].location),
      ),
    ),
    GoRoute(
      path: '/member/account',
      builder: (context, state) => AccountPage(
        accountProvider: memberAccountProvider,
        navItems: memberNavItems,
        selectedNavIndex:
            navIndexForLocation(memberNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(memberNavItems[index].location),
        showDemoAdminLink: true,
      ),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/distributor/home',
      builder: (context, state) => const HomeDistributorPage(),
    ),
    GoRoute(
      path: '/distributor/favorites',
      builder: (context, state) => const DistributorFavoritesPage(),
    ),
    GoRoute(
      path: '/distributor/club-team',
      builder: (context, state) => const ClubTeamPage(),
    ),
    GoRoute(
      path: '/distributor/history',
      builder: (context, state) => const DistributorHistoryPage(),
    ),
    GoRoute(
      path: '/distributor/notifications',
      builder: (context, state) => NotificationsPage(
        role: 'distributor',
        homeRoute: '/distributor/home',
        useOperatorShell: true,
        shellTitle: '通知',
        navItems: distributorNavItems,
        selectedNavIndex:
            navIndexForLocation(distributorNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(distributorNavItems[index].location),
      ),
    ),
    GoRoute(
      path: '/distributor/account',
      builder: (context, state) => AccountPage(
        accountProvider: distributorAccountProvider,
        useOperatorShell: true,
        shellTitle: 'アカウント',
        navItems: distributorNavItems,
        selectedNavIndex:
            navIndexForLocation(distributorNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(distributorNavItems[index].location),
      ),
    ),
    GoRoute(
      path: '/advertiser/home',
      builder: (context, state) => const HomeAdvertiserPage(),
    ),
    GoRoute(
      path: '/advertiser/history',
      builder: (context, state) => const AdvertiserHistoryPage(),
    ),
    GoRoute(
      path: '/advertiser/notifications',
      builder: (context, state) => NotificationsPage(
        role: 'advertiser',
        homeRoute: '/advertiser/home',
        useOperatorShell: true,
        shellTitle: '通知',
        navItems: advertiserNavItems,
        selectedNavIndex:
            navIndexForLocation(advertiserNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(advertiserNavItems[index].location),
      ),
    ),
    GoRoute(
      path: '/advertiser/account',
      builder: (context, state) => AccountPage(
        accountProvider: advertiserAccountProvider,
        useOperatorShell: true,
        shellTitle: 'アカウント',
        navItems: advertiserNavItems,
        selectedNavIndex:
            navIndexForLocation(advertiserNavItems, state.matchedLocation),
        onNavTap: (index) => context.go(advertiserNavItems[index].location),
      ),
    ),
    GoRoute(
      path: '/ads/:id',
      builder: (context, state) {
        final adId = state.pathParameters['id']!;
        return AdDetailPage(
          adId: adId,
          fromMode: state.uri.queryParameters['from'],
        );
      },
    ),
    GoRoute(
      path: '/advertiser/ads/new',
      builder: (context, state) {
        return const _AdPostRouteWrapper(isEdit: false);
      },
    ),
    GoRoute(
      path: '/advertiser/ads/:id/edit',
      builder: (context, state) {
        final adId = state.pathParameters['id']!;
        return _AdPostRouteWrapper(isEdit: true, adId: adId);
      },
    ),
  ],
);

class _AdPostRouteWrapper extends ConsumerStatefulWidget {
  const _AdPostRouteWrapper({required this.isEdit, this.adId});

  final bool isEdit;
  final String? adId;

  @override
  ConsumerState<_AdPostRouteWrapper> createState() =>
      _AdPostRouteWrapperState();
}

class _AdPostRouteWrapperState extends ConsumerState<_AdPostRouteWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(adFormProvider.notifier);
      if (widget.isEdit && widget.adId != null) {
        final ad = ref.read(adRepositoryProvider.notifier).findById(
              widget.adId!,
            );
        if (ad != null) {
          notifier.startEdit(ad);
        }
      } else {
        notifier.startCreate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdPostPage(adId: widget.adId);
  }
}
