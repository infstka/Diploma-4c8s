import 'package:dsn_records/jwt/jwt_check.dart';
import 'package:flutter/material.dart';
import '../rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  List<dynamic> services = [];
  List<String> categories = ['Репетиции', 'Звукозапись', 'Аренда'];
  String? userType;

  final String pricesTable = 'prices';
  bool _pricesFromREST = false;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _fetchServices();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> _fetchServices() async {
    try {
      List<dynamic> updatedServices = [];
      for (String category in categories) {
        final List<dynamic> fetchedServices = await REST.getServicesByCategory(category);
        updatedServices.addAll(fetchedServices);
      }
      setState(() {
        services = updatedServices;
      });
      _saveServicesToLocalDB(updatedServices);
      _pricesFromREST = true;
    } catch (error) {
      print('Error fetching prices: $error');
      final services = await _getServicesFromLocalDB();
      print('Loading prices from local database...');
      setState(() {
        this.services = services;
      });
      _pricesFromREST = false;
    }
  }

  Future<void> _saveServicesToLocalDB(List<dynamic> prices) async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $pricesTable (id INTEGER PRIMARY KEY, service TEXT, price TEXT, category TEXT)');
    await db.transaction((txn) async {
      for (final price in prices) {
        await txn.rawInsert(
            'INSERT OR REPLACE INTO $pricesTable (id, service, price, category) VALUES (?, ?, ?, ?)',
            [
              price['id'],
              price['service'],
              price['price'],
              price['category'],
            ]
        );
      }
    });
  }

  Future<List<dynamic>> _getServicesFromLocalDB() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $pricesTable (id INTEGER PRIMARY KEY, service TEXT, price TEXT, category TEXT)');
    final result = await db.rawQuery('SELECT * FROM $pricesTable');
    return result.toList();
  }

  Future<void> _recreatePricesTable() async {
    final db = await sqflite.openDatabase('localDB.db');
    await db.execute('DROP TABLE IF EXISTS $pricesTable');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $pricesTable (id INTEGER PRIMARY KEY, service TEXT, price TEXT, category TEXT)');
  }

  Future<void> _addService(String service, String price, String category) async {
    try {
      await REST.addService(service, price, category);
      await _fetchServices();
    } catch (error) {
      print('Error adding service: $error');
    }
  }

  Future<void> _updateService(int id, String service, String price) async {
    try {
      await REST.updateService(id, service, price);
      _recreatePricesTable();
      await _fetchServices();
    } catch (error) {
      print('Error updating service: $error');
    }
  }

  Future<void> _deleteService(int id) async {
    try {
      await REST.deleteService(id);
      _recreatePricesTable();
      await _fetchServices();
    } catch (error) {
      print('Error deleting service: $error');
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
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          List<dynamic> categoryServices = services.where((service) => service['category'] == categories[index]).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 2),
                ),
                itemCount: categoryServices.length + 1,
                itemBuilder: (BuildContext context, int serviceIndex) {
                  if (serviceIndex < categoryServices.length) {
                    final service = categoryServices[serviceIndex];
                    return GestureDetector(
                      onTap: _pricesFromREST == true && userType == "owner" ? () {
                        JWT.checkTokenValidity(context);
                        _showDeleteDialog(service);
                      } : null,
                      onLongPress: _pricesFromREST == true && userType == "owner" ? () {
                        JWT.checkTokenValidity(context);
                        _showEditDialog(service);
                      } : null,
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              service['service'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Цена: ${service['price']}',
                              style: TextStyle(color: Colors.white, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    if (_pricesFromREST == true && userType == "owner") {
                      return GestureDetector(
                        onTap: () {
                          JWT.checkTokenValidity(context);
                          _showAddDialog(categories[index]);
                        },
                        child: Card(
                          color: Colors.black,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Добавить новую услугу',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 16.0),
                              ),
                            ],
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

  void _showAddDialog(String category) {
    TextEditingController serviceNameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить новую услугу'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serviceNameController,
                decoration: InputDecoration(
                  labelText: 'Название услуги',
                ),
                onChanged: (value) {},
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Цена',
                ),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                String newServiceName = serviceNameController.text;
                String newPrice = priceController.text;

                _addService(newServiceName, newPrice, category);
                Navigator.of(context).pop();
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(dynamic service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить услугу?'),
          content: Text('Вы уверены, что хотите удалить услугу ${service['service']}?'),
          actions: [
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                _deleteService(service['id']);
                Navigator.of(context).pop();
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(dynamic service) {
    TextEditingController serviceNameController = TextEditingController(text: service['service']);
    TextEditingController priceController = TextEditingController(text: service['price'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать услугу'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: serviceNameController,
                decoration: InputDecoration(
                  labelText: 'Название услуги',
                ),
                onChanged: (value) {
                },
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Цена',
                ),
                onChanged: (value) {
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                JWT.checkTokenValidity(context);
                String updatedServiceName = serviceNameController.text;
                String updatedPrice = priceController.text;

                _updateService(
                  service['id'],
                  updatedServiceName,
                  updatedPrice,
                );
                Navigator.of(context).pop();
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
