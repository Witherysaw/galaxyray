import 'dart:developer';

import 'package:assignment/view/task_screen/Amount.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../controllers/UserEmailProvider.dart';
import '../../controllers/auth.dart';
import '../../controllers/firestoreService.dart';
import '../../models/user.dart';
import '../../widgets/password_text_form_field.dart';
import '../constants.dart';
import '../nav.dart';
import './registration_screen.dart';
import '../task_screen/Amount.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late bool _isLoginInProgress;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _isLoginInProgress = false;
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userEmailProvider = Provider.of<UserEmailProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 50),
                Center(
                  child: Image.asset(
                    'images/GRlogo.png', // Adjust the path based on your project structure
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                ),
                Center(
                  child: Image.asset(
                    'images/text.png', // Adjust the path based on your project structure
                    width: 250, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'user@gmail.com',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                PasswordTextFormField(
                  labelText: 'Password',
                  passwordEditingController: _passwordController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter password.';
                    } else if (value!.length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Change the button color based on different states
                        if (states.contains(MaterialState.pressed)) {
                          return bgColor; // Color when the button is pressed
                        }
                        return primaryColor; // Default color
                      },
                    ),
                  ),
                  onPressed: _isLoginInProgress == true
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate() == true) {
                      userEmailProvider.setEnteredEmail(_emailController.text.trim());
                      print(_emailController.text);
                      String? userName = await _firestoreService.getUserName(_emailController.text.trim());
                      // Store the user's name
                      if (userName != null) {
                        userEmailProvider.setUserName(userName);
                      }
                      loginUser(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                    }
                  },
                  child: Visibility(
                    visible: _isLoginInProgress,
                    replacement: const Text('Login'),
                    child: const CircularProgressIndicator(),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Haven\'t account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (cntxt) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text('Create'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoginInProgress = true;
    if (mounted) {
      setState(() {});
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoginInProgress = false;
      if (mounted) {
        setState(() {});
      }
      log(userCredential.user.toString());
      if (userCredential.user?.emailVerified == false) {
        showToastMessage('Please varify your account.',
            color: Colors.red, actionLabel: 'SEND', action: () async {
          await userCredential.user?.sendEmailVerification();
          showToastMessage(
            'Varification URL is sent to your email.',
            color: Colors.green,
          );
        });
      } else if (userCredential.user?.emailVerified == true) {
        log('login success');
        // log(userCredential.user!.uid);
        // log(userCredential.user!.phoneNumber.toString());
        // log(userCredential.user.toString());
        final UserModel user = UserModel(
          userEmail: email,
          userId: userCredential.user!.uid,
        );
        await UserAuth().saveUserAuth(user);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (cntxt) => Nav()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('user-not-found') == true ||
          e.code.contains('wrong-password') == true) {
        showToastMessage('E-mail or Password is incorrect!', color: Colors.red);
        await UserAuth.clearUserAuth();
      }
    } catch (e) {
      showToastMessage(e.toString(), color: Colors.red);
    }

    _isLoginInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  void showToastMessage(String content,
      {Color color = Colors.green, VoidCallback? action, String? actionLabel}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                onPressed: () {
                  if (action != null) {
                    action();
                  }
                },
                label: actionLabel,
                textColor: Colors.white,
                backgroundColor: Colors.black38,
              ),
      ),
    );
  }
}
