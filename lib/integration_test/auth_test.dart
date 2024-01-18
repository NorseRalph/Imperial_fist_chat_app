import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chat_app/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Add Keys to your email and password fields in the actual widget to be able to find them here
  final emailFieldFinder = find.byKey(const Key('emailField'));
  final passwordFieldFinder = find.byKey(const Key('passwordField'));

  setUpAll(() async {
    // Initialize Firebase here
    await Firebase.initializeApp();
    // Set up Firebase emulator only if necessary
     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
     FirebaseFirestore.instance.settings = Settings(host: 'localhost:8080', sslEnabled: false);
  });

  app.main();

  group('Auth Screen Tests', () {
    setUp(() async {
      // Ensure each test starts with a fresh instance
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      // Clear the Firestore data if you are using Firestore in your app
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }
    });

    // Additional tests for login, password
    testWidgets('Login test', (tester) async {
      app.main(); // Run the main app
      await tester.pumpAndSettle();

      // Switch to Login if necessary
      final switchToLoginButtonFinder = find.text('I already have an account');
      await tester.ensureVisible(switchToLoginButtonFinder);
      await tester.tap(switchToLoginButtonFinder);
      await tester.pumpAndSettle();

      // Fill in the login form
      await tester.enterText(emailFieldFinder, 'test@example.com');
      await tester.enterText(passwordFieldFinder, 'Test@1234');

      // Tap the login button
      final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginButtonFinder);
      await tester.tap(loginButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the user is successfully logged in and navigated to the next screen
      // Update the text 'Welcome back, test_username!' to match your app's response on successful login
      expect(find.text('Welcome back, test_username!'), findsOneWidget);
    });

    testWidgets('Password reset test', (tester) async {
      app.main(); // Run the main app
      await tester.pumpAndSettle();

      // Switch to Login if necessary and then to Forgot password
      final forgotPasswordButtonFinder = find.text('Forgot password?');
      await tester.ensureVisible(forgotPasswordButtonFinder);
      await tester.tap(forgotPasswordButtonFinder);
      await tester.pumpAndSettle();

      // Fill in the email form
      await tester.enterText(emailFieldFinder, 'test@example.com');

      // Tap the reset password button
      final resetPasswordButtonFinder =
          find.widgetWithText(ElevatedButton, 'Reset Password');
      await tester.ensureVisible(resetPasswordButtonFinder);
      await tester.tap(resetPasswordButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the user is shown a confirmation message
      // Update the text 'Password reset email sent!' to match your app's response on successful password reset
      expect(find.text('Password reset email sent!'), findsOneWidget);
    });
  });
}
