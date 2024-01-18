import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/widgets/user_image_picker.dart';

void main() {
  testWidgets('UserImagePicker displays default image and TextButton',
      (WidgetTester tester) async {
    // Define a dummy onPickImage function
    void dummyOnPickImage(File pickedImage) {}

    // Pump the UserImagePicker widget
    await tester.pumpWidget(MaterialApp(
      home: UserImagePicker(
        onPickImage: dummyOnPickImage,
        defaultImage: 'assets/images/imperial_logo.png',
      ),
    ));

    // Check for the presence of the CircleAvatar
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Check for the presence of the text 'Add Image', which is part of the TextButton
    expect(find.text('Add Image'), findsOneWidget);
  });

  // Add more tests as needed
}
