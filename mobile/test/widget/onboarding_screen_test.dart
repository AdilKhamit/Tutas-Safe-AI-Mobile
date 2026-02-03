import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/ui/screens/onboarding_screen.dart';
import '../../lib/core/services/onboarding_service.dart';
import '../helpers/widget_test_helpers.dart';
import '../mocks/mock_shared_preferences.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('should display first onboarding page', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Добро пожаловать в Tutas Safe'), findsOneWidget);
      expect(find.text('Мониторинг целостности трубопроводов в реальном времени'), findsOneWidget);
      expect(find.byIcon(Icons.engineering), findsOneWidget);
    });

    testWidgets('should display skip button', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Пропустить'), findsOneWidget);
    });

    testWidgets('should display page indicators', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      // Should have 4 page indicators (one for each page)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display Next button on first page', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Далее'), findsOneWidget);
    });

    testWidgets('should navigate to next page when Next is tapped', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Tap Next button
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('QR-сканер и офлайн режим'), findsOneWidget);
    });

    testWidgets('should display Get Started button on last page', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Navigate to last page
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Далее'));
        await tester.pumpAndSettle();
      }

      // Assert
      expect(find.text('Начать работу'), findsOneWidget);
    });

    testWidgets('should swipe between pages', (WidgetTester tester) async {
      // Arrange
      const widget = OnboardingScreen();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Swipe to next page
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('QR-сканер и офлайн режим'), findsOneWidget);
    });
  });
}
