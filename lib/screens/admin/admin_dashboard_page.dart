import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../data/audit_log_repository.dart';
import '../../mock_data/billing_events_mock.dart';
import '../../models/billing_event.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/demo_scenario_provider.dart';
import '../../mock_data/demo_scenarios.dart';
import '../../theme/app_theme.dart';
import '../../utils/csv_export.dart';
import '../../widgets/admin/admin_review_queue.dart';
import '../../widgets/admin_shell.dart';
import '../../widgets/ideal/ideal_theme.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final _reviewSectionKey = GlobalKey();

  void _scrollToReview() {
    final context = _reviewSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminDashboardStatsProvider);
    final allAds = ref.watch(adListProvider);

    return AdminShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      title: '運営ダッシュボード',
      showNavigation: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(IdealSpacing.xl),
            children: [
              Text(
                'プラットフォーム概要',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: IdealSpacing.md),
              _ActionQueue(
                stats: stats,
                onReviewTap: _scrollToReview,
                onAdsTap: () => context.go('/admin/ads'),
              ),
              const SizedBox(height: IdealSpacing.xl),
              _StatsGrid(stats: stats),
              const SizedBox(height: IdealSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      key: _reviewSectionKey,
                      children: [
                        Text(
                          '審査キュー',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: IdealSpacing.sm),
                        const AdminReviewQueue(),
                      ],
                    ),
                  ),
                  const SizedBox(width: IdealSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '管理メニュー',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: IdealSpacing.sm),
                        _NavCard(
                          icon: Icons.view_list_outlined,
                          title: '広告一覧',
                          description: '検索・フィルタ・緊急停止',
                          onTap: () => context.go('/admin/ads'),
                        ),
                        const SizedBox(height: IdealSpacing.sm),
                        _NavCard(
                          icon: Icons.star_outline,
                          title: '注目掲載枠',
                          description: 'カルーセル掲載の管理',
                          onTap: () =>
                              context.go('/admin/featured-placements'),
                        ),
                        const SizedBox(height: IdealSpacing.sm),
                        _NavCard(
                          icon: Icons.post_add_outlined,
                          title: '作成元ダッシュボード',
                          description: '広告投稿の確認',
                          onTap: () => context.go('/advertiser/home'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IdealSpacing.xl),
              Text(
                'デモシナリオ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: IdealSpacing.sm),
              const _DemoScenarioCard(),
              const SizedBox(height: IdealSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '監査ログ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final csv = buildAdsCsv(allAds);
                      await Clipboard.setData(ClipboardData(text: csv));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('広告CSVをクリップボードにコピーしました'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('CSVエクスポート'),
                  ),
                ],
              ),
              const SizedBox(height: IdealSpacing.sm),
              for (final activity in stats.recentActivities)
                Padding(
                  padding: const EdgeInsets.only(bottom: IdealSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(IdealRadii.card),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.history,
                        color: AppColors.primary,
                      ),
                      title: Text(activity),
                    ),
                  ),
                ),
              const SizedBox(height: IdealSpacing.xl),
              ExpansionTile(
                title: Text(
                  '請求イベント（設計プレビュー）',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: const Text('収益化フェーズ向けのイベント定義サンプル'),
                children: [
                  for (final event in mockBillingEvents)
                    ListTile(
                      title: Text('${event.companyName} — ${event.type.label}'),
                      subtitle: Text(event.note ?? ''),
                      trailing: Text('¥${event.amountYen}'),
                    ),
                ],
              ),
              const SizedBox(height: IdealSpacing.lg),
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

class _ActionQueue extends StatelessWidget {
  const _ActionQueue({
    required this.stats,
    required this.onReviewTap,
    required this.onAdsTap,
  });

  final AdminDashboardStats stats;
  final VoidCallback onReviewTap;
  final VoidCallback onAdsTap;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (stats.pendingReviewAds > 0) {
      items.add(
        _AlertCard(
          icon: Icons.fact_check_outlined,
          title: '審査待ち',
          description: '${stats.pendingReviewAds} 件',
          color: Colors.orange,
          onTap: onReviewTap,
        ),
      );
    }
    if (stats.pendingReports > 0) {
      items.add(
        _AlertCard(
          icon: Icons.flag_outlined,
          title: '通報',
          description: '${stats.pendingReports} 件',
          color: Colors.red,
          onTap: onAdsTap,
        ),
      );
    }
    if (stats.zeroDistributionAds > 0) {
      items.add(
        _AlertCard(
          icon: Icons.wifi_off_outlined,
          title: '配信0（公開中）',
          description: '${stats.zeroDistributionAds} 件',
          color: Colors.blue,
          onTap: onAdsTap,
        ),
      );
    }
    if (stats.draftAds > 0) {
      items.add(
        _AlertCard(
          icon: Icons.edit_note_outlined,
          title: '下書き',
          description: '${stats.draftAds} 件',
          color: Colors.grey,
          onTap: () => context.go('/advertiser/home'),
        ),
      );
    }

    if (items.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const ListTile(
          leading: Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text('要対応項目はありません'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '要対応',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: IdealSpacing.sm),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: IdealSpacing.sm),
            child: item,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('登録広告', '${stats.totalAds}'),
      _StatItem('配信中', '${stats.distributingAds}'),
      _StatItem('会員表示', '${stats.memberVisibleAds}'),
      _StatItem('参照数合計', '${stats.totalViews}'),
      _StatItem('審査待ち', '${stats.pendingReviewAds}'),
      _StatItem('通報', '${stats.pendingReports}'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: IdealSpacing.md,
      crossAxisSpacing: IdealSpacing.md,
      childAspectRatio: 2.2,
      children: items
          .map(
            (item) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(IdealRadii.card),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: IdealShadows.card,
              ),
              child: Padding(
                padding: const EdgeInsets.all(IdealSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.value,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                    ),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value);
  final String label;
  final String value;
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DemoScenarioCard extends ConsumerStatefulWidget {
  const _DemoScenarioCard();

  @override
  ConsumerState<_DemoScenarioCard> createState() => _DemoScenarioCardState();
}

class _DemoScenarioCardState extends ConsumerState<_DemoScenarioCard> {
  DemoScenarioId? _pending;

  DemoScenarioId get _selected =>
      _pending ?? ref.watch(demoScenarioProvider);

  void _apply() {
    ref.read(demoScenarioProvider.notifier).state = _selected;
    ref.read(adRepositoryProvider.notifier).resetToScenario(_selected);
    ref.read(auditLogRepositoryProvider.notifier).log(
          actor: '運営',
          action: 'シナリオ切替',
          targetType: 'scenario',
          targetId: _selected.name,
          detail: _selected.label,
        );
    setState(() => _pending = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('シナリオ「${_selected.label}」を適用しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(IdealSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<DemoScenarioId>(
              value: _selected,
              decoration: const InputDecoration(
                labelText: 'シナリオを選択',
                border: OutlineInputBorder(),
              ),
              items: DemoScenarioId.values
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(id.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _pending = value);
                }
              },
            ),
            const SizedBox(height: IdealSpacing.sm),
            Text(
              _selected.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: IdealSpacing.md),
            FilledButton(
              onPressed: _apply,
              child: const Text('シナリオを適用'),
            ),
          ],
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: IdealShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(IdealSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: IdealSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
