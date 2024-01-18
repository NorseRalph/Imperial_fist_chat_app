import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:chat_app/widgets/theme_notifier.dart';

// A simple mock for ThemeNotifier that we'll use in the tests.
// A mock for ThemeNotifier that we'll use in the tests.
class MockThemeNotifier extends ThemeNotifier {
  MockThemeNotifier() : super(ThemeData.light());
}

void main() {
  // A helper method to create a testable widget with required providers and MaterialApp
  Widget makeTestableWidget({required Widget child}) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => MockThemeNotifier(),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('NewMessage Widget Tests', () {
    testWidgets(
        'TextField and Send IconButton are present when widget is created',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: NewMessage()));

      // Verify that a TextField and IconButton are present in the widget tree
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('Send IconButton is initially disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: NewMessage()));

      // Find IconButton by looking for the widget that uses the Icons.send icon.
      final IconButton sendButton = tester.widget(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && (widget.icon as Icon).icon == Icons.send,
        ),
      );

      // Verify that the IconButton is disabled (onPressed should be null).
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('Send IconButton enables when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: NewMessage()));

      // Enter text to enable the send button
      await tester.enterText(find.byType(TextField), 'Test Message');
      await tester.pump();

      // Fetch the IconButton after pumping to get the latest state
      final IconButton sendButton = tester.firstWidget(find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.send));

      // The send button should now be enabled
      expect(sendButton.onPressed, isNotNull);
    });

    // More tests can be added as needed
  });
}
