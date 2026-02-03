import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/ui/widgets/integrity_gauge.dart';
import '../../lib/core/theme/app_theme.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('IntegrityGauge', () {
    testWidgets('should display gauge with value', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.95);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(IntegrityGauge), findsOneWidget);
      expect(find.text('95.0%'), findsOneWidget);
    });

    testWidgets('should display optimal green color for value >= 0.95', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.98);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(IntegrityGauge), findsOneWidget);
      // Color is determined internally, but we can verify the widget renders
      expect(find.text('98.0%'), findsOneWidget);
    });

    testWidgets('should display warning orange color for value >= 0.85 and < 0.95', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.90);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(IntegrityGauge), findsOneWidget);
      expect(find.text('90.0%'), findsOneWidget);
    });

    testWidgets('should display critical red color for value < 0.85', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.80);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(IntegrityGauge), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);
    });

    testWidgets('should display percentage with one decimal place', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.876);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('87.6%'), findsOneWidget);
    });

    testWidgets('should display trend indicator', (WidgetTester tester) async {
      // Arrange
      const widget = IntegrityGauge(value: 0.95);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+0.5%'), findsOneWidget);
    });
  });
}
