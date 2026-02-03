import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../lib/core/theme/app_theme.dart';
import '../../lib/core/l10n/app_localizations.dart';
import '../mocks/mocks.dart';

/// Helper class for widget testing
class WidgetTestHelpers {
  /// Create a test MaterialApp with localization
  static Widget createTestMaterialApp({
    required Widget child,
    Locale? locale,
  }) {
    return MaterialApp(
      locale: locale ?? const Locale('ru', 'RU'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  /// Create a test MaterialApp with ProviderScope
  static Widget createTestAppWithProviders({
    required Widget child,
    List<Override>? overrides,
    Locale? locale,
  }) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        locale: locale ?? const Locale('ru', 'RU'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Create a test MaterialApp with GoRouter
  static Widget createTestAppWithRouter({
    required GoRouter router,
    Locale? locale,
  }) {
    return MaterialApp.router(
      locale: locale ?? const Locale('ru', 'RU'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }

  /// Wait for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Find widget by type
  static T findWidget<T extends Widget>(WidgetTester tester) {
    return tester.widget<T>(find.byType(T));
  }

  /// Find widget by key
  static T findWidgetByKey<T extends Widget>(
    WidgetTester tester,
    Key key,
  ) {
    return tester.widget<T>(find.byKey(key));
  }

  /// Tap and wait for animations
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text and wait for animations
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll until visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    double delta = 100,
    Duration scrollDuration = const Duration(milliseconds: 100),
    int maxScrolls = 10,
  }) async {
    int scrolls = 0;
    while (!tester.any(finder) && scrolls < maxScrolls) {
      await tester.drag(find.byType(Scrollable), Offset(0, -delta));
      await tester.pump(scrollDuration);
      scrolls++;
    }
  }
}
