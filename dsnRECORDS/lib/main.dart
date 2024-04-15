import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dsn_records/pages/home_page.dart';
import 'package:dsn_records/pages/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:dcdg/dcdg.dart';

import 'jwt/jwt_check.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dsn RECORDS!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late SharedPreferences _sharedPreferences;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // После завершения анимации, запускаем проверку токена.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isLogin();
      }
    });
  }

  void isLogin() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    String? token = _sharedPreferences.getString('token');

    if (token == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int expiryTimeInSeconds = decodedToken['exp'];
    DateTime expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeInSeconds * 1000);

    if (DateTime.now().isAfter(expiryDateTime)) {
      await JWT.clearSharedPreferences();
      Fluttertoast.showToast(
        msg: 'Сессия истекла. Войдите снова',
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.grey, Colors.black87],
            begin: const FractionalOffset(0.0, 1.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.repeated,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: _animation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/dsnrecords logo black no bg.png",
                      width: MediaQuery.of(context).size.width > 600
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height > 600
                          ? MediaQuery.of(context).size.height * 0.7
                          : MediaQuery.of(context).size.height * 0.5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

