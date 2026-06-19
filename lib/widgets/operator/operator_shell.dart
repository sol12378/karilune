import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import '../app_shell.dart';
import 'operator_menu_bar.dart';
import 'operator_mode.dart';

/// オペレーター（配信/投稿）向け Shell。§3.2 ヘッダー（モード切替）準拠。
class OperatorShell extends StatelessWidget {
  const OperatorShell({
    super.key,
    required this.child,
    required this.currentLocation,
    required this.mode,
    this.navItems = const [],
    this.showMenuBar = true,
    this.title,
  });

  final Widget child;
  final String currentLocation;
  final OperatorMode mode;
  final List<AppNavItem> navItems;
  final bool showMenuBar;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () => context.go('/admin/dashboard'),
              onLongPress: () => context.go('/member/home'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  if (title != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              _ModeToggle(
                mode: mode,
                compact: constraints.maxWidth < Breakpoints.mobile,
              ),
              IconButton(
                tooltip: '通知',
                onPressed: () => context.push(mode.notificationsRoute),
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                tooltip: 'アカウント',
                onPressed: () => context.push(mode.accountRoute),
                icon: const Icon(Icons.account_circle_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showMenuBar && navItems.isNotEmpty)
                OperatorMenuBar(
                  items: navItems,
                  currentLocation: currentLocation,
                  onTap: (location) => context.go(location),
                ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.compact,
  });

  final OperatorMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SegmentedButton<OperatorMode>(
        segments: [
          ButtonSegment(
            value: OperatorMode.advertiser,
            label: Text(compact ? '投稿' : '広告投稿'),
            icon: const Icon(Icons.post_add_outlined, size: 18),
          ),
          ButtonSegment(
            value: OperatorMode.distributor,
            label: Text(compact ? '配信' : '広告配信'),
            icon: const Icon(Icons.campaign_outlined, size: 18),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selected) {
          final next = selected.first;
          if (next != mode) {
            context.go(next.homeRoute);
          }
        },
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
