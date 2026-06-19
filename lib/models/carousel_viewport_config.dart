/// 横スクロールカルーセルの表示設定。
///
/// [visibleColumnCount] を増やしてもレイアウト計算は [CarouselLayoutEngine] が担う。
class CarouselViewportConfig {
  const CarouselViewportConfig({
    this.visibleColumnCount = 3,
    this.itemSpacing = 20,
    this.horizontalInset = 48,
    this.minItemWidth = 260,
    this.maxItemWidth = 380,
    this.itemHeight = 360,
  });

  /// カード幅計算に使う見え方の枠数（中央 + 左右の袖）。
  /// 広告の掲載件数とは無関係。
  final int visibleColumnCount;
  final double itemSpacing;
  final double horizontalInset;
  final double minItemWidth;
  final double maxItemWidth;
  final double itemHeight;
}
