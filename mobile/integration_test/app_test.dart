import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tutas_ai_mobile/main.dart' as app;

/// Basic integration test to verify app starts
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app starts and shows onboarding or login', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app is running
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
