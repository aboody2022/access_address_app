// import 'package:access_address_app/screens/forgot_password_screen.dart';
// import 'package:access_address_app/screens/login_page.dart';
// import 'package:access_address_app/injection.dart';
// import 'package:access_address_app/screens/account_screen.dart';
// import 'package:access_address_app/screens/baes_screen.dart';
// import 'package:access_address_app/screens/home_screen.dart';
// import 'package:access_address_app/screens/register_screen.dart';
// import 'package:access_address_app/screens/my_orders_screen.dart';
// import 'package:access_address_app/screens/onboard_screen.dart';
// import 'package:access_address_app/screens/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'core/services/biometric_service.dart';
// import 'features/auth/home_model.dart';
// import 'features/auth/presentation/providers/auth_provider.dart';
// import 'features/vehicle/presentation/pages/my_vehicles_screen.dart';
//
// import 'package:adaptive_theme/adaptive_theme.dart';
//
// import 'core/themes/app_theme.dart';
//
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // إضافة مزود عام للخدمات
// late SharedPreferences globalPrefs;
// late BiometricService biometricService;
//
//
// Future<void> main() async {
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     // تهيئة SharedPreferences
//     globalPrefs = await SharedPreferences.getInstance();
//
//     // تهيئة خدمة المصادقة البيومترية
//     biometricService = BiometricService(globalPrefs);
//
//     // تهيئة حالة الثيم المحفوظة
//     final savedThemeMode = await AdaptiveTheme.getThemeMode();
//
//     // تعيين توجيه الشاشة
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//
//     Supabase.initialize(
//         url: 'https://sipdyolcorgpqocgydik.supabase.co',
//         anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpcGR5b2xjb3JncHFvY2d5ZGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3Nzk2OTEsImV4cCI6MjA2MTM1NTY5MX0.JwtkGwtp9qGGdNv7QscyIuxsKNVeSf46nqc5giZXNgg',
//       );
//
//
//     runApp(ChangeNotifierProvider(
//       create: (context) => HomeModel(),
//       child: MyApp(
//         savedThemeMode: savedThemeMode,
//         sharedPreferences: globalPrefs,
//         biometricService: biometricService,
//       ),
//     ));
//   } catch (e) {
//     // يمكن إضافة معالجة الأخطاء هنا
//   }
// }
//
// class MyApp extends StatelessWidget {
//   final AdaptiveThemeMode? savedThemeMode;
//   final SharedPreferences sharedPreferences;
//   final BiometricService biometricService;
//
//   const MyApp({
//     super.key,
//     this.savedThemeMode,
//     required this.sharedPreferences,
//     required this.biometricService,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => getIt<AuthProvider>(),
//         ),
//         // إضافة مزود خدمة المصادقة البيومترية
//         Provider.value(value: biometricService),
//         Provider.value(value: sharedPreferences),
//       ],
//       child: AdaptiveTheme(
//         light: AppTheme.lightTheme,
//         dark: AppTheme.darkTheme,
//         initial: savedThemeMode ?? AdaptiveThemeMode.light,
//         builder: (ThemeData light, ThemeData dark) => MaterialApp(
//           title: 'عنوان الوصول',
//           debugShowCheckedModeBanner: false,
//           theme: light,
//           darkTheme: dark,
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale('ar', ''),
//           ],
//           locale: const Locale('ar', ''),
//           initialRoute: '/splash_screen',
//           routes: {
//             '/login': (context) => LoginPage(),
//             '/register': (context) => RegisterScreen(),
//             '/home': (context) => HomeScreen(),
//             '/account': (context) => AccountScreen(),
//             '/my-orders': (context) => MyOrdersScreen(),
//             '/my-vehicles': (context) => MyVehiclesScreen(),
//             '/baes': (context) => MainScreen(),
//             '/splash_screen': (context) => SplashScreen(),
//             '/OnboardScreen': (context) => OnboardScreen(),
//             '/forgot-password': (context) => ForgotPasswordScreen(),
//
//           },
//           builder: (context, child) {
//             return Directionality(
//               textDirection: TextDirection.rtl,
//               child: child!,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// // إضافة extension للوصول السهل للخدمات
// extension ContextExtensions on BuildContext {
//   BiometricService get biometricService => read<BiometricService>();
//   SharedPreferences get sharedPreferences => read<SharedPreferences>();
// }
//



