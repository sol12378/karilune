import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/notification_repository.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/ideal/consumer/member_content_frame.dart';
import '../../widgets/ideal/consumer/notification_tile.dart';
import '../../widgets/ideal/ideal_theme.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({
    super.key,
    required this.role,
    required this.homeRoute,
    this.navItems = const [],
    this.selectedNavIndex = 0,
    this.onNavTap,
    this.useAdminShell = false,
    this.useOperatorShell = false,
    this.shellTitle,
  });

  final String role;
  final String homeRoute;
  final List<AppNavItem> navItems;
  final int selectedNavIndex;
  final ValueChanged<int>? onNavTap;
  final bool useAdminShell;
  final bool useOperatorShell;
  final String? shellTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(roleNotificationsProvider(role));
    final dateFormat = DateFormat('MM/dd HH:mm');
    final notifier = ref.read(notificationRepositoryProvider.notifier);

    final body = items.isEmpty
        ? const EmptyState(
            icon: Icons.notifications_none_outlined,
            title: '通知はありません',
            description: '新しいお知らせが届くとここに表示されます。',
          )
        : ListView.separated(
            padding: EdgeInsets.all(
              role == 'member' ? IdealSpacing.feedPadding : 16,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(
              height: role == 'member' ? IdealSpacing.sm : 8,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              if (role == 'member') {
                return NotificationTile(
                  title: item.title,
                  body: item.body,
                  timeLabel: dateFormat.format(item.createdAt),
                  isRead: item.isRead,
                  showChevron: item.targetRoute != null,
                  onTap: () {
                    notifier.markRead(item.id);
                    if (item.targetRoute != null) {
                      final route = item.targetRoute!;
                      if (route.startsWith('/ads/')) {
                        context.push(route);
                      } else {
                        context.go(route);
                      }
                    }
                  },
                );
              }
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isRead
                        ? Colors.grey.shade200
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      item.isRead
                          ? Icons.notifications_outlined
                          : Icons.notifications_active_outlined,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight:
                          item.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.body),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(item.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: item.targetRoute != null
                      ? const Icon(Icons.chevron_right)
                      : null,
                  onTap: () {
                    notifier.markRead(item.id);
                    if (item.targetRoute != null) {
                      final route = item.targetRoute!;
                      if (route.startsWith('/ads/')) {
                        context.push(route);
                      } else {
                        context.go(route);
                      }
                    }
                  },
                ),
              );
            },
          );

    final content = role == 'member'
        ? MemberContentFrame(
            style: MemberFrameStyle.mobileFeed,
            child: body,
          )
        : body;

    if (useOperatorShell) {
      final location = GoRouterState.of(context).matchedLocation;
      return OperatorShell(
        currentLocation: location,
        mode: OperatorModeX.fromLocation(location),
        navItems: navItems,
        title: shellTitle ?? '通知',
        child: body,
      );
    }

    if (useAdminShell) {
      return AdminShell(
        currentLocation: GoRouterState.of(context).matchedLocation,
        navItems: navItems,
        selectedNavIndex: selectedNavIndex,
        onNavTap: onNavTap,
        title: shellTitle ?? '通知',
        child: body,
      );
    }

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: navItems,
      selectedNavIndex: selectedNavIndex,
      onNavTap: onNavTap!,
      child: content,
    );
  }
}
