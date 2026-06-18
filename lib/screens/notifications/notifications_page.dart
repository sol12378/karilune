import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../mock_data/notifications_mock.dart';
import '../../models/notification.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class NotificationsPage extends ConsumerStatefulWidget {
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
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late List<AppNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = notificationsForRole(widget.role);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    final body = _items.isEmpty
        ? const EmptyState(
            icon: Icons.notifications_none_outlined,
            title: '通知はありません',
            description: '新しいお知らせが届くとここに表示されます。',
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _items[index];
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
                  onTap: () {
                    setState(() {
                      _items[index] = AppNotification(
                        id: item.id,
                        title: item.title,
                        body: item.body,
                        createdAt: item.createdAt,
                        isRead: true,
                      );
                    });
                  },
                ),
              );
            },
          );

    if (widget.useOperatorShell) {
      final location = GoRouterState.of(context).matchedLocation;
      return OperatorShell(
        currentLocation: location,
        mode: OperatorModeX.fromLocation(location),
        navItems: widget.navItems,
        title: widget.shellTitle ?? '通知',
        child: body,
      );
    }

    if (widget.useAdminShell) {
      return AdminShell(
        currentLocation: GoRouterState.of(context).matchedLocation,
        navItems: widget.navItems,
        selectedNavIndex: widget.selectedNavIndex,
        onNavTap: widget.onNavTap,
        title: widget.shellTitle ?? '通知',
        child: body,
      );
    }

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: widget.navItems,
      selectedNavIndex: widget.selectedNavIndex,
      onNavTap: widget.onNavTap!,
      child: body,
    );
  }
}
