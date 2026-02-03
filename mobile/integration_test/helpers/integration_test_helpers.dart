import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Helper class for integration tests
class IntegrationTestHelpers {
  /// Wait for app to be fully loaded
  static Future<void> waitForAppReady(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Wait for network request to complete
  static Future<void> waitForNetworkRequest(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Tap and wait for navigation
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text in a field
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    double delta = 100,
  }) async {
    int scrolls = 0;
    while (!tester.any(finder) && scrolls < 10) {
      await tester.drag(find.byType(find.byType), Offset(0, -delta));
      await tester.pump();
      scrolls++;
    }
  }
}
