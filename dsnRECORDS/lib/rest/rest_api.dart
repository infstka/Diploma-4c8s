import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/time_slot.dart';

//192.168.100.7
//172.20.10.10
//localhost
class REST {
  static const String BASE_URL = 'http://localhost:3000';

  static Future userLogin(String user_email, String user_password) async {
    final response = await http.post(Uri.parse('$BASE_URL/user/login'),
        headers: {"Accept": "Application/json"},
        body: {'user_email': user_email, 'user_password': user_password});
    var decodedData = jsonDecode(response.body);
    return decodedData;
  }

  static Future userRegister(String username, String user_email, String user_password) async {
    final response = await http.post(Uri.parse('$BASE_URL/user/register'), headers: {
      "Accept": "Application/json"
    }, body: {
      'username': username,
      'user_email': user_email,
      'user_password': user_password,
    });
    var decodedData = jsonDecode(response.body);
    if (decodedData['success'] == true) {
      return decodedData;
    } else {
      throw Exception(decodedData['message']);
    }
  }

  static Future getUsers() async {
    final response = await http.get(Uri.parse('$BASE_URL/admin/users'));
    final data = jsonDecode(response.body);
    return data['users'];
  }

  static Future getBlockedUsers() async {
    final response = await http.get(Uri.parse('$BASE_URL/admin/users/blocked'));
    final data = jsonDecode(response.body);
    return data['blocked_users'];
  }

  static Future deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/admin/users/delete/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future blockUser(int id) async {
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/block/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future unblockUser(int id) async {
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/blocked/unblock/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setAdmin(int id) async {
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/type/up/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setUser(int id) async {
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/type/down/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future getBookings() async {
    final response = await http.get(Uri.parse('$BASE_URL/admin/bookings'));
    final data = jsonDecode(response.body);
    return data['bookings'];
  }

  static Future getDeletedBookings() async {
    final response = await http.get(Uri.parse('$BASE_URL/admin/bookings/deleted'));
    final data = jsonDecode(response.body);
    return data['bookings_archive'];
  }

  static Future updateUser(Map<String, String> userData) async {
    final response = await http.put(Uri.parse('$BASE_URL/profile/update/${userData['id']}'),
        headers: {"Accept": "Application/json"},
        body: {
      'username': userData['username'],
      'user_email': userData['user_email'],
      'user_password': userData['user_password'],
    });
    var decodedData = jsonDecode(response.body);
    return decodedData;
  }

  static Future getUserBookings(int userID) async {
    final response = await http.get(Uri.parse('$BASE_URL/profile/history/$userID'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<TimeSlot>> fetchData(String data) async {
    var response = await http.get(Uri.parse("$BASE_URL/booking/$data"));
    var responseHttpDecode = json.decode(response.body);
    return timeSlotFromJson(json.encode(responseHttpDecode['data']));
  }

  static Future<void> updateTime(
      int userId, String timeRange, String data) async {Map<String, dynamic> body = {
      "user_id": userId,
      "timerange": timeRange,
      "data": data,
    };
    final encodeType = Encoding.getByName("UTF-8");
    var response = http.post(Uri.parse('$BASE_URL/booking/book'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
        encoding: encodeType);
    var responseHttp = await response;
    var responseHttpDecode = json.decode(responseHttp.body);
    await fetchData(data);
  }

  static Future deleteBooking(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/booking/delete/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future restoreBooking(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/booking/restore/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<dynamic>> getReviews() async {
    final response = await http.get(Uri.parse('$BASE_URL/review'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> addReview({
    required int userId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/review/new'),
      body: json.encode({
        'user_id': userId,
        'review_datetime': DateTime.now().toIso8601String(),
        'review_mark': rating,
        'review_comment': comment,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future deleteReview(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/review/delete/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<bool> updateReview({
    required int id,
    int? updRating,
    String? updComment,
  }) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/review/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'review_datetime': DateTime.now().toIso8601String(),
        'review_mark': updRating,
        'review_comment': updComment,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}