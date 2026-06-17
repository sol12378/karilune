import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/app_shell.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({
    super.key,
    required this.accountProvider,
    required this.navItems,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.useAdminShell = false,
    this.shellTitle = 'アカウント',
  });

  final StateNotifierProvider<AccountNotifier, Account> accountProvider;
  final List<AppNavItem> navItems;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool useAdminShell;
  final String shellTitle;

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

    final form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              account.companyName.isNotEmpty
                  ? account.companyName.characters.first
                  : '?',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _companyName,
            decoration: const InputDecoration(
              labelText: '会社名 / お名前',
              border: OutlineInputBorder(),
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
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tel,
            decoration: const InputDecoration(
              labelText: '電話番号',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactName,
            decoration: const InputDecoration(
              labelText: '担当者名',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
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
                  const SnackBar(content: Text('プロフィールを保存しました')),
                );
              }
            },
            child: const Text('保存する'),
          ),
        ],
      ),
    );

    if (widget.useAdminShell) {
      return AdminShell(
        currentLocation: GoRouterState.of(context).matchedLocation,
        navItems: widget.navItems,
        selectedNavIndex: widget.selectedNavIndex,
        onNavTap: widget.onNavTap,
        title: widget.shellTitle,
        child: form,
      );
    }

    return AppShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      navItems: widget.navItems,
      selectedNavIndex: widget.selectedNavIndex,
      onNavTap: widget.onNavTap,
      child: form,
    );
  }
}
