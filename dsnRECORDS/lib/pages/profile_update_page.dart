import 'package:flutter/material.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dsn_records/widgets/update_profile_form_fields_widget.dart';
import '../jwt/jwt_check.dart';
import 'login_page.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  int? userID;

  @override
  void initState() {
    super.initState();
    _loadUserID();
  }

  Future<void> _loadUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('id');
    });
  }
  void clearSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  //контроллеры для полей ввода
  final _usernameController = TextEditingController();
  final _userPasswordController = TextEditingController();
  final _userEmailController = TextEditingController();

  Future<void> _saveData() async {
    JWT.checkTokenValidity(context);
    if (_formKey.currentState!.validate()) {
      final response = await REST.updateUser({
        'id': userID.toString(),
        'username': _usernameController.text.trim(),
        'user_email': _userEmailController.text.trim(),
        'user_password': _userPasswordController.text.trim(),
      });

      if (response['error'] != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text(response['error']),
              actions: [
                TextButton(
                  onPressed: () {
                    JWT.checkTokenValidity(context);
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // вызываем метод очистки SharedPreferences
        clearSharedPreferences();
        // переходим на страницу логина
        Route route = MaterialPageRoute(builder: (_) => LoginPage());
        Navigator.pushReplacement(context, route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.width > 600 ? 100.0 : 56.0,
        ),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Container(
            width: MediaQuery.of(context).size.width > 600
                ? MediaQuery.of(context).size.width * 0.5
                : MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height > 600
                ? MediaQuery.of(context).size.height * 0.7
                : MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/text black.png'),
                fit: BoxFit.contain,
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20.0),
            child: InkWell(
              onTap: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
              customBorder: CircleBorder(),
              child: SizedBox(
                width: 25.0,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Обновление профиля',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ]),
              SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ProfileFormFields(
                      controller: _usernameController,
                      data: Icons.person,
                      txtHint: "Username",
                      obsecure: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введите новое имя пользователя!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ProfileFormFields(
                      controller: _userPasswordController,
                      data: Icons.lock,
                      txtHint: "Password",
                      obsecure: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введите новый пароль!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ProfileFormFields(
                      controller: _userEmailController,
                      data: Icons.email,
                      txtHint: "Email",
                      obsecure: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Введите новую почту!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40),
                      ),
                      child: Text(
                        'Сохранить',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
