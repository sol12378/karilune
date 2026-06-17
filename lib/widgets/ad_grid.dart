import 'package:flutter/material.dart';

/// 全会員・管理画面で共通のレスポンシブ広告グリッド
class AdGridDelegate {
  AdGridDelegate._();

  static const double spacing = 12;
  static const double maxCardWidth = 280;
  static const double cardHeight = 300;

  static SliverGridDelegate delegateFor(double width) {
    return const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCardWidth,
      mainAxisExtent: cardHeight,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
    );
  }
}

class AdGridView extends StatelessWidget {
  const AdGridView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: padding,
          gridDelegate: AdGridDelegate.delegateFor(constraints.maxWidth),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class AdGridSliver extends StatelessWidget {
  const AdGridSliver({
    super.key,
    required this.width,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double width;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: AdGridDelegate.delegateFor(width),
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
    );
  }
}
