import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/ad.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/mock_contact_actions.dart';
import '../../ad_card_grid_shell.dart';
import '../../ad_thumbnail.dart';
import '../ideal_theme.dart';
import 'ad_report_dialog.dart';

/// 消費者フィード用カード（HTML `.feed-card` 相当）。
class FeedAdCard extends ConsumerWidget {
  const FeedAdCard({
    super.key,
    required this.ad,
    this.onTap,
  });

  final Ad ad;
  final VoidCallback? onTap;

  void _openDetail(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      context.push('/ads/${ad.id}?from=member');
    }
  }

  void _mockCall(BuildContext context) {
    showMockPhoneSnackBar(context, ad.advertiserTel);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(ad.id));
    final distributor = ref.watch(distributorAccountProvider);
    final remainingDays =
        ad.endDate.difference(DateTime.now()).inDays.clamp(0, 999);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(IdealRadii.card),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: IdealShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IdealRadii.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                IdealSpacing.cardPaddingH,
                IdealSpacing.cardPaddingV,
                IdealSpacing.cardPaddingH,
                IdealSpacing.sm,
              ),
              child: Row(
                children: [
                  if (ad.hasSpotlightOption) ...[
                    const AdCardBadge(
                      label: 'おすすめ',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: IdealSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      ad.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) {
                      if (value == 'report') {
                        showAdReportDialog(context, ref, adId: ad.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'report',
                        child: Text('この広告を通報'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _openDetail(context),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AdThumbnail(
                      assetPath: ad.thumbnailAssetPath,
                      networkUrl: ad.thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                    if (ad.hasSpotlightOption)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: AdCardBadge(
                          label: '注目',
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                IdealSpacing.cardPaddingH,
                IdealSpacing.md,
                IdealSpacing.cardPaddingH,
                IdealSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.companyName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.catchCopy,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${distributor.companyName}がおすすめする${ad.category}情報',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: IdealSpacing.sm),
                  Wrap(
                    spacing: IdealSpacing.md,
                    runSpacing: 4,
                    children: [
                      _MetaItem(icon: Icons.label_outline, text: ad.category),
                      _MetaItem(
                        icon: Icons.place_outlined,
                        text: ad.prefecture,
                      ),
                      _MetaItem(
                        icon: Icons.calendar_today_outlined,
                        text: '残り$remainingDays日',
                      ),
                    ],
                  ),
                  const SizedBox(height: IdealSpacing.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 320;
                      final favoriteButton = TextButton.icon(
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(ad.id),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        label: Text(
                          isFavorite ? 'お気に入り済み' : 'お気に入り',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                      final phoneButton = OutlinedButton.icon(
                        onPressed: () => _mockCall(context),
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text('電話'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.distributing,
                          side: const BorderSide(color: AppColors.distributing),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      );
                      final detailButton = FilledButton(
                        onPressed: () => _openDetail(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('詳しく見る'),
                      );

                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: favoriteButton,
                            ),
                            const SizedBox(height: IdealSpacing.sm),
                            Row(
                              children: [
                                Expanded(child: phoneButton),
                                const SizedBox(width: IdealSpacing.sm),
                                Expanded(child: detailButton),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          favoriteButton,
                          const Spacer(),
                          phoneButton,
                          const SizedBox(width: IdealSpacing.sm),
                          detailButton,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }
}
