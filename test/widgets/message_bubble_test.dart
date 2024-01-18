import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:chat_app/widgets/theme_notifier.dart';

void main() {
  testWidgets('MessageBubble displays username and message',
      (WidgetTester tester) async {
    // Mock ThemeNotifier
    final themeNotifier = ThemeNotifier(ThemeData.light());

    // Define the test message and username
    const userName = 'John Doe';
    const message = 'Hello, World!';

    // Build the MessageBubble widget within a provider for ThemeNotifier
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>.value(
        value: themeNotifier,
        child: MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              userName: userName,
              userImage: '', // Empty string for simplicity
              message: message,
              isMe: true,
            ),
          ),
        ),
      ),
    );

    // Wait for any animations or image loading if necessary
    await tester.pumpAndSettle();

    // Verify that the user's name and message are displayed
    expect(find.text(userName), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    // Verify that a CircleAvatar is present
    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
