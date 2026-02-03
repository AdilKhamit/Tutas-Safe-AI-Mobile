import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/ui/widgets/skeleton_loader.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('should display skeleton loader with default size', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonLoader();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonLoader), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints, isNotNull);
    });

    testWidgets('should display skeleton loader with custom size', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonLoader(
        width: 100,
        height: 50,
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('should display skeleton loader with custom borderRadius', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonLoader(
        width: 100,
        height: 100,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('should display skeleton card', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonCard();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(SkeletonLoader), findsWidgets);
    });
  });

  group('SkeletonList', () {
    testWidgets('should display skeleton list with default item count', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonList();

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(SkeletonCard), findsNWidgets(5)); // Default itemCount is 5
    });

    testWidgets('should display skeleton list with custom item count', (WidgetTester tester) async {
      // Arrange
      const widget = SkeletonList(itemCount: 3);

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(SkeletonCard), findsNWidgets(3));
    });
  });
}
