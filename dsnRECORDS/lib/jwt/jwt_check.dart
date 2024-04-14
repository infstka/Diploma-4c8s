import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';

class JWT {
  static Future<void> clearSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  static Future<void> checkTokenValidity(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      Fluttertoast.showToast(
        msg: 'Войдите для продолжения',
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
      return;
    }

    //проверка токена
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int expiryTimeInSeconds = decodedToken['exp'];
    DateTime expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeInSeconds * 1000);

    bool isTokenValid = DateTime.now().isBefore(expiryDateTime.add(Duration(seconds: 5)));
    if (!isTokenValid) {
      await clearSharedPreferences();
      Fluttertoast.showToast(
        msg: 'Сессия истекла. Войдите снова',
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }
  }
}