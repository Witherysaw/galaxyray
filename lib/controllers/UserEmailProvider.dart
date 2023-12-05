import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEmailProvider with ChangeNotifier {
  String _enteredEmail = '';
  String _userName = '';

  String get enteredEmail => _enteredEmail;
  String get userName => _userName;

  Future<void> setEnteredEmail(String email) async {
    _enteredEmail = email;
    // Save the entered email to shared preferences for persistence
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('enteredEmail', email);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    // Save the username to shared preferences for persistence
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> loadFromSharedPreferences() async {
    // Load entered email and username from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _enteredEmail = prefs.getString('enteredEmail') ?? '';
    _userName = prefs.getString('userName') ?? '';
    notifyListeners();
  }
}
