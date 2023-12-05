import 'package:flutter/material.dart';

import '../controllers/auth.dart';
import 'auth_screens/login_screen.dart';
import 'constants.dart';
import 'others/profile.dart';
import 'task_screen/Amount.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    FinancialApp(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              FinancialApp().financialAppKey.currentState?.refreshPage();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
          child: Image.asset(
            'images/GRlogosm.png', // Adjust the path based on your project structure
            width: 20, // Adjust the width as needed
            height: 20, // Adjust the height as needed
          ),
        ),
        title: Text('Financial App'),
        backgroundColor: primaryColor,
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: () async {
        //       await UserAuth.clearUserAuth();
        //       if (mounted) {
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(builder: (cntxt) => const LoginScreen()),
        //               (route) => false,
        //         );
        //       }
        //     },
        //     icon: const Icon(Icons.logout),
        //
        //   ),
        // ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: darkCard,
        onTap: _onItemTapped,
      ),
    );
  }
}
