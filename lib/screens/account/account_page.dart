import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/account.dart';
import '../../models/notification.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/operator/operator_mode.dart';
import '../../widgets/operator/operator_shell.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({
    super.key,
    required this.accountProvider,
    required this.navItems,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.useAdminShell = false,
    this.useOperatorShell = false,
    this.shellTitle = 'アカウント',
    this.showAdminLink = false,
  });

  final StateNotifierProvider<AccountNotifier, Account> accountProvider;
  final List<AppNavItem> navItems;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool useAdminShell;
  final bool useOperatorShell;
  final String shellTitle;
  final bool showAdminLink;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyName;
  late TextEditingController _companyUrl;
  late TextEditingController _tel;
  late TextEditingController _contactName;
  var _initialized = false;

  void _ensureControllers(Account account) {
    if (_initialized) return;
    _companyName = TextEditingController(text: account.companyName);
    _companyUrl = TextEditingController(text: account.companyUrl);
    _tel = TextEditingController(text: account.tel);
    _contactName = TextEditingController(text: account.contactName);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _companyName.dispose();
      _companyUrl.dispose();
      _tel.dispose();
      _contactName.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(widget.accountProvider);
    _ensureControllers(account);

    final formCard = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      child: Text(
                        account.companyName.isNotEmpty
                            ? account.companyName.characters.first
                            : '?',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _companyName,
                    decoration: const InputDecoration(
                      labelText: '会社名 / お名前',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '必須項目です' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _companyUrl,
                    decoration: const InputDecoration(
                      labelText: 'Webサイト',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tel,
                    decoration: const InputDecoration(
                      labelText: '電話番号',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactName,
                    decoration: const InputDecoration(
                      labelText: '担当者名',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref.read(widget.accountProvider.notifier).update(
                              Account(
                                companyName: _companyName.text.trim(),
                                companyUrl: _companyUrl.text.trim(),
                                tel: _tel.text.trim(),
                                contactName: _contactName.text.trim(),
                              ),
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('プロフィールを保存しました'),
                            ),
                          );
                        }
                      },
                      child: const Text('保存する'),
                    ),
                  ),
                  if (widget.showAdminLink) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('広告管理ダッシュボード'),
                      subtitle: const Text('注目広告の掲載管理・全体統計'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/admin/dashboard'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  Text(
                    'デモ用ロール切替',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  for (final role in AppRole.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_roleIcon(role)),
                      title: Text(_roleLabel(role)),
                      trailing: ref.watch(authProvider).role == role
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () async {
                        await ref.read(authProvider.notifier).switchRole(role);
                        if (context.mounted) {
                          context.go(ref.read(authProvider).homeRoute);
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('ログアウト'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final body = SingleChildScrollView(
      child: formCard,
    );

    if (widget.useOperatorShell) {
      final location = GoRouterState.of(context).matchedLocation;
      return OperatorShell(
        currentLocation: location,
        mode: OperatorModeX.fromLocation(location),
        navItems: widget.navItems,
        title: widget.shellTitle,
        child: body,
      );
    }

    if (widget.useAdminShell) {
      return AdminShell(
        currentLocation: GoRouterState.of(context).matchedLocation,
        navItems: widget.navItems,
        selectedNavIndex: widget.selectedNavIndex,
        onNavTap: widget.onNavTap,
        title: widget.shellTitle,
        child: body,
      );
    }

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: widget.navItems,
      selectedNavIndex: widget.selectedNavIndex,
      onNavTap: widget.onNavTap,
      child: body,
    );
  }

  IconData _roleIcon(AppRole role) {
    switch (role) {
      case AppRole.member:
        return Icons.person_outline;
      case AppRole.distributor:
        return Icons.broadcast_on_personal_outlined;
      case AppRole.advertiser:
        return Icons.post_add_outlined;
    }
  }

  String _roleLabel(AppRole role) {
    switch (role) {
      case AppRole.member:
        return '会員として見る';
      case AppRole.distributor:
        return '配信者として操作';
      case AppRole.advertiser:
        return '投稿者として操作';
    }
  }
}
