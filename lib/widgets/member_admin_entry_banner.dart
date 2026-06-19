import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// デモ用: 会員ホーム下部のコンパクトな管理導線。
/// 本番ではガス事業者の管理画面へ別途遷移する想定（仕様書 §3.2 外）。
class MemberDemoAdminLink extends StatelessWidget {
  const MemberDemoAdminLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Center(
        child: TextButton.icon(
          onPressed: () => context.go('/admin/dashboard'),
          icon: Icon(
            Icons.admin_panel_settings_outlined,
            size: 16,
            color: Colors.grey.shade500,
          ),
          label: Text(
            '広告管理（デモ用）',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

/// @deprecated 会員ホーム上部の大バナー。 [MemberDemoAdminLink] に置き換え済み。
@Deprecated('Use MemberDemoAdminLink in footer or account page')
class MemberAdminEntryBanner extends StatelessWidget {
  const MemberAdminEntryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        color: AppColors.primary.withValues(alpha: 0.06),
        child: InkWell(
          onTap: () => context.go('/admin/dashboard'),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: MemberDemoAdminLinkContent(),
          ),
        ),
      ),
    );
  }
}

class MemberDemoAdminLinkContent extends StatelessWidget {
  const MemberDemoAdminLinkContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.admin_panel_settings_outlined,
            color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '広告の配信・投稿を管理する',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '広告管理ダッシュボードへ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
      ],
    );
  }
}
