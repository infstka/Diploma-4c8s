import 'package:flutter/material.dart';
import 'package:dsn_records/pages/price_page.dart';
import 'package:dsn_records/pages/equipment_page.dart';
import 'package:dsn_records/pages/clients_page.dart';
import 'package:dsn_records/pages/contacts_page.dart';
import '../jwt/jwt_check.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 25.0, top: 15.0, right: 25.0, bottom: 5.0),
            child: Column(
              children: [
                SizedBox(height: 16.0),
                //SizedBox(height: 20),
                Text(
                  'dsnrecords is a premier recording studio that offers top-quality audio production services for musicians, bands, and other clients. Our state-of-the-art facilities and experienced team of sound engineers ensure that every project we work on sounds amazing. Whether you need to record a full-length album, a single, or a podcast, we have the skills and expertise to make your vision a reality.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.0),
                Ink(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/1.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(
                          double.infinity,
                          MediaQuery.of(context).size.width > 600
                              ? MediaQuery.of(context).size.height * 0.3
                              : MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      JWT.checkTokenValidity(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          pageBuilder: (_, __, ___) => PriceScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Цены',
                      style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Ink(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/2.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(
                          double.infinity,
                          MediaQuery.of(context).size.width > 600
                              ? MediaQuery.of(context).size.height * 0.3
                              : MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      JWT.checkTokenValidity(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          pageBuilder: (_, __, ___) => EquipmentScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Оборудование',
                      style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Ink(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/3.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(
                          double.infinity,
                          MediaQuery.of(context).size.width > 600
                              ? MediaQuery.of(context).size.height * 0.3
                              : MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      JWT.checkTokenValidity(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          pageBuilder: (_, __, ___) => ClientsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Наши клиенты',
                      style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Ink(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/5.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        ContinuousRectangleBorder(),
                      ),
                      fixedSize: MaterialStateProperty.all(
                        Size(
                          double.infinity,
                          MediaQuery.of(context).size.width > 600
                              ? MediaQuery.of(context).size.height * 0.3
                              : MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      JWT.checkTokenValidity(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          pageBuilder: (_, __, ___) => ContactsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Контакты',
                      style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
