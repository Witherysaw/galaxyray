import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/password_text_form_field.dart';
import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isCreateAccountInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'user@gmail.com',

                    fillColor: Colors.white,
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
                const SizedBox(height: 10),
                PasswordTextFormField(
                  labelText: 'Confirm Password',
                  passwordEditingController: _confirmPasswordController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter confirm password.';
                    } else if (value!.length < 8) {
                      return 'Password must be at least 8 characters.';
                    } else if (value != _passwordController.text) {
                      return 'Password and Confirm Password must be match.';
                    }
                    return null;
                  },
                  // Define the style for the focused and unfocused states
                   // Customize the fill color of the text field
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
                  onPressed: _isCreateAccountInProgress == true
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() == true) {
                            createUser(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ).then((value) {
                              if (value == true) {
                                log('-------------');
                                _formKey.currentState!.reset();
                                _nameController.clear();
                                _emailController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          }
                        },
                  child: const Text('Create Account'),

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
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

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    String rank = 'User',
  }) async {
    _isCreateAccountInProgress = true;
    if (mounted) {
      setState(() {});
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'rank' : rank,
        // Add any other fields you want to store
      });

      _isCreateAccountInProgress = false;

      if (mounted) {
        setState(() {});
      }

      showToastMessage('Account create completed.');
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();
      showToastMessage('Account activation URL has been sent to your email.');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code.contains('weak-password') == true) {
        showToastMessage('The password provided is too weak.', color: Colors.red);
      } else if (e.code.contains('email-already-in-use') == true) {
        showToastMessage('The account already exists for that email.', color: Colors.red);
      }
    } catch (e) {
      log(e.toString());
      showToastMessage(e.toString(), color: Colors.red);
    }

    _isCreateAccountInProgress = false;
    if (mounted) {
      setState(() {});
    }
    return false;
  }


  void showToastMessage(String content, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(content),
      ),
    );
  }
}


