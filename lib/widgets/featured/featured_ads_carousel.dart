import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import 'featured_ad_card.dart';

const double _kItemSpacing = 20;
const double _kCarouselHeight = 360;

/// カルーセルのレイアウト計測値（スクロール位置計算に使用）。
class _CarouselLayout {
  const _CarouselLayout({
    required this.viewportWidth,
    required this.cardWidth,
    required this.itemStride,
    required this.leadingPadding,
  });

  final double viewportWidth;
  final double cardWidth;
  final double itemStride;
  final double leadingPadding;
}

class FeaturedAdsCarousel extends ConsumerStatefulWidget {
  const FeaturedAdsCarousel({
    super.key,
    this.linkFrom = 'member',
  });

  final String linkFrom;

  @override
  ConsumerState<FeaturedAdsCarousel> createState() =>
      _FeaturedAdsCarouselState();
}

class _FeaturedAdsCarouselState extends ConsumerState<FeaturedAdsCarousel> {
  final _scrollController = ScrollController();
  var _focusedIndex = 0;
  var _isProgrammaticScroll = false;

  double _cardWidth(double viewportWidth) {
    final available = viewportWidth - 48;
    final forThree = (available - 2 * _kItemSpacing) / 3;
    return forThree.clamp(260.0, kFeaturedAdCardWidth);
  }

  double _itemStride(double cardWidth) => cardWidth + _kItemSpacing;

  double _leadingPadding(double viewportWidth, double cardWidth) {
    final trioWidth = 3 * cardWidth + 2 * _kItemSpacing;
    return math.max(0, (viewportWidth - trioWidth) / 2);
  }

  /// 最後のカードがビューポート中央までスクロールできるよう右余白を追加する。
  double _trailingPadding(_CarouselLayout layout) {
    final extra = layout.viewportWidth / 2 -
        layout.cardWidth / 2 -
        layout.leadingPadding;
    return math.max(0, extra);
  }

  _CarouselLayout _buildLayout(double viewportWidth) {
    final cardWidth = _cardWidth(viewportWidth);
    return _CarouselLayout(
      viewportWidth: viewportWidth,
      cardWidth: cardWidth,
      itemStride: _itemStride(cardWidth),
      leadingPadding: _leadingPadding(viewportWidth, cardWidth),
    );
  }

  double _maxScrollExtent() {
    if (!_scrollController.hasClients) return 0;
    return _scrollController.position.maxScrollExtent;
  }

  /// フォーカス中カードがビューポート中央に来るオフセット（端ではクランプ）。
  double _offsetForFocusIndex(int index, int count, _CarouselLayout layout) {
    final raw = layout.leadingPadding +
        index * layout.itemStride +
        layout.cardWidth / 2 -
        layout.viewportWidth / 2;
    return raw.clamp(0.0, _maxScrollExtent());
  }

  int _focusIndexForOffset(double offset, int count, _CarouselLayout layout) {
    final center = offset + layout.viewportWidth / 2;
    final raw =
        (center - layout.leadingPadding - layout.cardWidth / 2) / layout.itemStride;
    return raw.round().clamp(0, count - 1);
  }

  double _itemCenterX(int index, _CarouselLayout layout) =>
      layout.leadingPadding +
      index * layout.itemStride +
      layout.cardWidth / 2;

  bool _isWrapNavigation(int from, int to, int count) {
    if (count <= 1) return false;
    return (from == count - 1 && to == 0) || (from == 0 && to == count - 1);
  }

  Future<void> _navigateToIndex({
    required int target,
    required int realCount,
    required _CarouselLayout layout,
  }) async {
    if (!_scrollController.hasClients || target == _focusedIndex) return;

    final wrap = _isWrapNavigation(_focusedIndex, target, realCount);
    final offset = _offsetForFocusIndex(target, realCount, layout);

    _isProgrammaticScroll = true;
    _focusedIndex = target;
    setState(() {});

    if (wrap) {
      _scrollController.jumpTo(offset);
    } else {
      await _scrollController.animateTo(
        offset,
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      );
    }

    if (!mounted) return;
    _isProgrammaticScroll = false;
  }

