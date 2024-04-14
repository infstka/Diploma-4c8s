import 'package:flutter/material.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../jwt/jwt_check.dart';

class RentalsPage extends StatefulWidget {
  @override
  _RentalsPageState createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  List<dynamic> _rentals = [];

  final String userRentalsTable = 'user_rentals';
  bool _userRentalsFromREST = false;

  @override
  void initState() {
    super.initState();
    _loadUserIDAndRentals();
  }

  void _loadUserIDAndRentals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('id');
    _getUserRentals(userID!);
  }

  Future<void> _getUserRentals(int userID) async {
    try {
      List<dynamic> updatedRentals = [];
      final List<dynamic> fetchedRentals = await REST.getUserRentals(userID);
      updatedRentals.addAll(fetchedRentals);
      setState(() {
        _rentals = updatedRentals;
        _userRentalsFromREST = true;
      });
      await _saveUserRentalsToLocalDB(updatedRentals, userID);
    } catch (error) {
      print('Failed to load user rentals from REST API: $error');
      final rentals = await _getUserRentalsFromLocalDB(userID);
      print('Loading user rentals from local database...');
      setState(() {
        _rentals = rentals;
        _userRentalsFromREST = false;
      });
    }
  }

  Future<void> _saveUserRentalsToLocalDB(List<dynamic> rentals, int userID) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $userRentalsTable (id INTEGER PRIMARY KEY, userID INTEGER, fullname TEXT, phone TEXT, start_date TEXT, end_date TEXT, eq_names TEXT)');
    await db.transaction((txn) async {
      for (final rental in rentals) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $userRentalsTable (id, userID, fullname, phone, start_date, end_date, eq_names) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [
              rental['id'],
              rental['user_id'],
              rental['fullname'],
              rental['phone'],
              rental['start_date'],
              rental['end_date'],
              rental['eq_names'],
            ]);
      }
    });
  }

  Future<List<dynamic>> _getUserRentalsFromLocalDB(int userID) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $userRentalsTable (id INTEGER PRIMARY KEY, userID INTEGER, fullname TEXT, phone TEXT, start_date TEXT, end_date TEXT, eq_names TEXT)');
    final result = await db.rawQuery('SELECT * FROM $userRentalsTable WHERE userID = ?', [userID]); // фильтруем по userID
    return result.toList();
  }

  Future<void> _recreateUserRentalsTable() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $userRentalsTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $userRentalsTable (id INTEGER PRIMARY KEY, fullname TEXT, phone TEXT, start_date TEXT, end_date TEXT, eq_names TEXT)');
  }

  void _deleteRental(int index) {
    final rental = _rentals[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение удаления"),
          content: Text("Вы действительно хотите удалить эту заявку?"),
          actions: <Widget>[
            TextButton(
              child: Text("Нет"),
              onPressed: () {
                Navigator.of(context).pop();
                JWT.checkTokenValidity(context);
              },
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () async {
                JWT.checkTokenValidity(context);
                try {
                  await REST.deleteRental(rental['id']);
                  setState(() {
                    _rentals.removeAt(index);
                  });
                } catch (e) {
                  print('Failed to delete rental: $e');
                }
                _recreateUserRentalsTable();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRentalDetailsDialog(Map<String, dynamic> rental) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Заявка №${rental['id']}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ФИО: ${rental['fullname']}'),
              Text('Телефон: ${rental['phone']}'),
              Text('Дата начала: ${rental['start_date']}'),
              Text('Дата конца: ${rental['end_date']}'),
              Text('Оборудование:'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (rental['eq_names'] as String)
                    .split(', ')
                    .map<Widget>((eqName) {
                  return Text('- $eqName');
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
            ),
            if (_userRentalsFromREST == true && _isDeletable(rental['start_date']))
              TextButton(
                onPressed: () {
                  JWT.checkTokenValidity(context);
                  _deleteRental(_rentals.indexOf(rental));
                },
                child: Text('Удалить'),
              ),
          ],
        );
      },
    );
  }

  bool _isDeletable(String rentalStartDate) {
    final now = DateTime.now();
    final parsedRentalStartDate = DateFormat('dd.MM.yyyy').parse(rentalStartDate);
    return parsedRentalStartDate.isAfter(now) || parsedRentalStartDate.isAtSameMomentAs(now);
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
      body: _rentals.isEmpty
          ? Center(child: Text('Нет заявок пользователя'))
          : ListView.builder(
        itemCount: _rentals.length,
        itemBuilder: (context, index) {
          final rental = _rentals[index];
          return InkWell(
            onTap: () {
              JWT.checkTokenValidity(context);
              _showRentalDetailsDialog(rental);
            },
            child: ListTile(
              title: Text('Заявка №${rental['id']}'),
            ),
          );
        },
      ),
    );
  }
}