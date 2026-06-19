import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/carousel_viewport_config.dart';
import '../../providers/ad_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import 'carousel_layout_engine.dart';
import 'featured_ad_card.dart';

/// 会員ホーム等の注目広告カルーセル設定（中央1枚 + 左右袖）。
const _kCarouselConfig = CarouselViewportConfig(
  visibleColumnCount: 3,
  horizontalInset: 48,
  minItemWidth: 260,
  maxItemWidth: kFeaturedAdCardWidth,
  itemHeight: 360,
);

class FeaturedAdsCarousel extends ConsumerStatefulWidget {
  const FeaturedAdsCarousel({
    super.key,
    this.linkFrom = 'member',
    this.viewportConfig = _kCarouselConfig,
  });

  final String linkFrom;
  final CarouselViewportConfig viewportConfig;

  @override
  ConsumerState<FeaturedAdsCarousel> createState() =>
      _FeaturedAdsCarouselState();
}

class _FeaturedAdsCarouselState extends ConsumerState<FeaturedAdsCarousel> {
  final _scrollController = ScrollController();
  var _focusedIndex = 0;
  var _isProgrammaticScroll = false;
  var _initialScrollApplied = false;
  var _initialScrollScheduled = false;
  int? _lastItemCount;

  CarouselLayoutEngine get _engine =>
      CarouselLayoutEngine(config: widget.viewportConfig);

  void _scheduleInitialCenterFocus({
    required int itemCount,
    required CarouselLayoutMetrics layout,
  }) {
    if (_initialScrollApplied || _initialScrollScheduled || itemCount <= 1) {
      return;
    }
    _initialScrollScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients || _initialScrollApplied) {
        return;
      }

      final centerIndex = CarouselLayoutMetrics.initialFocusIndex(itemCount);
      _lastItemCount = itemCount;
      await _applyScrollOffset(
        offset: layout.scrollOffsetForFocusIndex(
          centerIndex,
          itemCount: itemCount,
        ),
        targetIndex: centerIndex,
        animate: false,
      );
      if (!mounted) return;
      _initialScrollApplied = true;
    });
  }

  @override
  void didUpdateWidget(covariant FeaturedAdsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemCount = ref.read(spotlightAdsProvider).length;
    if (_lastItemCount != null && _lastItemCount != itemCount) {
      _initialScrollApplied = false;
      _initialScrollScheduled = false;
      _focusedIndex = CarouselLayoutMetrics.initialFocusIndex(itemCount);
    }
  }

  Future<void> _afterProgrammaticScroll() async {
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) return;
    _isProgrammaticScroll = false;
  }

  Future<void> _applyScrollOffset({
    required double offset,
    required int targetIndex,
    required bool animate,
  }) async {
    _isProgrammaticScroll = true;
    _focusedIndex = targetIndex;
    setState(() {});

    if (animate) {
      await _scrollController.animateTo(
        offset,
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      );
    } else {
      _scrollController.jumpTo(offset);
    }

    await _afterProgrammaticScroll();
  }

  bool _isWrapNavigation(int from, int to, int count) {
    if (count <= 1) return false;
    return (from == count - 1 && to == 0) || (from == 0 && to == count - 1);
  }

  Future<void> _navigateToIndex({
    required int target,
    required int itemCount,
    required CarouselLayoutMetrics layout,
  }) async {
    if (!_scrollController.hasClients || target == _focusedIndex) return;

    final wrap = _isWrapNavigation(_focusedIndex, target, itemCount);
    final offset =
        layout.scrollOffsetForFocusIndex(target, itemCount: itemCount);

    await _applyScrollOffset(
      offset: offset,
      targetIndex: target,
      animate: !wrap,
    );
  }

  Future<void> _goRelative({
    required int delta,
    required int itemCount,
    required CarouselLayoutMetrics layout,
  }) async {
    if (itemCount <= 1 || !_scrollController.hasClients) return;

    final target = (_focusedIndex + delta + itemCount) % itemCount;
    await _navigateToIndex(
      target: target,
      itemCount: itemCount,
      layout: layout,
    );
  }

  Future<void> _handleScrollEnd({
    required int itemCount,
    required CarouselLayoutMetrics layout,
  }) async {
    if (_isProgrammaticScroll ||
        itemCount <= 1 ||
        !_scrollController.hasClients) {
      return;
    }

    final nearest = layout.focusIndexForScrollOffset(
      _scrollController.offset,
      itemCount: itemCount,
    );

    if (nearest == _focusedIndex) return;

    await _navigateToIndex(
      target: nearest,
      itemCount: itemCount,
      layout: layout,
    );
  }

  bool _onScrollNotification(
    ScrollNotification notification, {
    required int itemCount,
    required CarouselLayoutMetrics layout,
  }) {
    if (notification is ScrollEndNotification) {
      _handleScrollEnd(itemCount: itemCount, layout: layout);
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

    final itemCount = ads.length;
    final engine = _engine;

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
              final layout = engine.compute(constraints.maxWidth);
              _scheduleInitialCenterFocus(
                itemCount: itemCount,
                layout: layout,
              );

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) => _onScrollNotification(
                      n,
                      itemCount: itemCount,
                      layout: layout,
                    ),
                    child: SizedBox(
                      height: engine.config.itemHeight,
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(
                          left: layout.leadingPadding,
                          right: layout.trailingPadding,
                        ),
                        physics: const ClampingScrollPhysics(),
                        itemCount: itemCount,
                        separatorBuilder: (_, __) => SizedBox(
                          width: engine.config.itemSpacing,
                        ),
                        itemBuilder: (context, index) {
                          final ad = ads[index];
                          return _ScaledCarouselItem(
                            scrollController: _scrollController,
                            itemCenterX: layout.itemCenterX(index),
                            viewportWidth: layout.viewportWidth,
                            itemStride: layout.itemStride,
                            child: FeaturedAdCard(
                              width: layout.itemWidth,
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
                  if (itemCount > 1) ...[
                    Positioned(
                      left: 8,
                      child: _NavButton(
                        icon: Icons.chevron_left,
                        onPressed: () => _goRelative(
                          delta: -1,
                          itemCount: itemCount,
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
                          itemCount: itemCount,
                          layout: layout,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (itemCount > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < itemCount; i++)
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
