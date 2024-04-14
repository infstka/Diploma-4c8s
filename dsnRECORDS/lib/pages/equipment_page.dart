import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../jwt/jwt_check.dart';
import '../rest/rest_api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class EquipmentScreen extends StatefulWidget {
  @override
  _EquipmentScreenState createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  List<Map<String, dynamic>> equipmentData = [];
  String _selectedCategory = '';
  String? userType;

  bool _equipmentFromREST = false;

  final String equipmentTable = 'equipment';
  final String defaultImagePath = 'assets/images/no_connection.png';

  @override
  void initState() {
    super.initState();
    fetchEquipment();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> fetchEquipment() async {
    try {
      final List<dynamic> equipment = await REST.getEquipment();
      final List<dynamic> prices = await REST.getPrices();
      setState(() {
        equipmentData = equipment.map((eq) {
          final Map<String, dynamic> equipmentMap =
          Map<String, dynamic>.from(eq);
          final price = prices.firstWhere(
                  (price) => price['id'] == equipmentMap['price_id'],
              orElse: () => null);
          equipmentMap['price'] = price != null ? price['price'] : null;
          equipmentMap['service'] = price != null ? price['service'] : null;
          return equipmentMap;
        }).toList();
        if (equipmentData.isNotEmpty) {
          _selectedCategory = equipmentData.first['eq_category'];
        }
      });
      _saveEquipmentToLocalDB(equipment, prices);
      _equipmentFromREST = true;
    } catch (error) {
      print('Error fetching equipment: $error');
      final equipment = await _getEquipmentFromLocalDB();
      print('Loading equipment from local database...');
      setState(() {
        equipmentData = List<Map<String, dynamic>>.from(equipment);
      });
      _equipmentFromREST = false;
    }
  }

  Future<void> _saveEquipmentToLocalDB(List<dynamic> equipment, List<dynamic> prices) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $equipmentTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $equipmentTable (id INTEGER PRIMARY KEY, eq_name TEXT, eq_category TEXT, eq_image_path TEXT, is_rentable INTEGER, price TEXT)'
    );
    await db.transaction((txn) async {
      for (final eq in equipment) {
        final priceId = eq['price_id'];
        final priceData = prices.firstWhere((price) => price['id'] == priceId, orElse: () => null);
        final price = priceData != null ? priceData['price'] : null;
        await txn.rawInsert(
          'INSERT OR REPLACE INTO $equipmentTable (id, eq_name, eq_category, eq_image_path, is_rentable, price) VALUES (?, ?, ?, ?, ?, ?)',
          [
            eq['id'],
            eq['eq_name'],
            eq['eq_category'],
            defaultImagePath,
            eq['is_rentable'] == 1 ? true : false,
            price,
          ],
        );
      }
    });
  }

  Future<List<dynamic>> _getEquipmentFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $equipmentTable (id INTEGER PRIMARY KEY, eq_name TEXT, eq_category TEXT, eq_image_path TEXT, is_rentable INTEGER, price TEXT)',
    );
    final result = await db.rawQuery('SELECT * FROM $equipmentTable');
    return result.toList();
  }

  Future<void> _recreateEquipmentTable() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $equipmentTable');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $equipmentTable (id INTEGER PRIMARY KEY, eq_name TEXT, eq_category TEXT, eq_image_path TEXT, is_rentable INTEGER, price TEXT)',
    );
  }

  File? _image;
  final picker = ImagePicker();
  String _equipmentName = '';
  bool _isRentable = false;
  int? _selectedPriceId;
  Uint8List? _imageBytes;

  Future<void> _addEquipment(String category) async {
    _equipmentName = '';
    _image = null;
    _isRentable = false;
    _selectedPriceId = null;
    JWT.checkTokenValidity(context);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Добавить оборудование'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Категория: $category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _equipmentName = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Название',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        JWT.checkTokenValidity(context);
                        final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final imageBytes = await pickedFile.readAsBytes();

                          setState(() {
                            _imageBytes = imageBytes;
                            _image = File(pickedFile.path);
                          });
                        }
                      },
                      child: Text('Выбрать изображение'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isRentable,
                          onChanged: (value) {
                            setState(() {
                              _isRentable = value!;
                              if (!_isRentable) {
                                _selectedPriceId = null;
                              }
                            });
                          },
                        ),
                        Text('Доступно для аренды'),
                      ],
                    ),
                    if (_isRentable) SizedBox(height: 20),
                    if (_isRentable)
                      FutureBuilder(
                        future: REST.getPrices(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final List<dynamic> prices =
                            snapshot.data as List<dynamic>;
                            return DropdownButton<int>(
                              hint: Text('Выберите цену'),
                              value: _selectedPriceId,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedPriceId = value;
                                });
                              },
                              items: prices.map<DropdownMenuItem<int>>((price) {
                                return DropdownMenuItem<int>(
                                  value: price['id'],
                                  child: Text(
                                    '${price['service']} - ${price['price']}',
                                    style: TextStyle(
                                        fontSize:
                                        14), // Adjust the font size here
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    JWT.checkTokenValidity(context);
                    Navigator.of(context).pop();
                    setState(() {
                      _isRentable = false;
                      _selectedPriceId = null;
                    });
                  },
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    JWT.checkTokenValidity(context);
                    Navigator.of(context).pop();
                    if (_equipmentName.isNotEmpty && _image != null) {
                      try {
                        var uri = Uri.parse('${REST.BASE_URL}/equipment/add');
                        var request = http.MultipartRequest('POST', uri)
                          ..fields['equipmentName'] = _equipmentName
                          ..fields['equipmentCategory'] = category
                          ..fields['isRentable'] = _isRentable.toString();

                        if (_isRentable) {
                          request.fields['priceId'] =
                              (_selectedPriceId ?? 0).toString();
                        }

                        request.files.add(http.MultipartFile.fromBytes(
                          'equipmentImage',
                          _imageBytes!,
                          filename: _image!
                              .path
                              .split('/')
                              .last,
                          contentType: MediaType('image', 'jpg'),
                        ));

                        var response = await request.send();

                        if (response.statusCode == 201) {
                          await fetchEquipment();
                          setState(() {
                            _isRentable = false;
                            _selectedPriceId = null;
                          });
                        } else {
                          throw Exception('Failed to add equipment');
                        }
                      } catch (error) {
                        print('Error adding equipment: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add equipment'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(int equipmentId) async {
    JWT.checkTokenValidity(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удаление оборудования'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Вы уверены, что хотите удалить это оборудование?'),
              ],
            ),
          ),
          actions: <Widget>[
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
                try {
                  await REST.deleteEquipment(equipmentId);
                  _recreateEquipmentTable();
                  await fetchEquipment();
                } catch (error) {
                  print('Error deleting equipment: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete equipment'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['Репетиции', 'Звукозапись', 'Аренда'];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            MediaQuery
                .of(context)
                .size
                .width > 600 ? 100.0 : 56.0),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Container(
            width: MediaQuery
                .of(context)
                .size
                .width > 600
                ? MediaQuery
                .of(context)
                .size
                .width * 0.5
                : MediaQuery
                .of(context)
                .size
                .width * 0.8,
            height: MediaQuery
                .of(context)
                .size
                .height > 600
                ? MediaQuery
                .of(context)
                .size
                .height * 0.7
                : MediaQuery
                .of(context)
                .size
                .height * 0.5,
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
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int categoryIndex) {
          final category = categories[categoryIndex];
          final categoryEquipment = equipmentData
              .where((equipment) => equipment['eq_category'] == category)
              .toList();

          // Добавляем карточку для добавления оборудования, если в категории нет оборудования
          if (categoryEquipment.isEmpty) {
            return _buildAddEquipmentCard(category);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery
                      .of(context)
                      .size
                      .width > 1200
                      ? 5
                      : MediaQuery
                      .of(context)
                      .size
                      .width > 800
                      ? 4
                      : MediaQuery
                      .of(context)
                      .size
                      .width > 600
                      ? 3
                      : 1,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.8,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                categoryEquipment.length + (_equipmentFromREST == true && userType == 'owner' ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index < categoryEquipment.length) {
                    final equipment = categoryEquipment[index];
                    return GestureDetector(
                      onTap: () {
                        if (_equipmentFromREST == true && userType == 'owner') {
                          _showDeleteConfirmationDialog(equipment['id']);
                        }
                      },
                      child: Card(
                        color: Colors.black,
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.5,
                                child: _equipmentFromREST
                                    ? Image.network(
                                  '${REST.BASE_URL}/${equipment['eq_image_path']}',
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  equipment['eq_image_path'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                equipment['eq_name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              if (equipment['is_rentable'] == 1)
                                Text(
                                  'Доступно для аренды',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              if (equipment['is_rentable'] == 1)
                                Text(
                                  'Цена: ${equipment['price']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (userType == 'owner') {
                      return GestureDetector(
                        onTap: () {
                          _addEquipment(category);
                        },
                        child: Card(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 40.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddEquipmentCard(String category) {
    if (userType == 'owner') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _addEquipment(category);
            },
            child: Card(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 40.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}
