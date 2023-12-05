import 'package:assignment/view/auth_screens/login_screen.dart';
import 'package:assignment/view/auth_screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('LoginScreen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(),
    ));

    // Verify the presence of certain widgets on the screen.

    // Verify the presence of Image widgets
    expect(find.byType(Image), findsNWidgets(2));

    // Verify the presence of TextFormField for email
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Verify the presence of ElevatedButton
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify the presence of Text and TextButton for registration
    expect(find.text('Haven\'t account?'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);

    // Test navigation to RegistrationScreen
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the RegistrationScreen
    expect(find.byType(RegistrationScreen), findsOneWidget);

  });
}
