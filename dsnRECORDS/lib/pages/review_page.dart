import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../rest/rest_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_platform/universal_platform.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<dynamic> _reviews = [];
  int? userID;
  String? userName;
  String? userType;
  bool _isFormVisible = false;
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  final String reviewTable = 'reviews';
  bool _reviewsFromREST = false;

  @override
  void initState() {
    super.initState();
    _loadUserID();
    _loadUserName();
    _loadUserType();
    _loadReviews();
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

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> _loadReviews({String? sort, String? sortOrder}) async {
    // if (!UniversalPlatform.isWeb) {
    //   final reviews = await _loadReviewsFromLocalDB();
    //   setState(() {
    //     _reviews = reviews;
    //   });
    // }
    try {
      final reviews = await REST.getReviews(sort: sort, sortOrder: sortOrder);
      setState(() {
        _reviews = reviews;
      });
      _saveReviewsToLocalDB(reviews);
      _reviewsFromREST = true;
    } catch (e) {
      print('Failed to load reviews from REST API: $e');
      final reviews = await _loadReviewsFromLocalDB();
      print('Loading reviews from local database...');
      setState(() {
        _reviews = reviews;
      });
    }
  }

  Future<void> _saveReviewsToLocalDB(List<dynamic> reviews) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $reviewTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $reviewTable (id INTEGER PRIMARY KEY, username TEXT, review_datetime DATETIME, review_mark INTEGER, review_comment TEXT)');
    await db.transaction((txn) async {
      for (final review in reviews) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $reviewTable (id, username, review_datetime, review_mark, review_comment) VALUES (?, ?, ?, ?, ?)',
            [
              review['id'],
              review['username'],
              review['review_datetime'],
              review['review_mark'],
              review['review_comment']
            ]);
      }
    });
  }

  Future<List<dynamic>> _loadReviewsFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    final result = await db.rawQuery('SELECT * FROM $reviewTable');
    return result.toList();
  }

  Future<void> _recreateReviewsTable() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $reviewTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $reviewTable (id INTEGER PRIMARY KEY, username TEXT, review_datetime DATETIME, review_mark INTEGER, review_comment TEXT)');
  }

  Future<void> _addReview() async {
    final success = await REST.addReview(
      userId: userID!,
      rating: _selectedRating,
      comment: _commentController.text,
    );
    if (success) {
      _loadReviews();
      setState(() {
        _selectedRating = 0;
        _commentController.clear();
      });
    }
  }

  void _deleteReview(int id) async {
    final result = await REST.deleteReview(id);
    if (result['success']) {
      setState(() {
        _reviews.removeWhere((review) => review['id'] == id);
      });
      _recreateReviewsTable();
      _loadReviews();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  void _handleUpdateReview(int id) async {
    final currentRating =
        _reviews.firstWhere((review) => review['id'] == id)['review_mark'];
    final currentComment =
        _reviews.firstWhere((review) => review['id'] == id)['review_comment'];
    final newRating = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Измените вашу оценку'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < currentRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => Navigator.pop(context, index + 1),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (newRating != null) {
      final newComment = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Измените ваш комментарий'),
            content: TextFormField(
              controller: _commentController..text = currentComment,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Введите комментарий',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Сохранить'),
                onPressed: () =>
                    Navigator.pop(context, _commentController.text),
              ),
            ],
          );
        },
      );
      if (newComment != null) {
        if (newRating != currentRating) {
          setState(() {
            _selectedRating = newRating;
          });
        }
        final success = await REST.updateReview(
          id: id,
          updRating: newRating,
          updComment: newComment,
        );
        if (success) {
          _recreateReviewsTable();
          _loadReviews();
          _selectedRating = 0;
          _commentController.clear();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to update review')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton(
                tooltip: "Сортировать",
                icon: Icon(Icons.sort, color: Colors.black45,),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.star),
                      title: Text('По оценке (возрастание)'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadReviews(sort: 'mark', sortOrder: 'asc');
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.star),
                      title: Text('По оценке (убывание)'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadReviews(sort: 'mark', sortOrder: 'desc');
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('По дате (возрастание)'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadReviews(sort: 'date', sortOrder: 'asc');
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('По дате (убывание)'),
                      onTap: () {
                        Navigator.pop(context);
                        _loadReviews(sort: 'date', sortOrder: 'desc');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (BuildContext context, int index) {
                final review = _reviews[index];
                final isUserReview = review['username'] == userName;
                if (userType == "user") {
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: ' ${review['username']} ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                            '${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.parse(review['review_datetime']).add(Duration(hours: 3)))}\n',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          WidgetSpan(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                review['review_mark'],
                                    (index) => Icon(
                                  Icons.star_rate,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '\n',
                          ),
                          TextSpan(
                            text: ' ${review['review_comment']}\n',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reviewsFromREST == true)
                          Tooltip(
                            message: 'Обновить отзыв',
                            child: isUserReview
                                ? IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _handleUpdateReview(review['id']),
                            )
                                : null,
                          ),
                        if (_reviewsFromREST == true)
                          Tooltip(
                            message: 'Удалить отзыв',
                            child: isUserReview
                                ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteReview(review['id']),
                            )
                                : null,
                          ),
                      ],
                    ),
                  );
                } else if (userType != "user") {
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: ' ${review['username']} ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                            '${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.parse(review['review_datetime']).add(Duration(hours: 3)))}\n',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          WidgetSpan(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                review['review_mark'],
                                    (index) => Icon(
                                  Icons.star_rate,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '\n',
                          ),
                          TextSpan(
                            text: ' ${review['review_comment']}\n',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reviewsFromREST == true)
                          Tooltip(
                            message: 'Обновить отзыв',
                            child: isUserReview
                                ? IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _handleUpdateReview(review['id']),
                            )
                                : null,
                          ),
                        if (_reviewsFromREST == true)
                          Tooltip(
                            message: 'Удалить отзыв',
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteReview(review['id']),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          if (_reviewsFromREST == true)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isFormVisible = !_isFormVisible;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Оставить отзыв',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Icon(
                          _isFormVisible
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 28.0,
                        ),
                      ],
                    ),
                  ),
                  if (_isFormVisible) ...[
                    Row(
                      children: [
                        Text('Оценка: '),
                        Row(
                          children: [
                            for (int i = 1; i <= 5; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating = i;
                                  });
                                },
                                child: Icon(
                                  Icons.star_rate,
                                  color: _selectedRating >= i
                                      ? Colors.amber
                                      : Colors.grey[400],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Комментарий',
                        hintText: 'Напишите ваш комментарий',
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _selectedRating == 0 ? null : _addReview,
                      child: Text('Добавить отзыв'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
