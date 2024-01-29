import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_platform/universal_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/bottom_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dsn_records/pages/admin_page.dart';
import 'package:dsn_records/pages/profile_page.dart';
import 'package:dsn_records/pages/timetable_page.dart';
import 'package:dsn_records/pages/review_page.dart';
import 'package:dsn_records/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int? selectedIndex;

  const HomePage({Key? key, this.selectedIndex}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String? userType;
  int _currentIndex = 0;

  final List<Widget> _children = [HomeScreen(), ScheduleScreen(), ProfileScreen(), ReviewScreen(), AdminScreen()];

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  void onTabTapped(int index) async {
    // если нажата вторая вкладка (SchedulePage)
    if (!UniversalPlatform.isWeb && index == 1) {
      bool isConnected = await checkConnection();
      if (!isConnected) {
        // если связи нет, отображаем диалоговое окно с сообщением об ошибке
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text('Проверьте подключение к сети'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }
    // если связь есть или нажата другая вкладка, переходим на соответствующую страницу
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _currentIndex = widget.selectedIndex ?? 0;
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
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
          ),
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: userType != "user" ? [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rate),
            label: 'Отзывы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Админ-панель',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings), // Иконка для вкладки "Настройки"
          //   label: 'Настройки',
          // ),
        ] : [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rate),
            label: 'Отзывы',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings), // Иконка для вкладки "Настройки"
          //   label: 'Настройки',
          // ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<String> _imagePaths = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
    'assets/images/7.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
            child: Column(
              children: [
                SizedBox(height: 16.0),
                Text(
                  'Добро пожаловать на студию dsn RECORDS!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'dsnrecords is a premier recording studio that offers top-quality audio production services for musicians, bands, and other clients. Our state-of-the-art facilities and experienced team of sound engineers ensure that every project we work on sounds amazing. Whether you need to record a full-length album, a single, or a podcast, we have the skills and expertise to make your vision a reality.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 400,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
              items: _imagePaths
                  .map((path) => Image.asset(
                path,
                width: MediaQuery.of(context).size.width > 600
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height > 600
                    ? MediaQuery.of(context).size.height * 0.5
                    : MediaQuery.of(context).size.height * 0.5,
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}