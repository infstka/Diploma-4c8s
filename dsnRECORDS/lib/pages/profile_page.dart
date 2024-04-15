import 'package:dsn_records/jwt/jwt_check.dart';
import 'package:flutter/material.dart';
import 'package:dsn_records/pages/login_page.dart';
import 'package:dsn_records/pages/profile_update_page.dart';
import 'package:dsn_records/pages/profile_history.dart';
import 'package:dsn_records/pages/profile_rental_history.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void clearSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? userID;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserID();
    _loadUserName();
    _loadUserEmail();
  }

  Future<void> _loadUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('id');
    });
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username');
    });
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16.0),
            Text(
              userName ?? 'N/A',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Email: ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail ?? 'N/A',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.0),
            SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.6,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  JWT.checkTokenValidity(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => UpdateProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text(
                  'Обновить профиль',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.6,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  JWT.checkTokenValidity(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => BookingsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text(
                  'Посмотреть бронирования',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.6,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  JWT.checkTokenValidity(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => RentalsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text(
                  'Просмотреть заявки на аренду',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.6,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  JWT.checkTokenValidity(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Выход'),
                      content: Text('Вы уверены, что хотите выйти?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            JWT.checkTokenValidity(context);
                            Navigator.of(context).pop();
                          },
                          child: Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () async {
                            JWT.checkTokenValidity(context);
                            clearSharedPreferences();
                            Route route = MaterialPageRoute(builder: (_) => LoginPage());
                            Navigator.pushReplacement(context, route);
                          },
                          child: Text('Да'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text(
                  'Выйти',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                JWT.checkTokenValidity(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Удалить профиль?'),
                    content:
                        Text('Вы уверены, что хотите удалить свой профиль?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          JWT.checkTokenValidity(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () async {
                          JWT.checkTokenValidity(context);
                          await REST.deleteUser(userID!);
                          clearSharedPreferences();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        child: Text('Удалить'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Удалить профиль',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
