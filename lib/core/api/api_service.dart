import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  String? authToken;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.login}';

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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل تسجيل الدخول: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }
}
