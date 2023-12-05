import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth.dart';
import '../constants.dart';
import '../auth_screens/login_screen.dart';
import 'settings.dart';
import '../../controllers/UserEmailProvider.dart';
import '../../controllers/firestoreService.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  String username = "";
  String useremail = "";
  String userrank = "";

  @override
  void initState() {
    super.initState();
    _loadUsernameAndrank();
  }

  Future<void> _loadUsernameAndrank() async {
    String? userEmail = Provider.of<UserEmailProvider>(context, listen: false).enteredEmail;
    print(userEmail);
    String? userName = await _firestoreService.getUserName(userEmail);
    String? userRank = await _firestoreService.getUserRank(userEmail);
    print(userName);

    setState(() {
      username = userName!;
      useremail = userEmail!;
      userrank = userRank!;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 26),
              _buildProfilePicture(),
              const SizedBox(height: 16),
              _buildProfileDetails(),
              const SizedBox(height: 16),
              _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            children: [
              Text(
                'Name: ',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Text(
                '$username',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                'Email: ',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 3),
              Text(
                '$useremail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                'Rank: ',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '$userrank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return SizedBox(
      height: 150,
      width: 150,
      child: CircleAvatar(
        backgroundColor: darkCard,
        child: Icon(Icons.person, size: 150,)
      ),
    );
  }


  Widget _buildSignOutButton(BuildContext context) {
    return Card(

      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(
          Icons.exit_to_app,
          color: Colors.red,
          size: 30,
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 20,
            color: Colors.red,
          ),
        ),
        onTap: () {
          _showSignOutConfirmationDialog(context);
        },
      ),
    );
  }

  void _showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await UserAuth.clearUserAuth();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (cntxt) => const LoginScreen()),
                                (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
