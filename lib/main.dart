import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './app.dart';
import 'controllers/UserEmailProvider.dart';
// Adjust the import based on your project structure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create an instance of UserEmailProvider
  UserEmailProvider userEmailProvider = UserEmailProvider();

  // Load data from shared preferences
  await userEmailProvider.loadFromSharedPreferences();

  runApp(
    ChangeNotifierProvider.value(
      value: userEmailProvider,
      child: FirebaseCrud(),
    ),
  );
}

