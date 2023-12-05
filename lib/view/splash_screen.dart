import 'package:flutter/material.dart';

import '../controllers/auth.dart';
import './auth_screens/login_screen.dart';
import './task_screen/Amount.dart';
import 'nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    screenNavigate();
  }

  Future<void> screenNavigate() async {
    bool isUserLogedIn = await UserAuth().isUserLogedIn();

    Future.delayed(const Duration(seconds: 3)).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (cntxt) =>
              isUserLogedIn == false ? const LoginScreen() : Nav(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: Image.asset(
        'images/GRlogo.png', // Adjust the path based on your project structure
        width: 100.0, // Set the desired width
        height: 100.0, // Set the desired height
        // You can customize the image properties as needed
      ),
      // child: const FlutterLogo(
      //   size: 5,
      //   duration: Duration(seconds: 5),
      //   curve: Curves.bounceIn,
      //   textColor: Colors.blue,
      //   style: FlutterLogoStyle.horizontal,
      // ),
    );
  }
}
