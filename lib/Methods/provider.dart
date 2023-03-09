import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProvider extends ChangeNotifier{
  bool _darkLight = false;
  bool _rememberMe = false;

  bool get darkLight => _darkLight;
  bool get rememberMe => _rememberMe;

  late SharedPreferences secureStorage;

  //Method to change
  void changeTheme(){
    _darkLight = !_darkLight;
    notifyListeners();
  }

  void setRememberMe()async{
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

}