import 'dart:convert';
import 'package:assignment/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class UserAuth with ChangeNotifier {
  static UserModel user = UserModel();

  Future<bool> isUserLogedIn() async {
    await getUserAuth();
    if (user.userId != null) {
      return true;
    }
    return false;
  }

  Future<void> saveUserAuth(UserModel userModel) async {
    user = userModel;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAuth', jsonEncode(userModel.toJson()));

    notifyListeners();
  }

  static Future<void> getUserAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userAuth') == true) {
      Map<String, dynamic> authUser = jsonDecode(prefs.getString('userAuth')!);
      user = UserModel.fromJson(authUser);
    }
  }

  static Future<void> clearUserAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = UserModel();
    prefs.clear();
  }
}


