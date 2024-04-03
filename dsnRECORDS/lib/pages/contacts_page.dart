import 'package:flutter/material.dart';
import 'package:dsn_records/rest/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> _contacts = [];
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await REST.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      print('Failed to load contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedContacts = {};
    _contacts.forEach((contact) {
      String contactType = contact['contact_type'];
      if (!groupedContacts.containsKey(contactType)) {
        groupedContacts[contactType] = [];
      }
      groupedContacts[contactType]!.add(contact);
    });

    List<Widget> contactGroups = [];
    groupedContacts.forEach((contactType, contacts) {
      contactGroups.add(
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            contactType,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );

      contacts.asMap().forEach((index, contact) {
        contactGroups.add(
          GestureDetector(
            onTap: userType == 'owner'
                ? () => _showDeleteContactDialog(contact['id'])
                : null,
            onLongPress: userType == 'owner'
                ? () => _showUpdateContactDialog(contact)
                : null,
            child: ListTile(
              title: Center(
                child: Text(
                  contact['contact'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );

        if (index == contacts.length - 1) {
          contactGroups.add(
            userType == 'owner'
                ? InkWell(
              onTap: () => _addNewContact(contactType),
              child: ListTile(
                title: Center(child: Icon(Icons.add)),
              ),
            )
                : SizedBox(),
          );
        }
      });

      // Добавляем разделитель между группами
      contactGroups.add(SizedBox(height: 20.0));
    });

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
              onTap: () => Navigator.of(context).pop(),
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
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        children: contactGroups,
      ),
    );
  }

  Future<void> _showDeleteContactDialog(int contactId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Удалить контакт"),
          content: Text("Вы уверены, что хотите удалить этот контакт?"),
          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Удалить"),
              onPressed: () async {
                try {
                  await REST.deleteContact(contactId);
                  // После удаления обновляем список контактов
                  _loadContacts();
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Failed to delete contact: $e");
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateContactDialog(dynamic contact) async {
    String newContactName = '';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Изменить имя контакта"),
          content: TextField(
            onChanged: (value) {
              newContactName = value;
            },
            decoration: InputDecoration(
              hintText: 'Новое имя контакта',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Сохранить"),
              onPressed: () async {
                try {
                  await REST.updateContact(contact['id'], newContactName);
                  _loadContacts();
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Failed to update contact: $e");
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewContact(String contactType) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String newContactName = '';
        return AlertDialog(
          title: Text("Добавить новый контакт"),
          content: TextField(
            onChanged: (value) {
              newContactName = value;
            },
            decoration: InputDecoration(
              hintText: 'Имя контакта',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Добавить"),
              onPressed: () async {
                try {
                  await REST.addContact(newContactName, contactType);
                  _loadContacts();
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Failed to add contact: $e");
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
