import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../widgets/time_slot.dart';

//192.168.100.6
//172.20.10.10
//localhost
class REST {
  static const String BASE_URL = 'http://192.168.100.6:3000';

  static Future userLogin(String user_email, String user_password) async {
    final response = await http.post(Uri.parse('$BASE_URL/user/login'),
        headers: {"Accept": "Application/json"},
        body: {'user_email': user_email, 'user_password': user_password});
    var decodedData = jsonDecode(response.body);
    return decodedData;
  }

  static Future userRegister(
      String username, String user_email, String user_password) async {
    final response =
        await http.post(Uri.parse('$BASE_URL/user/register'), headers: {
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
    final response =
        await http.delete(Uri.parse('$BASE_URL/admin/users/delete/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future blockUser(int id) async {
    final response =
        await http.put(Uri.parse('$BASE_URL/admin/users/block/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future unblockUser(int id) async {
    final response =
        await http.put(Uri.parse('$BASE_URL/admin/users/blocked/unblock/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setAdmin(int id) async {
    final response =
        await http.put(Uri.parse('$BASE_URL/admin/users/type/up/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future setUser(int id) async {
    final response =
        await http.put(Uri.parse('$BASE_URL/admin/users/type/down/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future getBookings() async {
    final response = await http.get(Uri.parse('$BASE_URL/admin/bookings'));
    final data = jsonDecode(response.body);
    return data['bookings'];
  }

  static Future getDeletedBookings() async {
    final response =
        await http.get(Uri.parse('$BASE_URL/admin/bookings/deleted'));
    final data = jsonDecode(response.body);
    return data['bookings_archive'];
  }

  static Future updateUser(Map<String, String> userData) async {
    final response = await http
        .put(Uri.parse('$BASE_URL/profile/update/${userData['id']}'), headers: {
      "Accept": "Application/json"
    }, body: {
      'username': userData['username'],
      'user_email': userData['user_email'],
      'user_password': userData['user_password'],
    });
    var decodedData = jsonDecode(response.body);
    return decodedData;
  }

  static Future getUserBookings(int userID) async {
    final response =
        await http.get(Uri.parse('$BASE_URL/profile/history/$userID'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<TimeSlot>> fetchData(String data) async {
    var response = await http.get(Uri.parse("$BASE_URL/booking/$data"));
    var responseHttpDecode = json.decode(response.body);
    return timeSlotFromJson(json.encode(responseHttpDecode['data']));
  }

  static Future<void> updateTime(
      int userId, String timeRange, String data) async {
    Map<String, dynamic> body = {
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
    final response =
        await http.delete(Uri.parse('$BASE_URL/booking/delete/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future restoreBooking(int id) async {
    final response =
        await http.delete(Uri.parse('$BASE_URL/booking/restore/$id'));
    final data = jsonDecode(response.body);
    return data;
  }

  static Future<List<dynamic>> getReviews(
      {String? sort, String? sortOrder}) async {
    String url = '$BASE_URL/review';

    if (sort != null && sortOrder != null) {
      url += '?sort=$sort&sortOrder=$sortOrder';
    }

    final response = await http.get(Uri.parse(url));

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
    final response =
        await http.delete(Uri.parse('$BASE_URL/review/delete/$id'));
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

  static Future<List<dynamic>> getServicesByCategory(String category) async {
    final response = await http.get(Uri.parse('$BASE_URL/price/category/$category'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load services by category');
    }
  }

  static Future<void> addService(String service, String price, String category) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/price/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"service": service, "price": price, "category": category}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add service');
    }
  }

  static Future<void> updateService(int id, String service, String price) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/price/update/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"service": service, "price": price}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update service');
    }
  }

  static Future<void> deleteService(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/price/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete service');
    }
  }

  static Future<List<dynamic>> getClients() async {
    final response = await http.get(Uri.parse('$BASE_URL/client'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load clients');
    }
  }

  // static Future addClient(String clientName, String imagePath) async {
  //   var uri = Uri.parse('$BASE_URL/client/add');
  //
  //   //создание multipart/form-data запроса
  //   var request = http.MultipartRequest('POST', uri)
  //     ..fields['clientName'] = clientName
  //     ..files.add(await http.MultipartFile.fromPath(
  //         'clientImage', imagePath,
  //         contentType: MediaType('image', 'jpg'))); // Предполагается, что изображение клиента находится по указанному пути
  //
  //   var response = await request.send();
  //
  //   if (response.statusCode == 201) {
  //     return true;
  //   } else {
  //     throw Exception('Failed to add client');
  //   }
  // }

  // static Future<void> updateClient(int clientId, String clientName, String imagePath) async {
  //   var url = Uri.parse('$BASE_URL/client/$clientId');
  //
  //   try {
  //     var request = http.MultipartRequest('PUT', url)
  //       ..fields['clientName'] = clientName;
  //
  //     if (imagePath.isNotEmpty) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //           'clientImage', imagePath,
  //           contentType: MediaType('image', 'jpg')));
  //     }
  //
  //     var response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       return;
  //     } else {
  //       throw Exception('Failed to update client: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     throw Exception('Failed to update client: $error');
  //   }
  // }

  static Future<void> deleteClient(int clientId) async {
    var url = Uri.parse('$BASE_URL/client/$clientId');
    try {
      var response = await http.delete(url);
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
    final response = await http.get(Uri.parse('$BASE_URL/equipment'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  static Future<List<dynamic>> getPrices() async {
    final response = await http.get(Uri.parse('$BASE_URL/equipment/prices'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load prices');
    }
  }

  // static Future<void> addEquipment(String equipmentName, String equipmentCategory, bool isRentable, String imagePath, int? priceId) async {
  //   var uri = Uri.parse('$BASE_URL/equipment/add');
  //
  //   var request = http.MultipartRequest('POST', uri)
  //     ..fields['equipmentName'] = equipmentName
  //     ..fields['equipmentCategory'] = equipmentCategory
  //     ..fields['isRentable'] = isRentable.toString();
  //   if (isRentable) {
  //     request.fields['priceId'] = priceId.toString();
  //   }
  //   request.files.add(await http.MultipartFile.fromPath(
  //       'equipmentImage', imagePath,
  //       contentType: MediaType('image', 'jpg')));
  //
  //   var response = await request.send();
  //
  //   if (response.statusCode == 201) {
  //     return;
  //   } else {
  //     throw Exception('Failed to add equipment');
  //   }
  // }

  // static Future<void> updateEquipment(int equipmentId, String equipmentName, String equipmentCategory, bool isRentable, String imagePath, int priceId) async {
  //   var url = Uri.parse('$BASE_URL/equipment/$equipmentId');
  //
  //   try {
  //     var request = http.MultipartRequest('PUT', url)
  //       ..fields['equipmentName'] = equipmentName
  //       ..fields['equipmentCategory'] = equipmentCategory
  //       ..fields['isRentable'] = isRentable.toString()
  //       ..fields['priceId'] = priceId.toString();
  //
  //     if (imagePath.isNotEmpty) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //           'equipmentImage', imagePath,
  //           contentType: MediaType('image', 'jpg')));
  //     }
  //
  //     var response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       return;
  //     } else {
  //       throw Exception('Failed to update equipment: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     throw Exception('Failed to update equipment: $error');
  //   }
  // }

  static Future<void> deleteEquipment(int equipmentId) async {
    var url = Uri.parse('$BASE_URL/equipment/$equipmentId');

    try {
      var response = await http.delete(url);

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
    final response = await http.post(
      Uri.parse('$BASE_URL/contact/add'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"contact": contact, "contact_type": contactType}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add contact');
    }
  }

  static Future<void> updateContact(int id, String contact) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/contact/update/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"contact": contact}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact');
    }
  }

  static Future<void> deleteContact(int id) async {
    final response = await http.delete(Uri.parse('$BASE_URL/contact/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }

  static Future<List<dynamic>> getContacts() async {
    final response = await http.get(Uri.parse('$BASE_URL/contact'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  static Future<List<dynamic>> getContactsByType(String contactType) async {
    final response = await http.get(Uri.parse('$BASE_URL/contact/$contactType'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load contacts by type');
    }
  }
}
