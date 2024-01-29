import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_platform/universal_platform.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _users = [];
  List<dynamic> _blocked_users = [];
  List<dynamic> _bookings = [];
  List<dynamic> _bookings_archive = [];
  int? userID;
  String? userType;

  final String usersTable = 'users';
  final String blockedUsersTable = 'blocked_users';
  final String bookingsTable = 'bookings';
  final String deletedBookingsTable = 'bookings_archive';
  bool _dataFromREST = false;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _getUsers();
    _getBlockedUsers();
    _getCurrentUser();
    _getBookings();
    _getDeletedBookings();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> _getUsers() async {
    // if (!UniversalPlatform.isWeb) {
    //   final users = await _getUsersFromLocalDB();
    //   setState(() {
    //     _users = users;
    //   });
    // }
    try {
      final users = await REST.getUsers();
      setState(() {
        _users = users.map((user) {
          final userType = user['user_type'] ?? 'user';
          return {
            ...user,
            'user_type': userType,
          };
        }).toList();
      });
      _saveUsersToLocalDB(users);
      _dataFromREST = true;
    } catch (e) {
      print('Failed to load users from REST API: $e');
      final users = await _getUsersFromLocalDB();
      setState(() {
        _users = users;
      });
    }
  }

  Future<void> _saveUsersToLocalDB(List<dynamic> users) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $usersTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $usersTable (id INTEGER PRIMARY KEY, username TEXT, user_email TEXT, user_type TEXT)');
    await db.transaction((txn) async {
      for (final user in users) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $usersTable (id, username, user_email, user_type) VALUES (?, ?, ?, ?)',
            [
              user['id'],
              user['username'],
              user['user_email'],
              user['user_type']
            ]);
      }
    });
  }

  Future<List<dynamic>> _getUsersFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $usersTable');
    return result.toList();
  }

  Future<void> _getBlockedUsers() async {
    // if (!UniversalPlatform.isWeb) {
    //   final blocked_users = await _getBlockedUsersFromLocalDB();
    //   setState(() {
    //     _blocked_users = blocked_users;
    //   });
    // }
    try {
      final blocked_users = await REST.getBlockedUsers();
      setState(() {
        _blocked_users = blocked_users;
      });
      _saveBlockedUsersToLocalDB(blocked_users);
      _dataFromREST = true;
    } catch (e) {
      print('Failed to load blocked users from REST API: $e');
      final blocked_users = await _getBlockedUsersFromLocalDB();
      setState(() {
        _blocked_users = blocked_users;
      });
    }
  }

  Future<void> _saveBlockedUsersToLocalDB(List<dynamic> blocked_users) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $blockedUsersTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $blockedUsersTable (id INTEGER PRIMARY KEY, username TEXT, user_email TEXT, user_type TEXT)');
    await db.transaction((txn) async {
      for (final blocked_user in blocked_users) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $blockedUsersTable (id, username, user_email, user_type) VALUES (?, ?, ?, ?)',
            [
              blocked_user['id'],
              blocked_user['username'],
              blocked_user['user_email'],
              blocked_user['user_type']
            ]);
      }
    });
  }

  Future<List<dynamic>> _getBlockedUsersFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $blockedUsersTable');
    return result.toList();
  }

  void _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('id');
    });
  }

  void _deleteUser(int id) async {
    final result = await REST.deleteUser(id);
    if (result['success']) {
      setState(() {
        _users.removeWhere((user) => user['id'] == id);
        _getUsers();
        _getBookings();
        _getDeletedBookings();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  void _blockUser(int id) async {
    final result = await REST.blockUser(id);
    if (result['success']) {
      setState(() {
        _users.removeWhere((user) => user['id'] == id);
        _getUsers();
        _getBlockedUsers();
        _getBookings();
        _getDeletedBookings();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  void _unblockUser(int id) async {
    final result = await REST.unblockUser(id);
    if (result['success']) {
      setState(() {
        _blocked_users.removeWhere((user) => user['id'] == id);
        _getUsers();
        _getBlockedUsers();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  void _setAdmin(int id) async {
    final result = await REST.setAdmin(id);
    if (result['success']) {
      setState(() {
        _getUsers();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  void _setUser(int id) async {
    final result = await REST.setUser(id);
    if (result['success']) {
      setState(() {
        _getUsers();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  Future<void> _getBookings() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // if (!UniversalPlatform.isWeb) {
    //   final bookings = await _getBookingsFromLocalDB();
    //   setState(() {
    //     _bookings = bookings;
    //   });
    // }
    try {
      final bookings = await REST.getBookings();
      final filteredBookings = bookings.where((booking) {
        final parsedBookingDate =
            DateFormat('dd.MM.yyyy').parse(booking['data']);
        return parsedBookingDate.isAfter(today) ||
            parsedBookingDate.isAtSameMomentAs(today);
      }).toList();
      setState(() {
        _bookings = filteredBookings;
      });
      _saveBookingsToLocalDB(filteredBookings);
      _dataFromREST = true;
    } catch (e) {
      print('Failed to load bookings from REST API: $e');
      final bookings = await _getBookingsFromLocalDB();
      setState(() {
        _bookings = bookings;
      });
    }
  }

  Future<void> _saveBookingsToLocalDB(List<dynamic> bookings) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $bookingsTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $bookingsTable (id INTEGER PRIMARY KEY, username TEXT, data TEXT, timerange TEXT)');
    await db.transaction((txn) async {
      for (final booking in bookings) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $bookingsTable (id, username, data, timerange) VALUES (?, ?, ?, ?)',
            [
              booking['id'],
              booking['username'],
              booking['data'],
              booking['timerange']
            ]);
      }
    });
  }

  Future<List<dynamic>> _getBookingsFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $bookingsTable');
    return result.toList();
  }

  bool _isDeletable(String bookingDate) {
    return true;
  }

  void _deleteBooking(dynamic booking) {
    final bookingId = booking['id'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение отмены"),
          content:
              Text("Вы действительно хотите отменить забронированное время?"),
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
                await REST.deleteBooking(bookingId);
                final index = _bookings.indexOf(booking);
                setState(() {
                  _bookings.removeAt(index);
                });
                _getDeletedBookings();
                _getBookings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getDeletedBookings() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // if (!UniversalPlatform.isWeb) {
    //   final bookings_archive = await _getArchivedBookingsFromLocalDB();
    //   setState(() {
    //     _bookings_archive = bookings_archive;
    //   });
    // }
    try {
      final bookings_archive = await REST.getDeletedBookings();
      final filteredBookings = bookings_archive.where((booking_archive) {
        final parsedBookingDate =
            DateFormat('dd.MM.yyyy').parse(booking_archive['data']);
        return parsedBookingDate.isAfter(today) ||
            parsedBookingDate.isAtSameMomentAs(today);
      }).toList();
      setState(() {
        _bookings_archive = filteredBookings;
      });
      _saveArchivedBookingsToLocalDB(filteredBookings);
      _dataFromREST = true;
    } catch (e) {
      print('Failed to load bookings from REST API: $e');
      final bookings_archive = await _getArchivedBookingsFromLocalDB();
      setState(() {
        _bookings_archive = bookings_archive;
      });
    }
  }

  Future<void> _saveArchivedBookingsToLocalDB(
      List<dynamic> bookings_archive) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $deletedBookingsTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $deletedBookingsTable (id INTEGER PRIMARY KEY, username TEXT, data TEXT, timerange TEXT)');
    await db.transaction((txn) async {
      for (final booking_archive in bookings_archive) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $deletedBookingsTable (id, username, data, timerange) VALUES (?, ?, ?, ?)',
            [
              booking_archive['id'],
              booking_archive['username'],
              booking_archive['data'],
              booking_archive['timerange']
            ]);
      }
    });
  }

  Future<List<dynamic>> _getArchivedBookingsFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $deletedBookingsTable');
    return result.toList();
  }

  void _restoreBooking(dynamic booking_archive) {
    final bookingId = booking_archive['id'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение восстановления"),
          content: Text("Восстановить отмененное время?"),
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
                await REST.restoreBooking(bookingId);
                final index = _bookings_archive.indexOf(booking_archive);
                setState(() {
                  _bookings_archive.removeAt(index);
                });
                _getBookings();
                _getDeletedBookings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 4, // количество папок
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (userType == "owner") {
                    return ExpansionTile(
                      title: Text('Пользователи'),
                      children: _users.map((user) {
                        final userType = user['user_type'];
                        final bool isCurrentUser = user['id'] == userID;
                        return ListTile(
                          title: Text(user['username']),
                          subtitle: userType == 'owner'
                              ? Text("Владелец\n${user['user_email']}")
                              : userType == 'admin'
                                  ? Text("Администратор\n${user['user_email']}")
                                  : Text(user['user_email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrentUser) Text("Это вы"),
                              if (userType != 'owner' && _dataFromREST == true)
                                Tooltip(
                                  message: 'Удалить пользователя',
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteUser(user['id']),
                                  ),
                                ),
                              if (userType != 'owner' && _dataFromREST == true)
                                Tooltip(
                                  message: 'Заблокировать пользователя',
                                  child: IconButton(
                                    icon: Icon(Icons.block),
                                    onPressed: () => _blockUser(user['id']),
                                  ),
                                ),
                              if (userType == 'user' && _dataFromREST == true)
                                Tooltip(
                                  message: 'Назначить администратором',
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_circle_up),
                                    onPressed: () => _setAdmin(user['id']),
                                  ),
                                ),
                              if (userType == 'admin' && _dataFromREST == true)
                                Tooltip(
                                  message: 'Убрать полномочия',
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_circle_down),
                                    onPressed: () => _setUser(user['id']),
                                  ),
                                )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  } else if (userType == "admin") {
                    return ExpansionTile(
                      title: Text('Пользователи'),
                      children: _users.map((user) {
                        final userType = user['user_type'];
                        final bool isCurrentUser = user['id'] == userID;
                        return ListTile(
                          title: Text(user['username']),
                          subtitle: userType == 'owner'
                              ? Text("Владелец\n${user['user_email']}")
                              : userType == 'admin'
                                  ? Text("Администратор\n${user['user_email']}")
                                  : Text(user['user_email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrentUser) Text("Это вы"),
                              if (!isCurrentUser &&
                                  userType == "user" &&
                                  _dataFromREST == true)
                                Tooltip(
                                  message: 'Удалить пользователя',
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteUser(user['id']),
                                  ),
                                ),
                              if (!isCurrentUser &&
                                  userType == "user" &&
                                  _dataFromREST == true)
                                Tooltip(
                                  message: 'Заблокировать пользователя',
                                  child: IconButton(
                                    icon: Icon(Icons.block),
                                    onPressed: () => _blockUser(user['id']),
                                  ),
                                ),
                              if (!isCurrentUser &&
                                  userType == "user" &&
                                  _dataFromREST == true)
                                Tooltip(
                                  message: 'Назначить администратором',
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_circle_up),
                                    onPressed: () => _setAdmin(user['id']),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                } else if (index == 1) {
                  return ExpansionTile(
                    title: Text('Заблокированные пользователи'),
                    children: _blocked_users.map((blocked_user) {
                      return ListTile(
                        title: Text(blocked_user['username']),
                        subtitle: Text(blocked_user['user_email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_dataFromREST == true)
                              Tooltip(
                                message: 'Удалить пользователя',
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteUser(blocked_user['id']),
                                ),
                              ),
                            if (_dataFromREST == true)
                              Tooltip(
                                message: 'Разблокировать пользователя',
                                child: IconButton(
                                  icon: Icon(Icons.restore),
                                  onPressed: () =>
                                      _unblockUser(blocked_user['id']),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                } else if (index == 2) {
                  return ExpansionTile(
                    title: Text('Актуальные бронирования'),
                    children: _bookings.map((booking) {
                      return ListTile(
                        title: Text('Пользователь: ${booking['username']}'),
                        subtitle: Text(
                            'Дата: ${booking['data']} \nВремя: ${booking['timerange']}'),
                        trailing: _dataFromREST == true &&
                                _isDeletable(booking['data'])
                            ? Tooltip(
                                message: 'Отменить бронирование',
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteBooking(booking),
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  );
                } else if (index == 3) {
                  return ExpansionTile(
                    title: Text('Отмененные бронирования'),
                    children: _bookings_archive.map((booking_archive) {
                      return ListTile(
                        title: Text(
                            'Пользователь: ${booking_archive['username']}'),
                        subtitle: Text(
                            'Дата: ${booking_archive['data']} \nВремя: ${booking_archive['timerange']}'),
                        trailing: _dataFromREST == true &&
                                _isDeletable(booking_archive['data'])
                            ? Tooltip(
                                message: 'Восстановить бронирование',
                                child: IconButton(
                                  icon: Icon(Icons.restore),
                                  onPressed: () =>
                                      _restoreBooking(booking_archive),
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  );
                } else {
                  return Container();
                }
              },
            ),
    );
  }
}
