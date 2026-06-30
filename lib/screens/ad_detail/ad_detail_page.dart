import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ad_repository.dart';
import '../../models/ad.dart';
import '../../providers/ad_list_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formats.dart';
import '../../utils/pricing_calculator.dart';
import '../../utils/mock_contact_actions.dart';
import '../../widgets/ad_thumbnail.dart';
import '../../widgets/ideal/consumer/ad_report_dialog.dart';
import '../../widgets/ideal/consumer/member_ad_detail_body.dart';
import '../../widgets/ideal/consumer/member_content_frame.dart';
import '../distributor/distributor_actions.dart';

class AdDetailPage extends ConsumerStatefulWidget {
  const AdDetailPage({super.key, required this.adId, this.fromMode});

  final String adId;
  final String? fromMode;

  @override
  ConsumerState<AdDetailPage> createState() => _AdDetailPageState();
}

class _AdDetailPageState extends ConsumerState<AdDetailPage> {
  var _viewCounted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = widget.fromMode ??
          GoRouterState.of(context).uri.queryParameters['from'] ??
          'member';
      if (mode == 'member' && !_viewCounted) {
        _viewCounted = true;
        ref.read(adRepositoryProvider.notifier).incrementViewCount(widget.adId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adId = widget.adId;
    final ad = ref.watch(adByIdProvider(adId));
    final mode = widget.fromMode ??
        GoRouterState.of(context).uri.queryParameters['from'] ??
        'member';
    final isMemberMode = mode == 'member';
    final isDistributorMode = mode == 'distributor';
    final showDistributeButton = isDistributorMode;
    final isAdvertiserMode = mode == 'advertiser';
    final isFavorite = ref.watch(isFavoriteProvider(adId));

    if (ad == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('広告詳細')),
        body: const Center(child: Text('広告が見つかりませんでした')),
      );
    }

    final total = isDistributorMode
        ? 0
        : PricingCalculator.calculateTotal(
            distributionDays: ad.distributionDays,
            hasSpotlightOption: ad.hasSpotlightOption,
            hasDistributionRequestNotification:
                ad.hasDistributionRequestNotification,
            hasDistributionSettingNotification:
                ad.hasDistributionSettingNotification,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('広告詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: isMemberMode
            ? [
                IconButton(
                  tooltip: '通報',
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => showAdReportDialog(
                    context,
                    ref,
                    adId: adId,
                  ),
                ),
              ]
            : null,
      ),
      body: isMemberMode
          ? MemberContentFrame(
              style: MemberFrameStyle.detail,
              child: SingleChildScrollView(
                child: MemberAdDetailBody(ad: ad),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AdThumbnail(
                    assetPath: ad.thumbnailAssetPath,
                    networkUrl: ad.thumbnailUrl,
                    width: 300,
                    height: 400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  ad.catchCopy,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  ad.companyName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(ad.prText),
                const SizedBox(height: 24),
                _InfoCard(
                  title: '配信情報',
                  children: [
                    _infoRow(
                      '配信開始日',
                      AppDateFormats.yearMonthDay.format(ad.startDate),
                    ),
                    _infoRow(
                      '配信終了日',
                      AppDateFormats.yearMonthDay.format(ad.endDate),
                    ),
                    _infoRow('配信日数', '${ad.distributionDays}日'),
                    _infoRow('カテゴリー', ad.category),
                    if (!isDistributorMode)
                      _infoRow(
                        '広告料金',
                        PricingCalculator.formatYen(total),
                      ),
                  ],
                ),
                if (isAdvertiserMode) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: '効果レポート',
                    children: [
                      _infoRow('配信者数', '${ad.distributorCount}'),
                      _infoRow('参照数', '${ad.viewCount}'),
                      _infoRow('地域', ad.prefecture),
                    ],
                  ),
                ],
                if (!isDistributorMode) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'オプション',
                    children: [
                      _infoRow(
                        '注目オプション',
                        ad.hasSpotlightOption ? 'あり' : 'なし',
                      ),
                      _infoRow(
                        '配信依頼通知',
                        ad.hasDistributionRequestNotification ? 'あり' : 'なし',
                      ),
                      _infoRow(
                        '配信設定通知',
                        ad.hasDistributionSettingNotification ? 'あり' : 'なし',
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _InfoCard(
                  title: '投稿者情報',
                  children: [
                    _infoRow('会社名', ad.advertiserCompanyName),
                    _infoRow('URL', ad.advertiserUrl),
                    _infoRow('TEL', ad.advertiserTel),
                    _infoRow('担当者', ad.advertiserContact),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(
        context,
        ref,
        ad: ad,
        isMemberMode: isMemberMode,
        isAdvertiserMode: isAdvertiserMode,
        showDistributeButton: showDistributeButton,
        isFavorite: isFavorite,
      ),
    );
  }

  Widget? _buildBottomBar(
    BuildContext context,
    WidgetRef ref, {
    required Ad ad,
    required bool isMemberMode,
    required bool isAdvertiserMode,
    required bool showDistributeButton,
    required bool isFavorite,
  }) {
    if (isMemberMode) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(ad.id),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(isFavorite ? 'お気に入り済み' : 'お気に入り'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isFavorite ? Colors.red.shade400 : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      showMockPhoneSnackBar(context, ad.advertiserTel),
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('電話'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isAdvertiserMode && ad.isAdvertiserAd) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => context.push('/advertiser/ads/${ad.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('広告を編集'),
          ),
        ),
      );
    }

    if (showDistributeButton && !ad.isOwnAd) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => confirmToggleDistributing(context, ref, ad),
            style: FilledButton.styleFrom(
              backgroundColor: ad.isDistributing
                  ? AppColors.distributing
                  : AppColors.primary,
            ),
            child: Text(ad.isDistributing ? '配信停止' : '配信する'),
          ),
        ),
      );
    }

    return null;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
