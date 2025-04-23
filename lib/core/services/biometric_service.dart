import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;
  static const String _credentialsKey = 'biometric_credentials';

  BiometricService(this._prefs) : _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      // التحقق من دعم الجهاز للمصادقة البيومترية
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        print('Device does not support biometric authentication');
        return false;
      }

      // التحقق من توفر المصادقة البيومترية
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        print('No biometrics available on this device');
        return false;
      }

      // التحقق من الأنواع المتاحة
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('No biometrics enrolled on this device');
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'قم بالمصادقة للدخول إلى التطبيق',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<void> saveCredentials(String username, String password) async {
    try {
      final credentials = {
        'username': username,
        'password': password,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _prefs.setString(_credentialsKey, jsonEncode(credentials));
    } catch (e) {
      print('Error saving credentials: $e');
      throw Exception('Failed to save credentials');
    }
  }

  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final storedData = _prefs.getString(_credentialsKey);
      if (storedData != null) {
        final Map<String, dynamic> data = jsonDecode(storedData);
        return {
          'username': data['username'],
          'password': data['password'],
        };
      }
      return null;
    } catch (e) {
      print('Error retrieving credentials: $e');
      return null;
    }
  }

  Future<void> removeCredentials() async {
    try {
      await _prefs.remove(_credentialsKey);
    } catch (e) {
      print('Error removing credentials: $e');
      throw Exception('Failed to remove credentials');
    }
  }
}
