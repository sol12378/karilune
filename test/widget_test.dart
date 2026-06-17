import 'package:carilune/main.dart';
import 'package:carilune/providers/account_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('アプリが会員ホームで起動する', (WidgetTester tester) async {
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
    expect(find.text('広告管理ダッシュボードへ'), findsOneWidget);
  });
}
