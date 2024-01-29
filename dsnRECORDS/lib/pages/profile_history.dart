import 'package:flutter/material.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> _bookings = [];

  final String userBookingsTable = 'user_bookings';
  bool _dataFromREST = false;

  @override
  void initState() {
    super.initState();
    _loadUserIDAndBookings();
  }

  void _loadUserIDAndBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('id');
    _getUserBookings(userID!);
  }

  Future<void> _getUserBookings(int userID) async {
    try {
      final bookings = await REST.getUserBookings(userID);
      setState(() {
        _bookings = bookings.map((booking) {
          return {
            ...booking,
            'data': '${booking['data']}', // format data as string
          };
        }).toList();
      });
      _saveUserBookingsToLocalDB(userID, bookings);
      _dataFromREST = true;
    } catch (e) {
      print('Failed to load user bookings from REST API: $e');
      final bookings = await _getUserBookingsFromLocalDB(userID);
      setState(() {
        _bookings = bookings.map((booking) {
          return {
            ...booking,
            'data': '${booking['data']}', // format data as string
          };
        }).toList();
      });
    }
  }

  Future<void> _saveUserBookingsToLocalDB(int userID, List<dynamic> bookings) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('CREATE TABLE IF NOT EXISTS $userBookingsTable (id INTEGER PRIMARY KEY, user_id INTEGER, data TEXT, timerange TEXT)');
    await db.transaction((txn) async {
      for (final booking in bookings) {
        await txn.rawInsert('INSERT OR REPLACE INTO $userBookingsTable (id, user_id, data, timerange) VALUES (?, ?, ?, ?)', [booking['id'], userID, booking['data'], booking['timerange']]);
      }
    });
  }

  Future<List<dynamic>> _getUserBookingsFromLocalDB(int userID) async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $userBookingsTable WHERE user_id = ?', [userID]);
    return result.toList();
  }

  void _deleteBooking(int index) {
    final booking = _bookings[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение отмены"),
          content: Text("Вы действительно хотите отменить забронированное время?"),
          actions: <Widget>[
            TextButton(
              child: Text("Нет"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () async {
                await REST.deleteBooking(booking['id']);
                setState(() {
                  _bookings.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isDeletable(String bookingDate) {
    final now = DateTime.now();
    final parsedBookingDate = DateFormat('dd.MM.yyyy').parse(bookingDate);
    return parsedBookingDate.isAfter(now) || parsedBookingDate.isAtSameMomentAs(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Container(
            margin: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _bookings.isEmpty
                  ? Center(child: Text('Забронированное время не найдено'))
                : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return ListTile(
                  title: Text('Дата: ${booking['data']}'),
                  subtitle: Text('Время: ${booking['timerange']}'),
                  trailing: _dataFromREST == true && _isDeletable(booking['data'])
                      ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteBooking(index),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
