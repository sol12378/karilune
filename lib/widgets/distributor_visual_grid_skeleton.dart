import 'package:flutter/material.dart';

import 'distributor_visual_grid.dart';

/// 配信判断画面のスケルトン（画像主体カード形状）。
class DistributorVisualGridSkeleton extends StatelessWidget {
  const DistributorVisualGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
  });

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            DistributorVisualGridDelegate.maxCrossAxisExtent,
        mainAxisExtent: DistributorVisualGridDelegate.cardHeight,
        crossAxisSpacing: DistributorVisualGridDelegate.spacing,
        mainAxisSpacing: DistributorVisualGridDelegate.spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ColoredBox(color: Colors.grey.shade200),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 12,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
