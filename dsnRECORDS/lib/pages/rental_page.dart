import 'package:flutter/material.dart';

class RentalScreen extends StatefulWidget {
  @override
  _RentalScreenState createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  static bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown) {
        _showMyDialog();
        _dialogShown = true;
      }
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Условия аренды оборудования'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('бубубу бебебе условия аренды еще что-то ляляляляляляляляляля правила использования не красть оборудование отвечть на звонки предоплата там и что еще'),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // background color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 25.0, top: 15.0, right: 25.0, bottom: 5.0),
          child: Column(
            children: [
              SizedBox(height: 16.0),
              Text(
                'dsnrecords is a premier recording studio that offers top-quality audio production services for musicians, bands, and other clients. Our state-of-the-art facilities and experienced team of sound engineers ensure that every project we work on sounds amazing. Whether you need to record a full-length album, a single, or a podcast, we have the skills and expertise to make your vision a reality.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

            ],
          ),
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