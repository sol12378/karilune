import 'package:carilune/providers/operator_stats_provider.dart';
import 'package:carilune/widgets/ideal/advertiser/stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatsGrid shows four stat cards', (tester) async {
    const stats = AdvertiserDashboardStats(
      activeAdCount: 5,
      distributorCount: 47,
      viewCount: 8420,
      leadCount: 186,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsGrid(stats: stats),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('配信中の広告'), findsOneWidget);
    expect(find.text('配信者数（合計）'), findsOneWidget);
    expect(find.text('参照数（合計）'), findsOneWidget);
    expect(find.text('リード数'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('186'), findsOneWidget);
  });
}
