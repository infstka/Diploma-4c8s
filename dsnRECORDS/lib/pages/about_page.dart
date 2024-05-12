import 'package:dsn_records/jwt/jwt_check.dart';
import 'package:flutter/material.dart';
import 'package:dsn_records/pages/price_page.dart';
import 'package:dsn_records/pages/equipment_page.dart';
import 'package:dsn_records/pages/clients_page.dart';
import 'package:dsn_records/pages/contacts_page.dart';

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
                Text(
                      '\u2003Наши страницы с ценами предлагают подробный прейскурант наших услуг, включая звукозапись, репетиции и аренду оборудования.\n'
                      '\u2003На вкладке оборудования вы найдете информацию о нашем современном оборудовании, часть из которого доступно для аренды.\n'
                      '\u2003На странице "Наши клиенты" вы можете узнать больше о музыкантах, которые уже воспользовались нашими услугами.\n'
                      '\u2003Если у вас есть вопросы, свяжитесь с нами. Наши контакты можно найти на странице контактов.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
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
                      image: AssetImage("assets/images/8.jpeg"),
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
                      image: AssetImage("assets/images/2.jpeg"),
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
                      image: AssetImage("assets/images/10.jpg"),
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
