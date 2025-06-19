// // lib/services/deep_link_handler.dart
// import 'dart:async';
// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/app_config.dart';
//
// class DeepLinkHandler {
//   static final AppLinks _appLinks = AppLinks();
//   static StreamSubscription<Uri>? _linkSubscription;
//   static GlobalKey<NavigatorState>? _navigatorKey;
//
//   /// تهيئة Deep Link Handler
//   static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
//     _navigatorKey = navigatorKey;
//
//     try {
//       print('🔗 تهيئة Deep Link Handler...');
//
//       // التحقق من وجود deep link عند فتح التطبيق
//       final initialUri = await _appLinks.getInitialLink();
//       if (initialUri != null) {
//         print('🔗 تم العثور على Deep Link أولي: $initialUri');
//         await _handleDeepLink(initialUri);
//       }
//
//       // الاستماع للـ deep links الجديدة
//       _linkSubscription = _appLinks.uriLinkStream.listen(
//             (uri) async {
//           print('🔗 تم استلام Deep Link جديد: $uri');
//           await _handleDeepLink(uri);
//         },
//         onError: (err) {
//           print('❌ خطأ في Deep Link: $err');
//         },
//       );
//
//       print('✅ تم تهيئة Deep Link Handler بنجاح');
//     } catch (e) {
//       print('❌ خطأ في تهيئة Deep Link Handler: $e');
//     }
//   }
//
//   /// معالجة Deep Link
//   static Future<void> _handleDeepLink(Uri uri) async {
//     print('🔗 معالجة Deep Link: $uri');
//     print('🔗 Scheme: ${uri.scheme}');
//     print('🔗 Host: ${uri.host}');
//     print('🔗 Path: ${uri.path}');
//     print('🔗 Query Parameters: ${uri.queryParameters}');
//
//     try {
//       // التحقق من scheme التطبيق
//       if (uri.scheme == AppConfig.deepLinkScheme) {
//         if (uri.host == 'reset-password') {
//           print('🔗 معالجة رابط إعادة تعيين كلمة المرور');
//           await _handlePasswordReset(uri);
//         } else {
//           print('🔗 Deep Link غير معروف: ${uri.host}');
//         }
//       } else {
//         print('🔗 Scheme غير صحيح: ${uri.scheme}');
//       }
//     } catch (e) {
//       print('❌ خطأ في معالجة Deep Link: $e');
//     }
//   }
//
//   /// معالجة رابط إعادة تعيين كلمة المرور
//   static Future<void> _handlePasswordReset(Uri uri) async {
//     try {
//       print('🔐 معالجة رابط إعادة تعيين كلمة المرور...');
//
//       // استخراج المعاملات من الرابط
//       final token = uri.queryParameters['token'];
//       final type = uri.queryParameters['type'];
//       final accessToken = uri.queryParameters['access_token'];
//       final refreshToken = uri.queryParameters['refresh_token'];
//
//       print('🔐 Token: ${token?.substring(0, 20)}...');
//       print('🔐 Type: $type');
//       print('🔐 Access Token: ${accessToken?.substring(0, 20)}...');
//
//       // إذا كان لدينا access_token و refresh_token (من Supabase Auth)
//       if (accessToken != null && refreshToken != null) {
//         await _handleSupabaseAuthTokens(accessToken, refreshToken);
//       }
//       // إذا كان لدينا token عادي (من Edge Function)
//       else if (token != null && type == 'recovery') {
//         await _handleRecoveryToken(token);
//       } else {
//         print('❌ معاملات Deep Link غير صحيحة');
//       }
//     } catch (e) {
//       print('❌ خطأ في معالجة رابط إعادة تعيين كلمة المرور: $e');
//     }
//   }
//
//   /// معالجة tokens من Supabase Auth
//   static Future<void> _handleSupabaseAuthTokens(String accessToken, String refreshToken) async {
//     try {
//       print('🔐 تعيين الجلسة في Supabase...');
//
//       final response = await Supabase.instance.client.auth.setSession(
//         accessToken,
//       );
//
//       if (response.session != null) {
//         print('✅ تم تعيين الجلسة بنجاح');
//         await _navigateToPasswordReset();
//       } else {
//         print('❌ فشل في تعيين الجلسة');
//       }
//     } catch (e) {
//       print('❌ خطأ في معالجة Supabase tokens: $e');
//     }
//   }
//
//   /// معالجة recovery token
//   static Future<void> _handleRecoveryToken(String token) async {
//     try {
//       print('🔐 معالجة recovery token...');
//
//       // هنا يمكنك إضافة منطق التحقق من الـ token
//       // أو الانتقال مباشرة لصفحة إعادة التعيين
//       await _navigateToPasswordReset();
//     } catch (e) {
//       print('❌ خطأ في معالجة recovery token: $e');
//     }
//   }
//   /// الانتقال إلى صفحة إعادة تعيين كلمة المرور
//   static Future<void> _navigateToPasswordReset() async {
//     try {
//       print('🧭 الانتقال إلى صفحة إعادة تعيين كلمة المرور...');
//
//       // انتظار قليل للتأكد من تحميل التطبيق
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       final context = _navigatorKey?.currentContext;
//       if (context != null) {
//         print('✅ تم العثور على Context، الانتقال إلى الصفحة...');
//
//         // الانتقال إلى صفحة إعادة تعيين كلمة المرور
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/reset-password',
//               (route) => route.settings.name == '/login',
//         );
//       } else {
//         print('❌ لم يتم العثور على Context');
//       }
//     } catch (e) {
//       print('❌ خطأ في الانتقال: $e');
//     }
//   }
//
//   /// تنظيف الموارد
//   static void dispose() {
//     print('🧹 تنظيف Deep Link Handler...');
//     _linkSubscription?.cancel();
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/reset_password_screen.dart'; // قم بتعديل المسار حسب مشروعك

