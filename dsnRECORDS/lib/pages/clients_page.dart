import 'dart:io';
import 'dart:typed_data';
import 'package:dsn_records/jwt/jwt_check.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../rest/rest_api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Map<String, dynamic>> clientData = [];
  String? userType;
  bool _clientsFromREST = false;

  final String clientsTable = 'clients';
  final String defaultImagePath = 'assets/images/no_connection.png';

  @override
  void initState() {
    super.initState();
    getClients();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> getClients() async {
    try {
      final List<dynamic> clients = await REST.getClients();
      setState(() {
        clientData = List<Map<String, dynamic>>.from(clients);
      });
      _saveClientsToLocalDB(clients);
      _clientsFromREST = true;
    } catch (error) {
      print('Error fetching clients: $error');
      final clients = await _getClientsFromLocalDB();
      print('Loading clients from local database...');
      setState(() {
        clientData = List<Map<String, dynamic>>.from(clients);
      });
      _clientsFromREST = false;
    }
  }

  Future<void> _saveClientsToLocalDB(List<dynamic> clients) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $clientsTable (id INTEGER PRIMARY KEY, client_name TEXT, client_image_path TEXT)');
    await db.transaction((txn) async {
      for (final client in clients) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $clientsTable (id, client_name, client_image_path) VALUES (?, ?, ?)',
            [
              client['id'],
              client['client_name'],
              defaultImagePath,
            ]);
      }
    });
  }

  Future<List<dynamic>> _getClientsFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $clientsTable (id INTEGER PRIMARY KEY, client_name TEXT, client_image_path TEXT)');
    final result = await db.rawQuery('SELECT * FROM $clientsTable');
    return result.toList();
  }

  Future<void> _recreateClientsTable() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $clientsTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $clientsTable (id INTEGER PRIMARY KEY, client_name TEXT, client_image_path TEXT)');
  }

  File? _image;
  final picker = ImagePicker();
  String _clientName = '';
  Uint8List? _imageBytes;

  Future<void> _addClient() async {
    JWT.checkTokenValidity(context);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить клиента'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _clientName = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Имя/название',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    JWT.checkTokenValidity(context);
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
                Navigator.of(context).pop();
                if (_clientName.isNotEmpty && _imageBytes != null) {
                  try {
                    var request = http.MultipartRequest(
                      'POST',
                      Uri.parse('${REST.BASE_URL}/client/add'),
                    )
                      ..fields['clientName'] = _clientName
                      ..files.add(http.MultipartFile.fromBytes(
                        'clientImage',
                        _imageBytes!,
                        filename: _image!.path.split('/').last,
                        contentType: MediaType('image', _image!.path.split('.').last),
                      ));

                    var response = await request.send();

                    if (response.statusCode == 201) {
                      await getClients();
                    } else {
                      print('Failed to add client');
                      throw Exception('Failed to add client');
                    }
                  } catch (error) {
                    print('Error adding client: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add client'),
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
  }

  Future<void> _deleteClient(int clientId) async {
    try {
      await REST.deleteClient(clientId);
      _recreateClientsTable();
      await getClients();
    } catch (error) {
      print('Failed to delete client: $error');
    }
  }

  Future<void> _showDeleteConfirmationDialog(int clientId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить клиента?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Вы уверены, что хотите удалить этого клиента?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Удалить'),
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
                _deleteClient(clientId);
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          crossAxisSpacing: 10.0,
          childAspectRatio: 2,
        ),
        itemCount: clientData.length + (userType == 'owner' ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index < clientData.length) {
            return GestureDetector(
              onTap: () {
                JWT.checkTokenValidity(context);
                if (_clientsFromREST == true && userType == 'owner') {
                  _showDeleteConfirmationDialog(clientData[index]['id']);
                }
              },
              onLongPress: () {},
              child: Card(
                elevation: 0,
                margin: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
                color: Colors.transparent,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _clientsFromREST
                                  ? NetworkImage('${REST.BASE_URL}/${clientData[index]['client_image_path']}')
                                  : AssetImage(clientData[index]['client_image_path']) as ImageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        clientData[index]['client_name'],
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            if (_clientsFromREST == true && userType == 'owner') {
              return GestureDetector(
                onTap: _addClient,
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          size: 50.0,
                          color: Colors.black,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Добавить нового клиента',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
    );
  }
}
