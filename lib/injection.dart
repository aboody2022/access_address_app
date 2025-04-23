// lib/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/biometric_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // BiometricService
  getIt.registerSingleton<BiometricService>(
    BiometricService(sharedPreferences),
  );

  // AuthProvider
  getIt.registerFactory<AuthProvider>(
        () => AuthProvider(),
  );
}