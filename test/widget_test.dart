import 'package:carilune/main.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('アプリが会員ホームで起動する', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const CariluneApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('カリルネ'), findsOneWidget);
    expect(find.text('注目の広告'), findsOneWidget);
    expect(find.text('オプション設定の広告をピックアップ'), findsOneWidget);
    expect(find.text('配信中の広告'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('広告管理（デモ用）'), findsOneWidget);
  });
}
