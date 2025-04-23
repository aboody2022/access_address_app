import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  String? authToken;

  // Future<Map<String, dynamic>> login(String username, String password) async {
  //   try {
  //     final url = '${ApiConstants.baseUrl}${ApiConstants.login}';
  //     print(url);
  //     print('Attempting to connect to: $url'); // للتشخيص
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'username': username,
  //         'password': password,
  //       },
  //     ).timeout(const Duration(seconds: 15));
  //
  //     print('Response status: ${response.statusCode}'); // للتشخيص
  //     print('Response body: ${response.body}'); // للتشخيص
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('فشل الاتصال بالخادم: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error during login: $e'); // للتشخيص
  //     throw Exception('فشل الاتصال بالخادم: $e');
  //   }
  // }

  // Future<Map<String, dynamic>> login(String username, String password) async {
  //   try {
  //     final url = '${ApiConstants.baseUrl}${ApiConstants.login}';
  //     print('Attempting to connect to: $url');
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'User-Agent': 'Mozilla/5.0', // إضافة User-Agent
  //         'Accept': 'application/json',
  //       },
  //       body: {
  //         'username': username,
  //         'password': password,
  //         'i': '1', // إضافة معامل i المطلوب
  //       },
  //     ).timeout(const Duration(seconds: 15));
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       if (response.body.contains('<html>')) {
  //         throw Exception('استجابة غير صالحة من الخادم');
  //       }
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('فشل الاتصال بالخادم: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error during login: $e');
  //     throw Exception('فشل الاتصال بالخادم: $e');
  //   }
  // }


  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.login}';
      print('Trying to connect to: $url'); // للتشخيص

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}'); // للتشخيص
      print('Response body: ${response.body}'); // للتشخيص

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل تسجيل الدخول: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // للتشخيص
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }


}