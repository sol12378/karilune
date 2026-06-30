import 'package:flutter/material.dart';

/// 配信判断画面向け：画像主体の広告グリッド（3列・縦長カード）。
class DistributorVisualGridDelegate {
  DistributorVisualGridDelegate._();

  static const double spacing = 16;
  static const double maxCrossAxisExtent = 320;
  static const double cardHeight = 420;

  static SliverGridDelegate delegateFor(double width) {
    return const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCrossAxisExtent,
      mainAxisExtent: cardHeight,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
    );
  }
}

class DistributorVisualGridView extends StatelessWidget {
  const DistributorVisualGridView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
    this.physics,
    this.width,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return GridView.builder(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ??
            (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
        gridDelegate: DistributorVisualGridDelegate.delegateFor(width!),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics ??
              (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
          gridDelegate:
              DistributorVisualGridDelegate.delegateFor(constraints.maxWidth),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