  void _goRelative({
    required int delta,
    required int realCount,
    required _CarouselLayout layout,
  }) {
    if (realCount <= 1) return;
    final target = (_focusedIndex + delta + realCount) % realCount;
    _navigateToIndex(
      target: target,
      realCount: realCount,
      layout: layout,
    );
  }

  Future<void> _handleScrollEnd({
    required int realCount,
    required _CarouselLayout layout,
  }) async {
    if (_isProgrammaticScroll || realCount <= 1 || !_scrollController.hasClients) {
      return;
    }

    final nearest = _focusIndexForOffset(
      _scrollController.offset,
      realCount,
      layout,
    );

    if (nearest == _focusedIndex) return;

    await _navigateToIndex(
      target: nearest,
      realCount: realCount,
      layout: layout,
    );
  }

  bool _onScrollNotification(
    ScrollNotification notification, {
    required int realCount,
    required _CarouselLayout layout,
  }) {
    if (notification is ScrollEndNotification) {
      _handleScrollEnd(realCount: realCount, layout: layout);
    }
    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(spotlightAdsProvider);
    if (ads.isEmpty) return const SizedBox.shrink();

    final realCount = ads.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final layout = _buildLayout(constraints.maxWidth);

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) => _onScrollNotification(
                      n,
                      realCount: realCount,
                      layout: layout,
                    ),
                    child: SizedBox(
                      height: _kCarouselHeight,
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(
                          left: layout.leadingPadding,
                          right: layout.leadingPadding +
                              _trailingPadding(layout),
                        ),
                        physics: const ClampingScrollPhysics(),
                        itemCount: realCount,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: _kItemSpacing),
                        itemBuilder: (context, index) {
                          final ad = ads[index];
                          return _ScaledCarouselItem(
                            scrollController: _scrollController,
                            itemCenterX: _itemCenterX(index, layout),
                            viewportWidth: layout.viewportWidth,
                            itemStride: layout.itemStride,
                            child: FeaturedAdCard(
                              width: layout.cardWidth,
                              ad: ad,
                              onTap: () => context.push(
                                '/ads/${ad.id}?from=${widget.linkFrom}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: _EdgeFadeMask(color: AppColors.background),
                    ),
                  ),
                  if (realCount > 1) ...[
                    Positioned(
                      left: 8,
                      child: _NavButton(
                        icon: Icons.chevron_left,
                        onPressed: () => _goRelative(
                          delta: -1,
                          realCount: realCount,
                          layout: layout,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      child: _NavButton(
                        icon: Icons.chevron_right,
                        onPressed: () => _goRelative(
                          delta: 1,
                          realCount: realCount,
                          layout: layout,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (realCount > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < realCount; i++)
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _focusedIndex == i ? 10 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _focusedIndex == i
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// ビューポート中心からの距離に応じて scale / opacity を補間する。
class _ScaledCarouselItem extends StatelessWidget {
  const _ScaledCarouselItem({
    required this.scrollController,
    required this.itemCenterX,
    required this.viewportWidth,
    required this.itemStride,
    required this.child,
  });

  final ScrollController scrollController;
  final double itemCenterX;
  final double viewportWidth;
  final double itemStride;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final offset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        final viewportCenter = offset + viewportWidth / 2;
        final normalized = (itemCenterX - viewportCenter).abs() / itemStride;
        final scale = (1 - normalized * 0.12).clamp(0.86, 1.0);
        final opacity = (1 - normalized * 0.5).clamp(0.4, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 左右端を背景色へフェードさせ、カードが自然に消える演出。
class _EdgeFadeMask extends StatelessWidget {
  const _EdgeFadeMask({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        const Spacer(flex: 4),
        Expanded(
          flex: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0), color],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注目の広告',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'オプション設定の広告をピックアップ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 2,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
