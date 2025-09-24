import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences? _sharedPreferences;

  static String prefName = "com.findmedicine.app";
  static String isIntro = "${prefName}isIntro";
  static String isLogin = "${prefName}isLogin";
  static String isWlc = "${prefName}isWlc";
  static String userDetails = "${prefName}userDetails"; // Add a key for user details

  PrefUtils() {
    // init();
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  /// Will clear all the data stored in preferences
  void clearPreferencesData() async {
    _sharedPreferences!.clear();
  }

  Future<void> setThemeData(String value) {
    return _sharedPreferences!.setString('themeData', value);
  }

  String getThemeData() {
    try {
      return _sharedPreferences!.getString('themeData')!;
    } catch (e) {
      return 'primary';
    }
  }

  static setIsIntro(bool sizes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isIntro, sizes);
  }

  static getIsIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool intValue = prefs.getBool(isIntro) ?? true;
    return intValue;
  }

  static setIsWlc(bool sizes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isWlc, sizes);
  }

  static getIsWlc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool intValue = prefs.getBool(isWlc) ?? true;
    return intValue;
  }

  static setIsLogin(bool sizes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLogin, sizes);
  }

  static getIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool intValue = prefs.getBool(isLogin) ?? false;
    return intValue;
  }

  // Method to save user details (like name, email, etc.)
  static Future<void> setUserDetails(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Storing user details as a JSON string
    await prefs.setString(userDetails, json.encode(userData));
  }

  // Method to retrieve user details
  static Future<Map<String, dynamic>?> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(userDetails);

    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }
}
