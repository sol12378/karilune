import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/breakpoints.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ideal/consumer/consumer_feed_layout.dart';
import '../../widgets/ideal/consumer/member_content_frame.dart';
import '../../widgets/ideal/consumer/member_desktop_home.dart';

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
          final isDesktop = constraints.maxWidth >= Breakpoints.desktop;

          if (isDesktop) {
            return const MemberDesktopHome();
          }

          return const MemberContentFrame(
            style: MemberFrameStyle.mobileFeed,
            child: ConsumerFeedLayout(),
          );
        },
      ),
    );
  }
}