import 'package:access_address_app/screens/forgot_password_screen.dart';
import 'package:access_address_app/screens/login_page.dart';
import 'package:access_address_app/injection.dart';
import 'package:access_address_app/screens/account_screen.dart';
import 'package:access_address_app/screens/baes_screen.dart';
import 'package:access_address_app/screens/home_screen.dart';
import 'package:access_address_app/screens/register_screen.dart';
import 'package:access_address_app/screens/my_orders_screen.dart';
import 'package:access_address_app/screens/onboard_screen.dart';
import 'package:access_address_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/biometric_service.dart';
import 'features/auth/home_model.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/vehicle/presentation/pages/my_vehicles_screen.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'core/themes/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔗 إضافة Deep Link Handler
import 'config/app_config.dart';
import 'services/deep_link_handler.dart';

// إضافة مزود عام للخدمات
late SharedPreferences globalPrefs;
late BiometricService biometricService;

// 🔗 GlobalKey للNavigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('🚀 بدء تشغيل التطبيق: ${AppConfig.appNameArabic}');

    // تهيئة SharedPreferences
    globalPrefs = await SharedPreferences.getInstance();

    // تهيئة خدمة المصادقة البيومترية
    biometricService = BiometricService(globalPrefs);

    // تهيئة حالة الثيم المحفوظة
    final savedThemeMode = await AdaptiveTheme.getThemeMode();

    // تعيين توجيه الشاشة
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // تهيئة Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    print('✅ تم تهيئة Supabase');

    // 🔗 تهيئة Deep Link Handler
    await DeepLinkHandler.initialize(navigatorKey);

    runApp(ChangeNotifierProvider(
      create: (context) => HomeModel(),
      child: MyApp(
        savedThemeMode: savedThemeMode,
        sharedPreferences: globalPrefs,
        biometricService: biometricService,
      ),
    ));
  } catch (e) {
    print('❌ خطأ في تشغيل التطبيق: $e');
  }
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final SharedPreferences sharedPreferences;
  final BiometricService biometricService;

  const MyApp({
    super.key,
    this.savedThemeMode,
    required this.sharedPreferences,
    required this.biometricService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthProvider>(),
        ),
        // إضافة مزود خدمة المصادقة البيومترية
        Provider.value(value: biometricService),
        Provider.value(value: sharedPreferences),
      ],
      child: AdaptiveTheme(
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (ThemeData light, ThemeData dark) => MaterialApp(
          navigatorKey: navigatorKey, // 🔗 إضافة المفتاح
          title: AppConfig.appNameArabic,
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', ''),
          ],
          locale: const Locale('ar', ''),
          initialRoute: '/splash_screen',
          routes: {
            '/login': (context) => LoginPage(),
            '/register': (context) => RegisterScreen(),
            '/home': (context) => HomeScreen(),
            '/account': (context) => AccountScreen(),
            '/my-orders': (context) => MyOrdersScreen(),
            '/my-vehicles': (context) => MyVehiclesScreen(),
            '/baes': (context) => MainScreen(),
            '/splash_screen': (context) => SplashScreen(),
            '/OnboardScreen': (context) => OnboardScreen(),
            // '/forgot-password': (context) => ForgotPasswordScreen(),
            '/reset-password': (context) => ForgotPasswordScreen(), // 🔗 إضافة المسار الجديد
          },
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

// إضافة extension للوصول السهل للخدمات
extension ContextExtensions on BuildContext {
  BiometricService get biometricService => read<BiometricService>();
  SharedPreferences get sharedPreferences => read<SharedPreferences>();
}