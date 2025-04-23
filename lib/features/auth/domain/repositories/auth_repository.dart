// auth_repository.dart
import '../../../../core/api/api_endpoints.dart';
import '../../data/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        {
          'username': username,
          'password': password,
        },
      );

      if (response['status']) {
        // حفظ token في ApiService
        _apiService.authToken = response['token'];
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }
}