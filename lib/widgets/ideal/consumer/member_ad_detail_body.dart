import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ad.dart';
import '../../../providers/account_provider.dart';
import '../../../theme/app_theme.dart';
import '../../ad_thumbnail.dart';
import '../ideal_theme.dart';
import 'ad_report_dialog.dart';
import 'distributor_banner.dart';

/// 会員向け広告詳細本文（HTML consumer-detail.html 相当）。
class MemberAdDetailBody extends ConsumerWidget {
  const MemberAdDetailBody({super.key, required this.ad});

  final Ad ad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributor = ref.watch(distributorAccountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: AdThumbnail(
            assetPath: ad.thumbnailAssetPath,
            networkUrl: ad.thumbnailUrl,
            width: double.infinity,
            height: 280,
            borderRadius: 0,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            IdealSpacing.lg,
            IdealSpacing.md,
            IdealSpacing.lg,
            0,
          ),
          child: DistributorBanner(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            IdealSpacing.lg,
            IdealSpacing.sm,
            IdealSpacing.lg,
            0,
          ),
          child: Text(
            '「${distributor.companyName}」（配信者）が会員の皆さまにおすすめする地域広告です。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(IdealSpacing.lg),
          child: DecoratedBox(
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
                children: [
                  Chip(
                    label: Text(ad.category),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: IdealSpacing.md),
                  Text(
                    ad.catchCopy,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: IdealSpacing.sm),
                  Text(
                    ad.companyName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  const SizedBox(height: IdealSpacing.md),
                  Text(
                    ad.prText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            IdealSpacing.lg,
            0,
            IdealSpacing.lg,
            IdealSpacing.lg,
          ),
          child: DecoratedBox(
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
                children: [
                  Text(
                    'お店情報',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: IdealSpacing.md),
                  _InfoRow(label: 'エリア', value: ad.prefecture),
                  _InfoRow(label: '電話', value: ad.advertiserTel),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            IdealSpacing.lg,
            IdealSpacing.md,
            IdealSpacing.lg,
            IdealSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => showAdReportDialog(context, ref, adId: ad.id),
              icon: Icon(Icons.flag_outlined, size: 18, color: Colors.grey.shade600),
              label: Text(
                'この広告を通報',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
