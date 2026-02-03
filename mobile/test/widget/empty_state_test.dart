import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../lib/ui/widgets/empty_state.dart';
import '../../lib/core/theme/app_theme.dart';
import '../../lib/core/l10n/app_localizations.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('should display icon and title', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyState(
        icon: Icons.inbox,
        title: 'No items',
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyState(
        icon: Icons.inbox,
        title: 'No items',
        subtitle: 'Add your first item',
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
    });

    testWidgets('should display action button when actionLabel and onAction provided', (WidgetTester tester) async {
      // Arrange
      bool actionCalled = false;
      const widget = EmptyState(
        icon: Icons.inbox,
        title: 'No items',
        actionLabel: 'Add Item',
        onAction: _mockAction,
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap action button
      await tester.tap(find.text('Add Item'));
      await tester.pump();
    });

    testWidgets('should not display action button when actionLabel is null', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyState(
        icon: Icons.inbox,
        title: 'No items',
        onAction: _mockAction,
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should use custom icon color when provided', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyState(
        icon: Icons.error,
        title: 'Error',
        iconColor: AppTheme.criticalRed,
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.error));
      expect(icon.color, equals(AppTheme.criticalRed));
    });
  });

  group('EmptyListState', () {
    testWidgets('should display list empty state', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyListState(
        title: 'No assets',
        subtitle: 'Assets will appear after sync',
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No assets'), findsOneWidget);
      expect(find.text('Assets will appear after sync'), findsOneWidget);
    });

    testWidgets('should call onAction when action button is tapped', (WidgetTester tester) async {
      // Arrange
      bool actionCalled = false;
      final widget = EmptyListState(
        title: 'No assets',
        actionLabel: 'Add Asset',
        onAction: () {
          actionCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.tap(find.text('Add Asset'));
      await tester.pump();

      // Assert
      expect(actionCalled, isTrue);
    });
  });

  group('EmptyErrorState', () {
    testWidgets('should display error state with message', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyErrorState(
        message: 'Failed to load data',
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      // Arrange
      bool retryCalled = false;
      final widget = EmptyErrorState(
        message: 'Network error',
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
      expect(retryCalled, isTrue);
    });

    testWidgets('should use critical red color for error icon', (WidgetTester tester) async {
      // Arrange
      const widget = EmptyErrorState(
        message: 'Error occurred',
      );

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, equals(AppTheme.criticalRed));
    });
  });

  group('EmptySearchState', () {
    testWidgets('should display search empty state', (WidgetTester tester) async {
      // Arrange
      const widget = EmptySearchState(query: 'test');

      // Act
      await tester.pumpWidget(
        WidgetTestHelpers.createTestMaterialApp(child: widget),
      );
      await tester.pumpAndSettle();

      // Assert
      // EmptySearchState uses EmptyState internally, so check for EmptyState
      expect(find.byType(EmptyState), findsOneWidget);
      // The icon is passed to EmptyState, so it should be rendered
      expect(find.byType(EmptySearchState), findsOneWidget);
    });
  });
}

void _mockAction() {
  // Mock action for testing
}
