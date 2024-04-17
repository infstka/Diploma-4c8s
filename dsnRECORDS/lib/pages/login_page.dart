import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dsn_records/pages/home_page.dart';
import 'package:dsn_records/pages/register_page.dart';
import 'package:dsn_records/widgets/auth_form_fields_widgets.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late SharedPreferences _sharedPreferences;

  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;
    return Material(
        child: Container(
            height: heightOfScreen,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Colors.grey, Colors.black87],
                    begin: const FractionalOffset(0.0, 1.0),
                    end: const FractionalOffset(0.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.repeated)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 80,
                ),
                Container(
                  alignment: Alignment.center,
                  child: MediaQuery.of(context).size.width > 768
                      ? Image.asset(
                    "assets/images/dsnrecords_logo_black_no_bg.png",
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                  )
                      : Image.asset(
                    "assets/images/dsnrecords_logo_black_no_bg.png",
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthFormFields(
                          controller: _emailController,
                          data: Icons.email,
                          txtHint: "Email",
                          obsecure: false,
                        ),
                        AuthFormFields(
                          controller: _passwordController,
                          data: Icons.lock,
                          txtHint: "Password",
                          obsecure: true,
                        )
                      ],
                    )),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text("Forgot password", style: TextStyle(color: Colors.white, fontSize: 15),),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty
                            ? doLogin(
                            _emailController.text, _passwordController.text)
                            : Fluttertoast.showToast(
                            msg: 'Необходимо заполнить все поля!',
                            textColor: Colors.red,
                            backgroundColor: Colors.white,);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40),
                      ),
                      child: Text(
                        "Войти",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Еще нет аккаунта? ',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        'Зарегистрируйтесь',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  doLogin(String user_email, String user_password) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    var res = await REST.userLogin(user_email.trim(), user_password.trim());
    print(res.toString());

    if (res['success']) {
      String token = res['token'];

      _sharedPreferences.setString('token', token);

      int isBlocked = res['user'][0]['blocked'];

      if (isBlocked == 1) {
        Fluttertoast.showToast(
            msg: "Ваш аккаунт был заблокирован!",
            textColor: Colors.red,
            backgroundColor: Colors.white,
        );
      } else {
        String userEmail = res['user'][0]['user_email'];
        int userID = res['user'][0]['id'];
        String userName = res['user'][0]['username'];
        String userType = res['user'][0]['user_type'];
        _sharedPreferences.setInt('id', userID);
        _sharedPreferences.setString('user_email', userEmail);
        _sharedPreferences.setString('username', userName);
        _sharedPreferences.setString('user_type', userType);

        Route route = MaterialPageRoute(builder: (_) => HomePage());
        Navigator.pushReplacement(context, route);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Неверные данные! Попробуйте снова",
        textColor: Colors.red,
        backgroundColor: Colors.white,
      );
    }
  }
}
