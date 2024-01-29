import 'dart:convert';

List<TimeSlot> timeSlotFromJson(String str) =>
    List<TimeSlot>.from(json.decode(str).map((x) => TimeSlot.fromJson(x)));

class TimeSlot {
  int userId;
  String timerange;
  int status;

  TimeSlot(
      {required this.userId, required this.timerange, required this.status});

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
      userId: json['user_id'],
      timerange: json['timerange'],
      status: json['status']);
}