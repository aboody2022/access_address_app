// api_endpoints.dart
// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiEndpoints {
  static const String baseUrl = 'http://accessaddress.freesite.online/api';

  // Auth endpoints
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';

  // Vehicle endpoints
  static const String vehicles = '/vehicle/vehicles.php';
  static const String addVehicle = '/vehicle/add_vehicle.php';

  // Maintenance request endpoints
  static const String maintenanceRequests = '/maintenance/requests.php';
  static const String createRequest = '/maintenance/create_request.php';
}



class ApiService {
  final String baseUrl = ApiEndpoints.baseUrl;
  String? authToken;

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'حدث خطأ ما');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'حدث خطأ ما');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }
}