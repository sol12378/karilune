import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/featured_placement_repository.dart';
import '../../models/ad.dart';
import '../../models/featured_placement.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_shell.dart';

class FeaturedPlacementsPage extends ConsumerStatefulWidget {
  const FeaturedPlacementsPage({super.key});

  @override
  ConsumerState<FeaturedPlacementsPage> createState() =>
      _FeaturedPlacementsPageState();
}

class _FeaturedPlacementsPageState
    extends ConsumerState<FeaturedPlacementsPage> {
  String _selectedKey = FeaturedPlacementKeys.memberHomeSpotlight;

  List<FeaturedPlacement> get _placementsForKey {
    return ref
        .watch(featuredPlacementRepositoryProvider)
        .where((p) => p.placementKey == _selectedKey)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    final placements = _placementsForKey;
    final catalog = ref.watch(activeDistributingAdsProvider);

    return AdminShell(
      currentLocation: GoRouterState.of(context).matchedLocation,
      title: '注目広告の掲載管理',
      showNavigation: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: FeaturedPlacementKeys.memberHomeSpotlight,
                label: Text('会員ホーム'),
              ),
              ButtonSegment(
                value: FeaturedPlacementKeys.distributorHomeSpotlight,
                label: Text('配信ホーム'),
              ),
            ],
            selected: {_selectedKey},
            onSelectionChanged: (value) {
              setState(() => _selectedKey = value.first);
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showAddDialog(catalog),
              icon: const Icon(Icons.add),
              label: const Text('広告を追加'),
            ),
          ),
          const SizedBox(height: 12),
          if (placements.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('掲載中の広告はありません。追加してください。'),
              ),
            )
          else
            for (var i = 0; i < placements.length; i++)
              _PlacementTile(
                placement: placements[i],
                adLabel: _adLabel(placements[i].adId, catalog),
                onMoveUp: i > 0 ? () => _swapOrder(placements, i, i - 1) : null,
                onMoveDown: i < placements.length - 1
                    ? () => _swapOrder(placements, i, i + 1)
                    : null,
                onToggleActive: () {
                  ref.read(featuredPlacementRepositoryProvider.notifier).upsert(
                        placements[i].copyWith(
                          isActive: !placements[i].isActive,
                        ),
                      );
                },
                onRemove: () {
                  ref
                      .read(featuredPlacementRepositoryProvider.notifier)
                      .remove(placements[i].id);
                },
              ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go('/admin/dashboard'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('ダッシュボードへ戻る'),
            ),
          ),
        ],
      ),
    );
  }

  String _adLabel(String adId, List<Ad> catalog) {
    for (final ad in catalog) {
      if (ad.id == adId) return ad.companyName;
    }
    return adId;
  }

  void _swapOrder(List<FeaturedPlacement> list, int from, int to) {
    final updated = List<FeaturedPlacement>.from(list);
    final tempOrder = updated[from].sortOrder;
    updated[from] = updated[from].copyWith(sortOrder: updated[to].sortOrder);
    updated[to] = updated[to].copyWith(sortOrder: tempOrder);
    ref.read(featuredPlacementRepositoryProvider.notifier).replaceForKey(
          placementKey: _selectedKey,
          placements: updated,
        );
  }

  Future<void> _showAddDialog(List<Ad> catalog) async {
    if (catalog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配信中の広告がありません')),
      );
      return;
    }
    var selectedAdId = catalog.first.id;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('掲載広告を追加'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedAdId,
          decoration: const InputDecoration(
            labelText: '広告',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final ad in catalog)
              DropdownMenuItem(
                value: ad.id,
                child: Text(ad.companyName),
              ),
          ],
          onChanged: (value) {
            if (value != null) selectedAdId = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    if (result != true) return;

    final existing = _placementsForKey;
    final nextOrder = existing.isEmpty
        ? 0
        : existing.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    ref.read(featuredPlacementRepositoryProvider.notifier).upsert(
          FeaturedPlacement(
            id: 'fp-${DateTime.now().millisecondsSinceEpoch}',
            placementKey: _selectedKey,
            adId: selectedAdId,
            sortOrder: nextOrder,
          ),
        );
  }
}

class _PlacementTile extends StatelessWidget {
  const _PlacementTile({
    required this.placement,
    required this.adLabel,
    this.onMoveUp,
    this.onMoveDown,
    required this.onToggleActive,
    required this.onRemove,
  });

  final FeaturedPlacement placement;
  final String adLabel;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onToggleActive;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: placement.isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          child: Text('${placement.sortOrder + 1}'),
        ),
        title: Text(adLabel),
        subtitle: Text(
          placement.isActive ? '有効' : '無効',
          style: TextStyle(
            color: placement.isActive ? AppColors.distributing : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: onMoveUp,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: onMoveDown,
            ),
            IconButton(
              icon: Icon(
                placement.isActive ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggleActive,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