// تأكد من وجود AppConfig إذا كنت تستخدمها (لـ deepLinkScheme)
// import 'package:your_app_name/config/app_config.dart';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static StreamSubscription<AuthState>? _authStateSubscription; // إضافة استماع لحالة المصادقة
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// تهيئة Deep Link Handler
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    try {
      print('🔗 تهيئة Deep Link Handler...');

      // الاستماع لأحداث تغيير حالة المصادقة من Supabase
      _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        print('Supabase Auth Event (from DeepLinkHandler): ${event.name}');

        if (event == AuthChangeEvent.passwordRecovery) {
          // هذا الحدث يتم إطلاقه عندما ينقر المستخدم على رابط إعادة تعيين كلمة المرور
          // ويتم توجيهه إلى التطبيق، وتقوم Supabase بمعالجة الرمز المميز.
          print('AuthChangeEvent.passwordRecovery detected. Navigating to ResetPasswordScreen.');

          // تأكد من أن لدينا context صالح قبل التوجيه
          final context = _navigatorKey?.currentContext;
          if (context != null) {
            // استخدام pushAndRemoveUntil لضمان أن ResetPasswordScreen هي الشاشة الوحيدة في المكدس
            // هذا يمنع أي شاشات سابقة (مثل شاشة تسجيل الدخول) من الظهور أو التداخل.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const ResetPasswordScreen(),
              ),
                  (route) => false, // إزالة جميع المسارات السابقة من المكدس
            );
          } else {
            print('❌ لم يتم العثور على Navigator Context في DeepLinkHandler عند passwordRecovery.');
          }
        }
        // يمكنك إضافة المزيد من الشروط لأحداث أخرى هنا إذا لزم الأمر
        // else if (event == AuthChangeEvent.signedIn) { ... }
        // else if (event == AuthChangeEvent.signedOut) { ... }
      });

      // التحقق من وجود deep link عند فتح التطبيق
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 تم العثور على Deep Link أولي: $initialUri');
        await _handleDeepLink(initialUri);
      }

      // الاستماع للـ deep links الجديدة
      _linkSubscription = _appLinks.uriLinkStream.listen(
            (uri) async {
          print('🔗 تم استلام Deep Link جديد: $uri');
          await _handleDeepLink(uri);
        },
        onError: (err) {
          print('❌ خطأ في Deep Link: $err');
        },
      );

      print('✅ تم تهيئة Deep Link Handler بنجاح');
    } catch (e) {
      print('❌ خطأ في تهيئة Deep Link Handler: $e');
    }
  }

  /// معالجة Deep Link
  static Future<void> _handleDeepLink(Uri uri) async {
    print('🔗 معالجة Deep Link: $uri');
    print('🔗 Scheme: ${uri.scheme}');
    print('🔗 Host: ${uri.host}');
    print('🔗 Path: ${uri.path}');
    print('🔗 Query Parameters: ${uri.queryParameters}');

    try {
      // التحقق من scheme التطبيق
      // هنا نفترض أن AppConfig.deepLinkScheme هو 'accessaddress'
      if (uri.scheme == 'accessaddress') { // استخدم القيمة الثابتة أو AppConfig إذا كانت معرفة
        if (uri.host == 'reset-password') {
          print('🔗 معالجة رابط إعادة تعيين كلمة المرور');
          // لا نحتاج لاستدعاء _handlePasswordReset هنا
          // لأن Supabase SDK سيتعامل مع الرمز المميز ويطلق AuthChangeEvent.passwordRecovery
          // والذي سيتم التقاطه بواسطة مستمع onAuthStateChange
          // ومع ذلك، إذا كان الرابط يحتوي على access_token و refresh_token
          // فمن الأفضل تعيين الجلسة يدوياً لضمان أن Supabase SDK يتعرف عليها
          final accessToken = uri.queryParameters['access_token'];
          final refreshToken = uri.queryParameters['refresh_token'];

          if (accessToken != null && refreshToken != null) {
            await _handleSupabaseAuthTokens(accessToken, refreshToken);
          }
        } else {
          print('🔗 Deep Link غير معروف: ${uri.host}');
        }
      } else {
        print('🔗 Scheme غير صحيح: ${uri.scheme}');
      }
    } catch (e) {
      print('❌ خطأ في معالجة Deep Link: $e');
    }
  }

  /// معالجة tokens من Supabase Auth
  static Future<void> _handleSupabaseAuthTokens(String accessToken, String refreshToken) async {
    try {
      print('🔐 تعيين الجلسة في Supabase يدوياً...');
      // هذا سيؤدي إلى إطلاق AuthChangeEvent.signedIn أو AuthChangeEvent.passwordRecovery
      // اعتماداً على نوع الجلسة. onAuthStateChange listener في initialize سيقوم بالتعامل مع التوجيه.
      final response = await Supabase.instance.client.auth.setSession(
        accessToken,
      );

      if (response.session != null) {
        print('✅ تم تعيين الجلسة بنجاح يدوياً.');
      } else {
        print('❌ فشل في تعيين الجلسة يدوياً.');
      }
    } catch (e) {
      print('❌ خطأ في معالجة Supabase tokens يدوياً: $e');
    }
  }

  // تم إزالة _handleRecoveryToken و _navigateToPasswordReset
  // لأن onAuthStateChange هو المسؤول عن التوجيه الآن

  /// تنظيف الموارد
  static void dispose() {
    print('🧹 تنظيف Deep Link Handler...');
    _linkSubscription?.cancel();
    _authStateSubscription?.cancel(); // إلغاء استماع حالة المصادقة
  }
}
