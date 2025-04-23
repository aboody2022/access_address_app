// lib/features/auth/presentation/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;

  // دالة لتحديث حالة تسجيل الدخول
  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    notifyListeners();
  }

  // دالة لتحديث بيانات المستخدم
  Future<void> setUserData(Map<String, dynamic> data) async {
    _userData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(data));
    notifyListeners();
  }

  // دالة لتحميل البيانات المحفوظة
  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedUserData = prefs.getString('userData');
    if (savedUserData != null) {
      _userData = jsonDecode(savedUserData);
    }
    notifyListeners();
  }

  // دالة لتسجيل الخروج
  Future<void> logout() async {
    _isLoggedIn = false;
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
    notifyListeners();
  }
}