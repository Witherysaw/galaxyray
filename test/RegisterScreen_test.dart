
import 'package:assignment/view/auth_screens/registration_screen.dart';
import 'package:assignment/widgets/password_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Registration Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen()));

    // Verify the presence of UI elements on the screen
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Have an account?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Test the Full Name text field
    final Finder nameTextFieldFinder = find.widgetWithText(TextFormField, 'Full Name');
    await tester.enterText(nameTextFieldFinder, 'John Doe');
    expect(find.text('John Doe'), findsOneWidget);

    // Test the E-mail text field
    final Finder emailTextFieldFinder = find.widgetWithText(TextFormField, 'E-mail');
    await tester.enterText(emailTextFieldFinder, 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);

    // Test PasswordTextFormField
    final Finder passwordTextFieldFinder = find.widgetWithText(PasswordTextFormField, 'Password');
    await tester.enterText(passwordTextFieldFinder, 'password123');
    expect(find.text('password123'), findsOneWidget);

    // Test Confirm Password text field
    final Finder confirmPasswordTextFieldFinder =
    find.widgetWithText(PasswordTextFormField, 'Confirm Password');

    // Tap the "Create Account" button
    final createAccountButtonFinder = find.byType(ElevatedButton);
    await tester.tap(createAccountButtonFinder);
    await tester.pump();
  });
}
