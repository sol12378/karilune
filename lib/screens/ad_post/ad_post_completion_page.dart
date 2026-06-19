import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../widgets/ad_card_consumer.dart';

class AdPostCompletionPage extends ConsumerWidget {
  const AdPostCompletionPage({super.key, required this.adId});

  final String adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ad = ref.watch(adByIdProvider(adId));

    return Scaffold(
      appBar: AppBar(title: const Text('投稿完了')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '広告の投稿が完了しました',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '決済が完了し、審査通過後に配信者へ公開されます。'
                '配信者画面では新しい広告が候補一覧に表示されます。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              if (ad != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  height: 280,
                  child: AdCardConsumer(ad: ad),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/distributor/home'),
                child: const Text('配信者画面で確認'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/advertiser/home'),
                child: const Text('投稿ホームへ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
