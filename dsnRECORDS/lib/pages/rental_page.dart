import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dsn_records/pages/equipment_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../rest/rest_api.dart';

class RentalScreen extends StatefulWidget {
  @override
  _RentalScreenState createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  static bool _dialogShown = false;

  List<dynamic> equipmentList = [];
  List<int> selectedEquipment = [];

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  int? userID;

  bool areFieldsEmpty() {
    return startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        phoneController.text.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadUserID();
    startDateController.addListener(_updateSubmitButtonState);
    endDateController.addListener(_updateSubmitButtonState);
    fullNameController.addListener(_updateSubmitButtonState);
    phoneController.addListener(_updateSubmitButtonState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown) {
        _showMyDialog();
        _dialogShown = true;
      }
    });
  }

  void _updateSubmitButtonState() {
    setState(() {});
  }

  Future<void> _loadUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('id');
    });
  }

  Future<void> _fetchEquipment() async {
    try {
      final startDate = startDateController.text;
      final endDate = endDateController.text;
      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        List<dynamic> availableEquipment = await REST.getAvailableEquipment(startDate, endDate);
        setState(() {
          equipmentList = availableEquipment;
        });
      }
    } catch (error) {
      print('Error fetching equipment: $error');
    }
  }

  Future<void> _submitRentalRequest() async {
    try {
      List<int> eq_ids = selectedEquipment.toList();
      await REST.addRental(
        startDateController.text,
        endDateController.text,
        fullNameController.text,
        phoneController.text,
        userID!,
        eq_ids,
      );

      startDateController.clear();
      endDateController.clear();
      fullNameController.clear();
      phoneController.clear();
      selectedEquipment.clear();

      for (var equipment in equipmentList) {
        final eqId = equipment['id'];
        setState(() {
          selectedEquipment.remove(eqId);
        });
      }
    } catch (error) {
      print('Error submitting rental request: $error');
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Условия аренды оборудования'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'бубубу бебебе условия аренды еще что-то ляляляляляляляляляля правила использования не красть оборудование отвечть на звонки предоплата там и что еще'),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: Text('ОК', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd.MM.yyyy').format(pickedDate);
      });
      await _fetchEquipment();
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтверждение'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Вы уверены, что хотите отправить заявку на аренду?'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitRentalRequest();
                _showSuccessDialog();
              },
              child: Text('Отправить',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Заявка отправлена'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ваша заявка на аренду успешно отправлена!'),
                Text('Вы можете просмотреть её в профиле пользователя'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
  bool _isSubmitButtonEnabled() {
    final isDatesSelected = startDateController.text.isNotEmpty &&
        endDateController.text.isNotEmpty;
    final isFormFilled = fullNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
    return isDatesSelected && isFormFilled && selectedEquipment.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding:
        EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0, bottom: 5.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            Text(
              'dsnrecords is a premier recording studio that offers top-quality audio production services for musicians, bands, and other clients. Our state-of-the-art facilities and experienced team of sound engineers ensure that every project we work on sounds amazing. Whether you need to record a full-length album, a single, or a podcast, we have the skills and expertise to make your vision a reality.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => EquipmentScreen(),
                  ),
                );
              },
              child: Text(
                'Подробнее об оборудовании',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Заявка на аренду оборудования',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Дата начала аренды:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    controller: startDateController,
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, startDateController);
                    },
                    decoration: InputDecoration(
                      hintText: 'Выберите дату начала',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Дата окончания аренды:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                    controller: endDateController,
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, endDateController);
                    },
                    decoration: InputDecoration(
                      hintText: 'Выберите дату окончания',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'ФИО:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Введите ваше ФИО',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Номер телефона:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Введите ваш номер телефона',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (startDateController.text.isNotEmpty &&
                      endDateController.text.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Выберите оборудование для аренды:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8.0),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: equipmentList.length,
                          itemBuilder: (context, index) {
                            final equipment = equipmentList[index];
                            final eqId = equipment['id'];
                            final isSelected = selectedEquipment.contains(eqId);
                            return CheckboxListTile(
                              title: Text(equipment['eq_name']),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && eqId != null) {
                                    if (value) {
                                      selectedEquipment.add(eqId);
                                    } else {
                                      selectedEquipment.remove(eqId);
                                    }
                                  }
                                });
                              },
                            );
                          },
                        ),
                        if (equipmentList.isEmpty)
                          Text(
                            'Нет доступного оборудования на выбранные даты.',
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: areFieldsEmpty() || selectedEquipment.isEmpty
                        ? null
                        : () {
                      _showConfirmationDialog();
                    },
                    child: Text('Отправить заявку',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMyDialog,
        child: Icon(Icons.help_outline, size: 24.0, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }
}
