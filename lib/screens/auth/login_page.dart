import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/notification.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'カリルネ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'デモ用ログイン（本番DBなし）',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 32),
              _RoleLoginCard(
                icon: Icons.person_outline,
                title: '会員としてログイン',
                subtitle: '山田 太郎 — 広告閲覧・お気に入り',
                onTap: () => _login(context, ref, AppRole.member),
              ),
              const SizedBox(height: 12),
              _RoleLoginCard(
                icon: Icons.broadcast_on_personal_outlined,
                title: '配信者としてログイン',
                subtitle: '○○ガス 名古屋支店 — 広告配信・実績確認',
                onTap: () => _login(context, ref, AppRole.distributor),
              ),
              const SizedBox(height: 12),
              _RoleLoginCard(
                icon: Icons.post_add_outlined,
                title: '投稿者としてログイン',
                subtitle: '○○ガス 広告部 — 広告投稿・効果測定',
                onTap: () => _login(context, ref, AppRole.advertiser),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(
    BuildContext context,
    WidgetRef ref,
    AppRole role,
  ) async {
    await ref.read(authProvider.notifier).login(role);
    if (context.mounted) {
      context.go(ref.read(authProvider).homeRoute);
    }
  }
}

class _RoleLoginCard extends StatelessWidget {
  const _RoleLoginCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
