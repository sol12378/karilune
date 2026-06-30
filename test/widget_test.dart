import 'package:carilune/main.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_logged_in': true,
      'auth_role': 'member',
    });
  });

  testWidgets('ログイン済み会員がホームを表示する', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
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
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('からのおすすめ'), findsOneWidget);
    expect(find.text('詳しく見る'), findsWidgets);
  });

  testWidgets('ログイン済み会員がPCホームを表示する', (WidgetTester tester) async {
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
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('注目の広告'), findsOneWidget);
    expect(find.text('配信中の広告'), findsOneWidget);
    expect(find.text('電話'), findsWidgets);
  });
}
