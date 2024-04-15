import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../jwt/jwt_check.dart';
import '../widgets/time_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

//192.168.100.6
//172.20.10.10
//localhost
class REST {
  static const String BASE_URL = 'http://localhost:3000';

  static Future userLogin(String user_email, String user_password) async {
    final response = await http.post(Uri.parse('$BASE_URL/user/login'),
        headers: {"Accept": "Application/json"},
        body: {'user_email': user_email, 'user_password': user_password});
    var decodedData = jsonDecode(response.body);
    if (decodedData['success'] == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', decodedData['token']);
    }
    return decodedData;
  }

  static Future userRegister(String username, String user_email, String user_password) async {
    final response = await http.post(Uri.parse('$BASE_URL/user/register'),
        headers: {
      "Accept": "Application/json",
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
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data['users'];
  }

  static Future getBlockedUsers() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/users/blocked'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data['blocked_users'];
  }

  static Future deleteUser(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/admin/users/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future blockUser(int id) async {
    final token = await JWT.getToken();
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/block/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future unblockUser(int id) async {
    final token = await JWT.getToken();
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/blocked/unblock/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setAdmin(int id) async {
    final token = await JWT.getToken();
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/type/up/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setUser(int id) async {
    final token = await JWT.getToken();
    final response = await http.put(Uri.parse('$BASE_URL/admin/users/type/down/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future getBookings() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/bookings'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data['bookings'];
  }

  static Future getDeletedBookings() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/bookings/deleted'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data['bookings_archive'];
  }

  static Future updateUser(Map<String, String> userData) async {
    final token = await JWT.getToken();
    final response = await http.put(Uri.parse('$BASE_URL/profile/update/${userData['id']}'),
        headers: {
          "Accept": "Application/json",
          'Authorization': 'Bearer $token',
    }, body: {
      'username': userData['username'],
      'user_email': userData['user_email'],
      'user_password': userData['user_password'],
    });
    var decodedData = jsonDecode(response.body);
    return decodedData;
  }

  static Future getUserBookings(int userID) async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/profile/history/bookings/$userID'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<dynamic>> getUserRentals(int userId) async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/profile/history/rentals/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rentals by user ID');
    }
  }

  static Future<List<TimeSlot>> fetchData(String data) async {
    final token = await JWT.getToken();
    var response = await http.get(Uri.parse("$BASE_URL/booking/$data"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var responseHttpDecode = json.decode(response.body);
    return timeSlotFromJson(json.encode(responseHttpDecode['data']));
  }

  static Future<void> updateTime(int userId, String timeRange, String data, String category) async {
    final token = await JWT.getToken();
    Map<String, dynamic> body = {
      "user_id": userId,
      "timerange": timeRange,
      "data": data,
      "category": category,
    };
    final encodeType = Encoding.getByName("UTF-8");
    var response = http.post(Uri.parse('$BASE_URL/booking/book'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
        encoding: encodeType);
    var responseHttp = await response;
    var responseHttpDecode = json.decode(responseHttp.body);
    await fetchData(data);
  }

  static Future deleteBooking(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/booking/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future restoreBooking(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/booking/restore/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<dynamic>> getReviews({String? sort, String? sortOrder}) async {
    final token = await JWT.getToken();
    String url = '$BASE_URL/review';

    if (sort != null && sortOrder != null) {
      url += '?sort=$sort&sortOrder=$sortOrder';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }

  static Future<bool> addReview({required int userId, required int rating, required String comment,}) async {
    final token = await JWT.getToken();
    final response = await http.post(
      Uri.parse('$BASE_URL/review/new'),
      body: json.encode({
        'user_id': userId,
        'review_datetime': DateTime.now().toIso8601String(),
        'review_mark': rating,
        'review_comment': comment,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future deleteReview(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/review/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<bool> updateReview({required int id, int? updRating, String? updComment}) async {
    final token = await JWT.getToken();
    final response = await http.put(
      Uri.parse('$BASE_URL/review/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
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

  static Future<List<dynamic>> getServicesByCategory(String category) async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/price/category/$category'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load services by category');
    }
  }

  static Future<void> addService(String service, String price, String category) async {
    final token = await JWT.getToken();
    final response = await http.post(
      Uri.parse('$BASE_URL/price/add'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"service": service, "price": price, "category": category}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add service');
    }
  }

  static Future<void> updateService(int id, String service, String price) async {
    final token = await JWT.getToken();
    final response = await http.put(
      Uri.parse('$BASE_URL/price/update/$id'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"service": service, "price": price}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update service');
    }
  }

  static Future<void> deleteService(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/price/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete service');
    }
  }

  static Future<List<dynamic>> getClients() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/client'),
      headers: {
      'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load clients');
    }
  }

  static Future<void> deleteClient(int clientId) async {
    final token = await JWT.getToken();
    final url = Uri.parse('$BASE_URL/client/$clientId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete client: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to delete client: $error');
    }
  }

  static Future<List<dynamic>> getEquipment() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/equipment'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  static Future<List<dynamic>> getPrices() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/equipment/prices'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load prices');
    }
  }

  static Future<void> deleteEquipment(int equipmentId) async {
    final token = await JWT.getToken();
    final url = Uri.parse('$BASE_URL/equipment/$equipmentId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to delete equipment: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to delete equipment: $error');
    }
  }

  static Future<void> addContact(String contact, String contactType) async {
    final token = await JWT.getToken();
    final response = await http.post(
      Uri.parse('$BASE_URL/contact/add'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"contact": contact, "contact_type": contactType}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add contact');
    }
  }

  static Future<void> updateContact(int id, String contact) async {
    final token = await JWT.getToken();
    final response = await http.put(
      Uri.parse('$BASE_URL/contact/update/$id'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"contact": contact}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact');
    }
  }

  static Future<void> deleteContact(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(
      Uri.parse('$BASE_URL/contact/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }

  static Future<List<dynamic>> getContacts() async {
    final token = await JWT.getToken();
    final response = await http.get(
      Uri.parse('$BASE_URL/contact'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  static Future<List<dynamic>> getRentals() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/rentals'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rentals');
    }
  }

  static Future<List<dynamic>> getAvailableEquipment(String startDate, String endDate) async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/rental/availableEquipment/$startDate/$endDate'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load available equipment');
    }
  }

  static Future<void> addRental(String start_date, String end_date, String fullname, String phone, int user_id, List<int> eq_ids) async {
    final token = await JWT.getToken();
    final response = await http.post(
      Uri.parse('$BASE_URL/rental/add'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "start_date": start_date,
        "end_date": end_date,
        "fullname": fullname,
        "phone": phone,
        "user_id": user_id,
        "eq_ids": eq_ids
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add rental');
    }
  }

  static Future<void> deleteRental(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/rental/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete rental');
    }
  }

  static Future restoreRental(int id) async {
    final token = await JWT.getToken();
    final response = await http.delete(Uri.parse('$BASE_URL/rental/restore/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<dynamic>> getDeletedRentals() async {
    final token = await JWT.getToken();
    final response = await http.get(Uri.parse('$BASE_URL/admin/rentals/deleted'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['rentals_archive'];
    } else {
      throw Exception('Failed to load deleted rentals');
    }
  }
}
