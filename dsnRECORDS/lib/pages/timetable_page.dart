//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dsn_records/widgets/time_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../rest/rest_api.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String selectedTime = "";
  DateTime _selectedDate = DateTime.now();
  int? userID;

  @override
  void initState() {
    super.initState();
    _loadUserID();
    fetchBookedTimeSlots();
    //Timer.periodic(Duration(seconds: 1), (Timer t) => _loadUserID());
  }

  Future<void> _loadUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getInt('id');
      fetchBookedTimeSlots();
    });
  }

  List<TimeSlot> timeSlots = [
    TimeSlot(userId: 1, timerange: "06:00-07:00", status: 1),
    TimeSlot(userId: 1, timerange: "07:00-08:00", status: 1),
    TimeSlot(userId: 1, timerange: "08:00-09:00", status: 1),
    TimeSlot(userId: 1, timerange: "09:00-10:00", status: 1),
    TimeSlot(userId: 1, timerange: "10:00-11:00", status: 1),
    TimeSlot(userId: 1, timerange: "11:00-12:00", status: 1),
    TimeSlot(userId: 1, timerange: "12:00-13:00", status: 1),
    TimeSlot(userId: 1, timerange: "13:00-14:00", status: 1),
    TimeSlot(userId: 1, timerange: "14:00-15:00", status: 1),
    TimeSlot(userId: 1, timerange: "15:00-16:00", status: 1),
    TimeSlot(userId: 1, timerange: "16:00-17:00", status: 1),
    TimeSlot(userId: 1, timerange: "17:00-18:00", status: 1),
    TimeSlot(userId: 1, timerange: "18:00-19:00", status: 1),
    TimeSlot(userId: 1, timerange: "19:00-20:00", status: 1),
    TimeSlot(userId: 1, timerange: "20:00-21:00", status: 1),
    TimeSlot(userId: 1, timerange: "21:00-22:00", status: 1),
    TimeSlot(userId: 1, timerange: "22:00-23:00", status: 1),
    TimeSlot(userId: 1, timerange: "23:00-00:00", status: 1),
  ];

  Future<void> updateTime() async {
    String formattedDate = DateFormat('dd.MM.y').format(_selectedDate);
    await REST.updateTime(userID!, selectedTime, formattedDate);
    setState(() {});
  }

  getTodayDay() {
    return DateFormat("dd.MM.y").format(DateTime.now());
  }

  // Запрос на получение данных bookings
  Future<void> fetchBookedTimeSlots() async {
    if (_selectedDate != null && userID != null) {
      String formattedDate = DateFormat('dd.MM.y').format(_selectedDate);
      List<TimeSlot> bookedSlots = await REST.fetchData(formattedDate);
      setState(() {
        timeSlots.forEach((timeSlot) {
          bool isBooked = bookedSlots.any((bookedSlot) =>
          timeSlot.timerange == bookedSlot.timerange &&
              bookedSlot.status == 1);
          timeSlot.status = isBooked ? 0 : 1;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd.MM.y').format(_selectedDate);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to the previous date, but limit it to today's date
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day - 1,
                        );
                        if (_selectedDate.isBefore(DateTime.now())) {
                          _selectedDate = DateTime.now();
                        }
                      });
                      fetchBookedTimeSlots();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    "${DateFormat("dd.MM.y").format(_selectedDate)}",
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to the next date
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day + 1,
                        );
                      });
                      fetchBookedTimeSlots();
                    },
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: FutureBuilder<List<TimeSlot>>(
                  future: Future.value(timeSlots),
                  builder: (context, snapshot) {
                    Future<void> checkBookedTimeSlots() async {
                      List<TimeSlot> bookedSlots = await REST.fetchData(formattedDate); // получить записи из базы данных
                      setState(() {
                        snapshot.data!.forEach((timeSlot) {
                          bool isBooked = bookedSlots.any((bookedSlot) => timeSlot.timerange == bookedSlot.timerange && bookedSlot.status == 1);
                          timeSlot.status = isBooked ? 0 : 1;
                        });
                      });
                    }
                    if (snapshot.hasData) {
                      //checkBookedTimeSlots();
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: Container(
                                  width: MediaQuery.of(context).size.width > 600
                                      ? MediaQuery.of(context).size.width * 0.2
                                      : MediaQuery.of(context).size.width * 0.5,
                                  child: Text('Время')),
                            ),
                            DataColumn(
                              label: Container(
                                  width: //MediaQuery.of(context).size.width * 0.5,
                                  MediaQuery.of(context).size.width > 600
                                                          ? MediaQuery.of(context).size.width * 0.2
                                                          : MediaQuery.of(context).size.width * 0.5,
                                  child: Text('Статус')),
                            ),
                          ],
                          rows: snapshot.data!
                              .map((timeSlot) => DataRow(
                            cells: [
                              DataCell(Text("${timeSlot.timerange}")),
                              MediaQuery.of(context).size.width > 600 ? DataCell(
                                timeSlot.status == 0
                                    ? Text("Занято")
                                    :  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      minimumSize:
                                      Size(MediaQuery.of(context).size.width * 0.2, 40),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedTime == timeSlot.timerange) {
                                          selectedTime = "";
                                        } else {
                                          selectedTime = timeSlot.timerange;
                                        }
                                      });
                                    },
                                    child: Text("Свободно")),
                              )
                                  : MediaQuery.of(context).size.width > 400 ? DataCell(
                                timeSlot.status == 0
                                    ? Text("Занято")
                                    :  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      minimumSize:
                                      Size(MediaQuery.of(context).size.width * 0.3, 40),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedTime == timeSlot.timerange) {
                                          selectedTime = "";
                                        } else {
                                          selectedTime = timeSlot.timerange;
                                        }
                                      });
                                    },
                                    child: Text("Свободно")),
                              )
                                  : DataCell(
                                timeSlot.status == 0
                                    ? Text("Занято")
                                    :  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.green)),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedTime == timeSlot.timerange) {
                                          selectedTime = "";
                                        } else {
                                          selectedTime = timeSlot.timerange;
                                        }
                                      });
                                    },
                                    child: Text("Свободно")),
                              ),
                            ],
                          ))
                              .toList(),
                        ),
                      );
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Transform.scale(
                          scale: 0.1,
                          child: CircularProgressIndicator(
                            strokeWidth: 10,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: selectedTime != "" ? () {
                  updateTime();
                  setState(() {
                    selectedTime = "";
                  });
                  fetchBookedTimeSlots();
                } : null,
                child:
                Text(
                  "Забронировать",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 40), // установите желаемый минимальный размер кнопки
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}