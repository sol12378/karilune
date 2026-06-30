import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/account_provider.dart';
import '../../../theme/app_theme.dart';
import '../ideal_theme.dart';

/// 配信元の信頼シグナル（HTML `.distributor-banner` 相当）。
class DistributorBanner extends ConsumerWidget {
  const DistributorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(distributorAccountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IdealSpacing.feedPadding,
        IdealSpacing.md,
        IdealSpacing.feedPadding,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(IdealRadii.card),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: IdealShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: IdealSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('⛽', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: IdealSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.companyName}からのおすすめ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'あなたの街のガス会社が厳選した情報です',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
