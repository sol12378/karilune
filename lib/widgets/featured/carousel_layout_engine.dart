import '../../models/carousel_viewport_config.dart';

/// カルーセル 1 フレーム分のレイアウト計測値。
class CarouselLayoutMetrics {
  const CarouselLayoutMetrics({
    required this.viewportWidth,
    required this.itemWidth,
    required this.itemStride,
    required this.leadingPadding,
    required this.trailingPadding,
  });

  final double viewportWidth;
  final double itemWidth;
  final double itemStride;
  final double leadingPadding;
  final double trailingPadding;

  double itemCenterX(int index) =>
      leadingPadding + index * itemStride + itemWidth / 2;

  /// リスト件数から初期フォーカス位置（中央インデックス）を返す。
  static int initialFocusIndex(int itemCount) {
    if (itemCount <= 1) return 0;
    return itemCount ~/ 2;
  }

  /// 指定インデックスのカードがビューポート中央に来るスクロールオフセット。
  double scrollOffsetForFocusIndex(int index, {required int itemCount}) {
    if (itemCount <= 1) return 0;
    return index * itemStride;
  }

  /// 現在のスクロール位置から最も近いフォーカスインデックスを返す。
  int focusIndexForScrollOffset(double offset, {required int itemCount}) {
    if (itemCount <= 1) return 0;

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < itemCount; i++) {
      final distance =
          (offset - scrollOffsetForFocusIndex(i, itemCount: itemCount)).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }
}

/// カラム数可変の中央スナップカルーセル用レイアウト計算。
class CarouselLayoutEngine {
  const CarouselLayoutEngine({this.config = const CarouselViewportConfig()});

  final CarouselViewportConfig config;

  CarouselLayoutMetrics compute(double viewportWidth) {
    final columns = config.visibleColumnCount.clamp(1, 99);
    final available = viewportWidth - config.horizontalInset;
    final gapCount = columns - 1;
    final rawWidth =
        (available - gapCount * config.itemSpacing) / columns;
    final itemWidth =
        rawWidth.clamp(config.minItemWidth, config.maxItemWidth);
    final itemStride = itemWidth + config.itemSpacing;

    // 先頭・末尾も中央にスナップできるよう左右対称パディングを付与する。
    final sidePadding = viewportWidth / 2 - itemWidth / 2;

    return CarouselLayoutMetrics(
      viewportWidth: viewportWidth,
      itemWidth: itemWidth,
      itemStride: itemStride,
      leadingPadding: sidePadding,
      trailingPadding: sidePadding,
    );
  }
}
