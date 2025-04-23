import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/get_users.php"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }
}