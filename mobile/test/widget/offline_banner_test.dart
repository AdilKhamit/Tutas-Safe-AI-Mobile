import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/ui/widgets/offline_banner.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('should not display when isOffline is false', (WidgetTester tester) async {
      // Arrange
      const widget = OfflineBanner(isOffline: false);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsNothing);
      expect(find.byType(OfflineBanner), findsOneWidget);
    });

    testWidgets('should display when isOffline is true', (WidgetTester tester) async {
      // Arrange
      const widget = OfflineBanner(isOffline: true);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Offline mode'), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      // Arrange
      bool retryCalled = false;
      final widget = OfflineBanner(
        isOffline: true,
        onRetry: () {
          retryCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      expect(retryCalled, isTrue);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      // Arrange
      const widget = OfflineBanner(
        isOffline: true,
        onRetry: null,
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
    });
  });
}
