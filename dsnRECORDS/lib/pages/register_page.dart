import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dsn_records/pages/login_page.dart';
import 'package:dsn_records/rest/rest_api.dart';

import '../widgets/auth_form_fields_widgets.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.grey, Colors.black87],
                  begin: const FractionalOffset(0.0, 1.0),
                  end: const FractionalOffset(0.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.repeated
              )
          ),
          height: heightOfScreen,
          child: Stack(children: <Widget>[
            Positioned(
              child: Container(),
              top: MediaQuery.of(context).size.height * .15,
              right: MediaQuery.of(context).size.width * .4,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                                controller: username,
                                data: Icons.person,
                                txtHint: "Имя пользователя",
                                obsecure: false,
                              ),
                              AuthFormFields(
                                controller: email,
                                data: Icons.email,
                                txtHint: "Email",
                                obsecure: false,
                              ),
                              AuthFormFields(
                                controller: password,
                                data: Icons.lock,
                                txtHint: "Пароль",
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
                          ElevatedButton(
                            onPressed: () {
                              String? emailError;
                              String? passwordError;

                              if (email.text.isEmpty || !email.text.contains('@')) {
                                emailError = 'Email должен быть типа example@example.example';
                              }

                              if (password.text.isEmpty || password.text.length < 8) {
                                passwordError = 'Пароль должен содержать не менее 8 символов';
                              }

                              if (emailError != null) {
                                Fluttertoast.showToast(msg: emailError, textColor: Colors.red);
                              } else if (passwordError != null) {
                                Fluttertoast.showToast(msg: passwordError, textColor: Colors.red);
                              } else {
                                doRegister(username.text, email.text, password.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40),
                            ),
                            child: Text(
                              "Зарегистрироваться",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15,),
                      _LoginText(),
                    ]),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ])),
    );
  }

  doRegister(String username, String user_email, String user_password) async {
    var res = await REST.userRegister(username, user_email, user_password);
    if (res['success']) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else if (res['message'] == 'User with this username or email already exists') {
      Fluttertoast.showToast(msg: 'Этот пользователь уже существует!', textColor: Colors.red);
    }
    else {
      Fluttertoast.showToast(msg: 'Попробуйте снова', textColor: Colors.red);
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
              ),
            ),
            Text(
              'Назад',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  Widget _LoginText() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Уже есть аккаунт? ',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            Text(
              'Войти',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
