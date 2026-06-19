import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/stats_row.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAds = ref.watch(adListProvider);
    final advertiserAds = ref.watch(advertiserAdsProvider);
    final distributingCount =
        allAds.where((ad) => ad.isDistributing && ad.isActive).length;
    final viewCount = allAds.fold<int>(0, (sum, ad) => sum + ad.viewCount);
    final monthlyViews = viewCount;

    final activities = [
      '「名古屋焼肉 炎」が新たに配信開始されました',
      '自社広告「春の安全点検」の参照数が4,000を突破',
      '新規広告が1件投稿されました',
    ];

    return AdminShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      title: '広告管理ダッシュボード',
      showNavigation: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              StatsRow(
                adCount: distributingCount,
                distributorCount: advertiserAds.length,
                viewCount: monthlyViews,
              ),
              const SizedBox(height: 8),
              Text(
                '管理メニュー',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.campaign_outlined,
                title: '広告配信を管理',
                description: '会員へ配信する広告の選択・配信ON/OFF',
                onTap: () => context.go('/distributor/home'),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.star_outline,
                title: '注目広告の掲載管理',
                description: '会員・配信ホームカルーセルの追加・順序・有効/無効',
                onTap: () => context.go('/admin/featured-placements'),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.post_add_outlined,
                title: '広告投稿を管理',
                description: '自社広告の投稿・編集・効果確認',
                onTap: () => context.go('/advertiser/home'),
              ),
              const SizedBox(height: 24),
              Text(
                '直近の活動',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              for (final activity in activities)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: AppColors.primary,
                    ),
                    title: Text(activity),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/member/home'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('会員サイトへ戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
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
                child: Icon(icon, color: AppColors.primary, size: 28),
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
                      description,
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
