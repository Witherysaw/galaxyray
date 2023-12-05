import 'package:flutter/material.dart';

import './view/splash_screen.dart';

class FirebaseCrud extends StatelessWidget {
  const FirebaseCrud({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: SplashScreen(),
    );
  }
}
