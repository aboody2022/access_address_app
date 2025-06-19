// // lib/services/otp_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class OTPService {
//   static final _supabase = Supabase.instance.client;
//
//   // إرسال OTP باستخدام Supabase Auth مباشرة
//   static Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
//     try {
//       print('🚀 إرسال OTP باستخدام Supabase Auth...');
//       print('📧 البريد: $email');
//
//       // التحقق من وجود المستخدم في جدول users أولاً
//       final userCheck = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, uid')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userCheck == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       print('✅ تم العثور على المستخدم: ${userCheck['full_name']}');
//
//       // توليد OTP محلي وحفظه
//       final otp = _generateOTP();
//       final expiresAt = DateTime.now().add(Duration(minutes: 10));
//
//       print('🎲 OTP المولد محلياً: $otp');
//
//       // حذف OTP القديمة أولاً
//       try {
//         await _supabase
//             .from('password_reset_otps')
//             .delete()
//             .eq('email', email.trim().toLowerCase());
//         print('🗑️ تم حذف OTP القديمة');
//       } catch (e) {
//         print('⚠️ لا توجد OTP قديمة للحذف: $e');
//       }
//
//       // حفظ OTP الجديدة في قاعدة البيانات
//       // استخدام الأعمدة الصحيحة: otp_code, used
//       await _supabase.from('password_reset_otps').insert({
//         'email': email.trim().toLowerCase(),
//         'otp_code': otp,  // تغيير من otp إلى otp_code
//         'expires_at': expiresAt.toIso8601String(),
//         'created_at': DateTime.now().toIso8601String(),
//         'used': false,    // تغيير من verified إلى used
//       });
//
//       print('💾 تم حفظ OTP في قاعدة البيانات');
//
//       // محاولة إرسال البريد باستخدام Supabase Auth (اختياري)
//       try {
//         await _supabase.auth.resetPasswordForEmail(
//           email.trim().toLowerCase(),
//           redirectTo: 'accessaddress://reset-password',
//         );
//         print('📧 تم إرسال رابط إعادة التعيين أيضاً');
//       } catch (e) {
//         print('⚠️ لم يتم إرسال البريد: $e');
//       }
//
//       return {
//         'success': true,
//         'message': 'تم توليد رمز التحقق بنجاح!\n\n🔢 رمز التحقق: $otp\n\n⏰ صالح لمدة 10 دقائق\n\n👤 للمستخدم: ${userCheck['full_name']}',
//         'email_sent': true,
//         'otp_for_testing': otp,
//         'user_name': userCheck['full_name'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في sendPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في إرسال رمز التحقق: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من OTP
//   static Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
//     try {
//       print('🔍 التحقق من OTP: $otp للبريد: $email');
//
//       // استخدام الأعمدة الصحيحة: otp_code, used
//       final result = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('otp_code', otp.trim())  // تغيير من otp إلى otp_code
//           .eq('used', false)           // تغيير من verified إلى used
//           .gt('expires_at', DateTime.now().toIso8601String())
//           .maybeSingle();
//
//       if (result == null) {
//         // التحقق من السبب
//         final allOtps = await _supabase
//             .from('password_reset_otps')
//             .select('*')
//             .eq('email', email.trim().toLowerCase())
//             .order('created_at', ascending: false)
//             .limit(1);
//
//         if (allOtps.isEmpty) {
//           return {
//             'success': false,
//             'error': 'لم يتم العثور على رمز تحقق لهذا البريد',
//           };
//         }
//
//         final latestOtp = allOtps.first;
//         if (latestOtp['otp_code'] != otp.trim()) {  // تغيير من otp إلى otp_code
//           return {
//             'success': false,
//             'error': 'رمز التحقق غير صحيح',
//           };
//         }
//
//         if (latestOtp['used'] == true) {  // تغيير من verified إلى used
//           return {
//             'success': false,
//             'error': 'تم استخدام هذا الرمز مسبقاً',
//           };
//         }
//
//         if (DateTime.parse(latestOtp['expires_at']).isBefore(DateTime.now())) {
//           return {
//             'success': false,
//             'error': 'انتهت صلاحية رمز التحقق',
//           };
//         }
//
//         return {
//           'success': false,
//           'error': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
//         };
//       }
//
//       // تحديث حالة الاستخدام
//       await _supabase
//           .from('password_reset_otps')
//           .update({
//         'used': true,  // تغيير من verified إلى used
//       })
//           .eq('id', result['id']);
//
//       print('✅ تم التحقق من OTP بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم التحقق من الرمز بنجاح',
//         'verified_at': DateTime.now().toIso8601String(),
//       };
//
//     } catch (e) {
//       print('💥 خطأ في verifyPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في التحقق من الرمز: ${e.toString()}',
//       };
//     }
//   }
//
//   // تغيير كلمة المرور
//   static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
//     try {
//       print('🔄 تغيير كلمة المرور للبريد: $email');
//
//       // التحقق من وجود OTP مُستخدم حديثاً
//       final otpCheck = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('used', true)  // تغيير من verified إلى used
//           .gt('expires_at', DateTime.now().subtract(Duration(hours: 1)).toIso8601String())
//           .order('created_at', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (otpCheck == null) {
//         return {
//           'success': false,
//           'error': 'يجب التحقق من رمز OTP أولاً',
//         };
//       }
//
//       // تشفير كلمة المرور الجديدة
//       // استخدم مكتبة crypt.dart هنا
//       final hashedPassword = newPassword; // مؤقتاً - يجب استخدام التشفير الصحيح
//
//       // تحديث كلمة المرور في جدول users
//       final updateResult = await _supabase
//           .from('users')
//           .update({
//         'password': hashedPassword,
//         'updated_at': DateTime.now().toIso8601String(),
//       })
//           .eq('email', email.trim().toLowerCase())
//           .select('full_name');
//
//       if (updateResult.isEmpty) {
//         return {
//           'success': false,
//           'error': 'فشل في تحديث كلمة المرور',
//         };
//       }
//
//       // حذف جميع OTP للمستخدم
//       await _supabase
//           .from('password_reset_otps')
//           .delete()
//           .eq('email', email.trim().toLowerCase());
//
//       print('✅ تم تغيير كلمة المرور بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح للمستخدم: ${updateResult.first['full_name']}',
//         'updated_at': DateTime.now().toIso8601String(),
//         'user_name': updateResult.first['full_name'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في resetPassword: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // توليد OTP
//   static String _generateOTP() {
//     final random = DateTime.now().millisecondsSinceEpoch;
//     return (random % 900000 + 100000).toString();
//   }
//
//   // باقي الدوال المساعدة...
//   static bool isValidEmail(String email) {
//     return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
//   }
//
//   static Map<String, dynamic> checkPasswordStrength(String password) {
//     if (password.length < 6) {
//       return {
//         'isStrong': false,
//         'message': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
//       };
//     }
//
//     if (password.length < 8) {
//       return {
//         'isStrong': false,
//         'message': 'كلمة المرور ضعيفة - يُنصح بـ 8 أحرف على الأقل'
//       };
//     }
//
//     bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
//     bool hasLowercase = password.contains(RegExp(r'[a-z]'));
//     bool hasDigits = password.contains(RegExp(r'[0-9]'));
//     bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//
//     int strength = 0;
//     if (hasUppercase) strength++;
//     if (hasLowercase) strength++;
//     if (hasDigits) strength++;
//     if (hasSpecialCharacters) strength++;
//
//     if (strength >= 3) {
//       return {
//         'isStrong': true,
//         'message': 'كلمة مرور قوية'
//       };
//     } else if (strength >= 2) {
//       return {
//         'isStrong': true,
//         'message': 'كلمة مرور متوسطة القوة'
//       };
//     } else {
//       return {
//         'isStrong': false,
//         'message': 'كلمة المرور ضعيفة - استخدم أحرف كبيرة وصغيرة وأرقام'
//       };
//     }
//   }
//
//   // إضافة هذه الدالة في OTPService
//   static Future<Map<String, dynamic>> getUserSecurityQuestion(String email) async {
//     try {
//       print('🔍 البحث عن سؤال الأمان للبريد: $email');
//
//       final userResult = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, security_question, answer_security_qu')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userResult == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (userResult['security_question'] == null || userResult['security_question'].toString().trim().isEmpty) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين سؤال أمان لهذا الحساب',
//         };
//       }
//
//       return {
//         'success': true,
//         'user_name': userResult['full_name'],
//         'security_question': userResult['security_question'],
//         'security_answer': userResult['answer_security_qu'], // للتحقق الداخلي فقط
//       };
//
//     } catch (e) {
//       print('💥 خطأ في getUserSecurityQuestion: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في الحصول على سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
// }


// lib/services/otp_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:crypt/crypt.dart';
//
// class OTPService {
//   static final _supabase = Supabase.instance.client;
//
//   // إرسال OTP باستخدام Supabase Auth مباشرة
//   static Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
//     try {
//       print('🚀 إرسال OTP باستخدام Supabase Auth...');
//       print('📧 البريد: $email');
//
//       // التحقق من وجود المستخدم في جدول users أولاً
//       final userCheck = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, uid')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userCheck == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       print('✅ تم العثور على المستخدم: ${userCheck['full_name']}');
//
//       // توليد OTP محلي وحفظه
//       final otp = _generateOTP();
//       final expiresAt = DateTime.now().add(Duration(minutes: 10));
//
//       print('🎲 OTP المولد محلياً: $otp');
//
//       // حذف OTP القديمة أولاً
//       try {
//         await _supabase
//             .from('password_reset_otps')
//             .delete()
//             .eq('email', email.trim().toLowerCase());
//         print('🗑️ تم حذف OTP القديمة');
//       } catch (e) {
//         print('⚠️ لا توجد OTP قديمة للحذف: $e');
//       }
//
//       // حفظ OTP الجديدة في قاعدة البيانات
//       await _supabase.from('password_reset_otps').insert({
//         'email': email.trim().toLowerCase(),
//         'otp_code': otp,
//         'expires_at': expiresAt.toIso8601String(),
//         'created_at': DateTime.now().toIso8601String(),
//         'used': false,
//       });
//
//       print('💾 تم حفظ OTP في قاعدة البيانات');
//
//       // محاولة إرسال البريد باستخدام Supabase Auth (اختياري)
//       try {
//         await _supabase.auth.resetPasswordForEmail(
//           email.trim().toLowerCase(),
//           redirectTo: 'accessaddress://reset-password',
//         );
//         print('📧 تم إرسال رابط إعادة التعيين أيضاً');
//       } catch (e) {
//         print('⚠️ لم يتم إرسال البريد: $e');
//       }
//
//       return {
//         'success': true,
//         'message': 'تم إرسال رمز التحقق بنجاح إلى بريدك الإلكتروني',
//         'email_sent': true,
//         'otp_for_testing': otp, // للاختبار فقط - احذف هذا في الإنتاج
//         'user_name': userCheck['full_name'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في sendPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في إرسال رمز التحقق: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من OTP
//   static Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
//     try {
//       print('🔍 التحقق من OTP: $otp للبريد: $email');
//
//       final result = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('otp_code', otp.trim())
//           .eq('used', false)
//           .gt('expires_at', DateTime.now().toIso8601String())
//           .maybeSingle();
//
//       if (result == null) {
//         // التحقق من السبب
//         final allOtps = await _supabase
//             .from('password_reset_otps')
//             .select('*')
//             .eq('email', email.trim().toLowerCase())
//             .order('created_at', ascending: false)
//             .limit(1);
//
//         if (allOtps.isEmpty) {
//           return {
//             'success': false,
//             'error': 'لم يتم العثور على رمز تحقق لهذا البريد',
//           };
//         }
//
//         final latestOtp = allOtps.first;
//         if (latestOtp['otp_code'] != otp.trim()) {
//           return {
//             'success': false,
//             'error': 'رمز التحقق غير صحيح',
//           };
//         }
//
//         if (latestOtp['used'] == true) {
//           return {
//             'success': false,
//             'error': 'تم استخدام هذا الرمز مسبقاً',
//           };
//         }
//
//         if (DateTime.parse(latestOtp['expires_at']).isBefore(DateTime.now())) {
//           return {
//             'success': false,
//             'error': 'انتهت صلاحية رمز التحقق',
//           };
//         }
//
//         return {
//           'success': false,
//           'error': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
//         };
//       }
//
//       // تحديث حالة الاستخدام
//       await _supabase
//           .from('password_reset_otps')
//           .update({
//         'used': true,
//         'verified_at': DateTime.now().toIso8601String(),
//       })
//           .eq('id', result['id']);
//
//       print('✅ تم التحقق من OTP بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم التحقق من الرمز بنجاح',
//         'verified_at': DateTime.now().toIso8601String(),
//       };
//
//     } catch (e) {
//       print('💥 خطأ في verifyPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في التحقق من الرمز: ${e.toString()}',
//       };
//     }
//   }
//
//   // تغيير كلمة المرور مع التشفير المناسب
//   static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
//     try {
//       print('🔄 تغيير كلمة المرور للبريد: $email');
//
//       // التحقق من وجود OTP مُستخدم حديثاً
//       final otpCheck = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('used', true)
//           .gt('expires_at', DateTime.now().subtract(Duration(hours: 1)).toIso8601String())
//           .order('created_at', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (otpCheck == null) {
//         return {
//           'success': false,
//           'error': 'يجب التحقق من رمز OTP أولاً',
//         };
//       }
//
//       // تشفير كلمة المرور الجديدة باستخدام نفس الطريقة المستخدمة في التطبيق
//       final hashedPassword = _encryptPassword(newPassword);
//
//       // تحديث كلمة المرور في جدول users
//       final updateResult = await _supabase
//           .from('users')
//           .update({
//         'password': hashedPassword,
//         'updated_at': DateTime.now().toIso8601String(),
//       })
//           .eq('email', email.trim().toLowerCase())
//           .select('full_name, username');
//
//       if (updateResult.isEmpty) {
//         return {
//           'success': false,
//           'error': 'فشل في تحديث كلمة المرور',
//         };
//       }
//
//       // حذف جميع OTP للمستخدم
//       await _supabase
//           .from('password_reset_otps')
//           .delete()
//           .eq('email', email.trim().toLowerCase());
//
//       print('✅ تم تغيير كلمة المرور بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح',
//         'updated_at': DateTime.now().toIso8601String(),
//         'user_name': updateResult.first['full_name'],
//         'username': updateResult.first['username'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في resetPassword: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من إجابة سؤال الأمان
//   static Future<Map<String, dynamic>> verifySecurityAnswer(String email, String answer) async {
//     try {
//       print('🔍 التحقق من إجابة سؤال الأمان للبريد: $email');
//
//       final userResult = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, security_question, answer_security_qu')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userResult == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (userResult['answer_security_qu'] == null) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين إجابة سؤال الأمان لهذا الحساب',
//         };
//       }
//
//       // التحقق من صحة الإجابة
//       final storedAnswer = userResult['answer_security_qu'].toString();
//       final normalizedAnswer = answer.trim().toLowerCase();
//
//       // يمكنك استخدام التشفير هنا إذا كانت الإجابات مشفرة
//       bool isCorrect = false;
//
//       try {
//         // محاولة التحقق باستخدام التشفير
//         final crypt = Crypt(storedAnswer);
//         isCorrect = crypt.match(normalizedAnswer);
//       } catch (e) {
//         // إذا فشل التشفير، قارن النص العادي
//         isCorrect = storedAnswer.toLowerCase() == normalizedAnswer;
//       }
//
//       if (!isCorrect) {
//         return {
//           'success': false,
//           'error': 'إجابة سؤال الأمان غير صحيحة',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم التحقق من إجابة سؤال الأمان بنجاح',
//         'user_name': userResult['full_name'],
//         'verified_at': DateTime.now().toIso8601String(),
//       };
//
//     } catch (e) {
//       print('💥 خطأ في verifySecurityAnswer: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في التحقق من إجابة سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
//
//   // إعادة تعيين كلمة المرور باستخدام سؤال الأمان
//   static Future<Map<String, dynamic>> resetPasswordWithSecurityAnswer(
//       String email,
//       String answer,
//       String newPassword
//       ) async {
//     try {
//       // التحقق من إجابة سؤال الأمان أولاً
//       final verificationResult = await verifySecurityAnswer(email, answer);
//
//       if (!verificationResult['success']) {
//         return verificationResult;
//       }
//
//       // تشفير كلمة المرور الجديدة
//       final hashedPassword = _encryptPassword(newPassword);
//
//       // تحديث كلمة المرور في جدول users
//       final updateResult = await _supabase
//           .from('users')
//           .update({
//         'password': hashedPassword,
//         'updated_at': DateTime.now().toIso8601String(),
//       })
//           .eq('email', email.trim().toLowerCase())
//           .select('full_name, username');
//
//       if (updateResult.isEmpty) {
//         return {
//           'success': false,
//           'error': 'فشل في تحديث كلمة المرور',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح باستخدام سؤال الأمان',
//         'updated_at': DateTime.now().toIso8601String(),
//         'user_name': updateResult.first['full_name'],
//         'username': updateResult.first['username'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في resetPasswordWithSecurityAnswer: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // توليد OTP محسن
//   static String _generateOTP() {
//     final now = DateTime.now();
//     final random = (now.millisecondsSinceEpoch % 900000) + 100000;
//     return random.toString();
//   }
//
//   // تشفير كلمة المرور باستخدام نفس الطريقة المستخدمة في التطبيق
//   static String _encryptPassword(String password) {
//     try {
//       // استخدام SHA-256 مع 10000 جولة كما هو محدد في PasswordCryptService
//       final crypt = Crypt.sha256(password, rounds: 10000);
//       return crypt.toString();
//     } catch (e) {
//       print('خطأ في تشفير كلمة المرور: $e');
//       // fallback إلى تشفير بسيط
//       final crypt = Crypt.sha256(password);
//       return crypt.toString();
//     }
//   }
//
//   // التحقق من تطابق كلمة المرور
//   static bool _verifyPassword(String password, String hashedPassword) {
//     try {
//       final crypt = Crypt(hashedPassword);
//       return crypt.match(password);
//     } catch (e) {
//       print('خطأ في التحقق من كلمة المرور: $e');
//       return false;
//     }
//   }
//
//   // الحصول على سؤال الأمان للمستخدم
//   static Future<Map<String, dynamic>> getUserSecurityQuestion(String email) async {
//     try {
//       print('🔍 البحث عن سؤال الأمان للبريد: $email');
//
//       final userResult = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, security_question, answer_security_qu')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userResult == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (userResult['security_question'] == null ||
//           userResult['security_question'].toString().trim().isEmpty) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين سؤال أمان لهذا الحساب',
//         };
//       }
//
//       return {
//         'success': true,
//         'user_name': userResult['full_name'],
//         'security_question': userResult['security_question'],
//         'has_security_answer': userResult['answer_security_qu'] != null,
//       };
//
//     } catch (e) {
//       print('💥 خطأ في getUserSecurityQuestion: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في الحصول على سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من صحة البريد الإلكتروني
//   static bool isValidEmail(String email) {
//     return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
//   }
//
//   // فحص قوة كلمة المرور
//   static Map<String, dynamic> checkPasswordStrength(String password) {
//     if (password.length < 6) {
//       return {
//         'isStrong': false,
//         'message': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
//         'strength': 0,
//       };
//     }
//
//     int strength = 0;
//     String message = '';
//
//     if (password.length >= 8) strength++;
//     if (password.contains(RegExp(r'[A-Z]'))) strength++;
//     if (password.contains(RegExp(r'[a-z]'))) strength++;
//     if (password.contains(RegExp(r'[0-9]'))) strength++;
//     if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) strength++;
//
//     switch (strength) {
//       case 0:
//       case 1:
//         message = 'كلمة المرور ضعيفة جداً';
//         break;
//       case 2:
//         message = 'كلمة المرور ضعيفة';
//         break;
//       case 3:
//         message = 'كلمة المرور متوسطة';
//         break;
//       case 4:
//         message = 'كلمة المرور قوية';
//         break;
//       case 5:
//         message = 'كلمة المرور قوية جداً';
//         break;
//     }
//
//     return {
//       'isStrong': strength >= 3,
//       'message': message,
//       'strength': strength,
//     };
//   }
//
//   // تنظيف OTP المنتهية الصلاحية
//   static Future<void> cleanupExpiredOTPs() async {
//     try {
//       await _supabase
//           .from('password_reset_otps')
//           .delete()
//           .lt('expires_at', DateTime.now().toIso8601String());
//       print('🧹 تم تنظيف OTP المنتهية الصلاحية');
//     } catch (e) {
//       print('⚠️ خطأ في تنظيف OTP: $e');
//     }
//   }
// }


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:crypt/crypt.dart';
//
// class OTPService {
//   static final _supabase = Supabase.instance.client;
//
//   // إرسال OTP باستخدام Supabase Auth مباشرة
//   static Future<Map<String, dynamic>> sendPasswordResetOTP(String email ) async {
//     try {
//       print('🚀 إرسال OTP باستخدام Supabase Auth...');
//       print('📧 البريد: $email');
//
//       // التحقق من وجود المستخدم في جدول users أولاً
//       final userCheck = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, uid')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userCheck == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       print('✅ تم العثور على المستخدم: ${userCheck['full_name']}');
//
//       // توليد OTP محلي وحفظه
//       final otp = _generateOTP();
//       final expiresAt = DateTime.now().add(Duration(minutes: 10));
//
//       print('🎲 OTP المولد محلياً: $otp');
//
//       // حذف OTP القديمة أولاً
//       try {
//         await _supabase
//             .from('password_reset_otps')
//             .delete()
//             .eq('email', email.trim().toLowerCase());
//         print('🗑️ تم حذف OTP القديمة');
//       } catch (e) {
//         print('⚠️ لا توجد OTP قديمة للحذف: $e');
//       }
//
//       // حفظ OTP الجديدة في قاعدة البيانات
//       await _supabase.from('password_reset_otps').insert({
//         'email': email.trim().toLowerCase(),
//         'otp_code': otp,
//         'expires_at': expiresAt.toIso8601String(),
//         'created_at': DateTime.now().toIso8601String(),
//         'used': false,
//       });
//
//       print('💾 تم حفظ OTP في قاعدة البيانات');
//
//       // استدعاء Supabase Edge Function لإرسال البريد الإلكتروني مع OTP
//       try {
//         final response = await _supabase.functions.invoke(
//           'send-otp-email', // اسم Edge Function الذي قمت بنشره
//           body: {
//             'email': email.trim().toLowerCase(),
//             'otp': otp,
//           },
//         );
//
//         if (response.status == 200) {
//           print('📧 تم إرسال البريد الإلكتروني بنجاح عبر Edge Function');
//         } else {
//           print('⚠️ فشل إرسال البريد الإلكتروني عبر Edge Function: ${response.data}');
//         }
//       } catch (e) {
//         print('💥 خطأ في استدعاء Edge Function: $e');
//       }
//
//       return {
//         'success': true,
//         'message': 'تم إرسال رمز التحقق بنجاح إلى بريدك الإلكتروني',
//         'email_sent': true,
//         'otp_for_testing': otp, // للاختبار فقط - احذف هذا في الإنتاج
//         'user_name': userCheck['full_name'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في sendPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في إرسال رمز التحقق: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من OTP
//   static Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
//     try {
//       print('🔍 التحقق من OTP: $otp للبريد: $email');
//
//       final result = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('otp_code', otp.trim())
//           .eq('used', false)
//           .gt('expires_at', DateTime.now().toIso8601String())
//           .maybeSingle();
//
//       if (result == null) {
//         // التحقق من السبب
//         final allOtps = await _supabase
//             .from('password_reset_otps')
//             .select('*')
//             .eq('email', email.trim().toLowerCase())
//             .order('created_at', ascending: false)
//             .limit(1);
//
//         if (allOtps.isEmpty) {
//           return {
//             'success': false,
//             'error': 'لم يتم العثور على رمز تحقق لهذا البريد',
//           };
//         }
//
//         final latestOtp = allOtps.first;
//         if (latestOtp['otp_code'] != otp.trim()) {
//           return {
//             'success': false,
//             'error': 'رمز التحقق غير صحيح',
//           };
//         }
//
//         if (latestOtp['used'] == true) {
//           return {
//             'success': false,
//             'error': 'تم استخدام هذا الرمز مسبقاً',
//           };
//         }
//
//         if (DateTime.parse(latestOtp['expires_at']).isBefore(DateTime.now())) {
//           return {
//             'success': false,
//             'error': 'انتهت صلاحية رمز التحقق',
//           };
//         }
//
//         return {
//           'success': false,
//           'error': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
//         };
//       }
//
//       // تحديث حالة الاستخدام
//       await _supabase
//           .from('password_reset_otps')
//           .update({
//         'used': true,
//         'verified_at': DateTime.now().toIso8601String(),
//       })
//           .eq('id', result['id']);
//
//       print('✅ تم التحقق من OTP بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم التحقق من الرمز بنجاح',
//         'verified_at': DateTime.now().toIso8601String(),
//       };
//
//     } catch (e) {
//       print('💥 خطأ في verifyPasswordResetOTP: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في التحقق من الرمز: ${e.toString()}',
//       };
//     }
//   }
//
//   // تغيير كلمة المرور مع التشفير المناسب
//   static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
//     try {
//       print('🔄 تغيير كلمة المرور للبريد: $email');
//
//       // التحقق من وجود OTP مُستخدم حديثاً
//       final otpCheck = await _supabase
//           .from('password_reset_otps')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .eq('used', true)
//           .gt('expires_at', DateTime.now().subtract(Duration(hours: 1)).toIso8601String())
//           .order('created_at', ascending: false)
//           .limit(1)
//           .maybeSingle();
//
//       if (otpCheck == null) {
//         return {
//           'success': false,
//           'error': 'يجب التحقق من رمز OTP أولاً',
//         };
//       }
//
//       // تشفير كلمة المرور الجديدة باستخدام نفس الطريقة المستخدمة في التطبيق
//       final hashedPassword = _encryptPassword(newPassword);
//
//       // تحديث كلمة المرور في جدول users
//       final updateResult = await _supabase
//           .from('users')
//           .update({
//         'password': hashedPassword,
//         'updated_at': DateTime.now().toIso8601String(),
//       })
//           .eq('email', email.trim().toLowerCase())
//           .select('full_name, username');
//
//       if (updateResult.isEmpty) {
//         return {
//           'success': false,
//           'error': 'فشل في تحديث كلمة المرور',
//         };
//       }
//
//       // حذف جميع OTP للمستخدم
//       await _supabase
//           .from('password_reset_otps')
//           .delete()
//           .eq('email', email.trim().toLowerCase());
//
//       print('✅ تم تغيير كلمة المرور بنجاح');
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح',
//         'updated_at': DateTime.now().toIso8601String(),
//         'user_name': updateResult.first['full_name'],
//         'username': updateResult.first['username'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في resetPassword: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من إجابة سؤال الأمان
//   static Future<Map<String, dynamic>> verifySecurityAnswer(String email, String answer) async {
//     try {
//       print('🔍 التحقق من إجابة سؤال الأمان للبريد: $email');
//
//       final userResult = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, security_question, answer_security_qu')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userResult == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (userResult['answer_security_qu'] == null) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين إجابة سؤال الأمان لهذا الحساب',
//         };
//       }
//
//       // التحقق من صحة الإجابة
//       final storedAnswer = userResult['answer_security_qu'].toString();
//       final normalizedAnswer = answer.trim().toLowerCase();
//
//       // يمكنك استخدام التشفير هنا إذا كانت الإجابات مشفرة
//       bool isCorrect = false;
//
//       try {
//         // محاولة التحقق باستخدام التشفير
//         final crypt = Crypt(storedAnswer);
//         isCorrect = crypt.match(normalizedAnswer);
//       } catch (e) {
//         // إذا فشل التشفير، قارن النص العادي
//         isCorrect = storedAnswer.toLowerCase() == normalizedAnswer;
//       }
//
//       if (!isCorrect) {
//         return {
//           'success': false,
//           'error': 'إجابة سؤال الأمان غير صحيحة',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم التحقق من إجابة سؤال الأمان بنجاح',
//         'user_name': userResult['full_name'],
//         'verified_at': DateTime.now().toIso8601String(),
//       };
//
//     } catch (e) {
//       print('💥 خطأ في verifySecurityAnswer: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في التحقق من إجابة سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
//
//   // إعادة تعيين كلمة المرور باستخدام سؤال الأمان
//   static Future<Map<String, dynamic>> resetPasswordWithSecurityAnswer(
//       String email,
//       String answer,
//       String newPassword
//       ) async {
//     try {
//       // التحقق من إجابة سؤال الأمان أولاً
//       final verificationResult = await verifySecurityAnswer(email, answer);
//
//       if (!verificationResult['success']) {
//         return verificationResult;
//       }
//
//       // تشفير كلمة المرور الجديدة
//       final hashedPassword = _encryptPassword(newPassword);
//
//       // تحديث كلمة المرور في جدول users
//       final updateResult = await _supabase
//           .from('users')
//           .update({
//         'password': hashedPassword,
//         'updated_at': DateTime.now().toIso8601String(),
//       })
//           .eq('email', email.trim().toLowerCase())
//           .select('full_name, username');
//
//       if (updateResult.isEmpty) {
//         return {
//           'success': false,
//           'error': 'فشل في تحديث كلمة المرور',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح باستخدام سؤال الأمان',
//         'updated_at': DateTime.now().toIso8601String(),
//         'user_name': updateResult.first['full_name'],
//         'username': updateResult.first['username'],
//       };
//
//     } catch (e) {
//       print('💥 خطأ في resetPasswordWithSecurityAnswer: $e');
//       return {
//         'success': false,
//         'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // توليد OTP محسن
//   static String _generateOTP() {
//     final now = DateTime.now();
//     final random = (now.millisecondsSinceEpoch % 900000) + 100000;
//     return random.toString();
//   }
//
//   // تشفير كلمة المرور باستخدام نفس الطريقة المستخدمة في التطبيق
//   static String _encryptPassword(String password) {
//     try {
//       // استخدام SHA-256 مع 10000 جولة كما هو محدد في PasswordCryptService
//       final crypt = Crypt.sha256(password, rounds: 10000);
//       return crypt.toString();
//     } catch (e) {
//       print('خطأ في تشفير كلمة المرور: $e');
//       // fallback إلى تشفير بسيط
//       final crypt = Crypt.sha256(password);
//       return crypt.toString();
//     }
//   }
//
//   // التحقق من تطابق كلمة المرور
//   static bool _verifyPassword(String password, String hashedPassword) {
//     try {
//       final crypt = Crypt(hashedPassword);
//       return crypt.match(password);
//     } catch (e) {
//       print('خطأ في التحقق من كلمة المرور: $e');
//       return false;
//     }
//   }
//
//   // الحصول على سؤال الأمان للمستخدم
//   static Future<Map<String, dynamic>> getUserSecurityQuestion(String email) async {
//     try {
//       print('🔍 البحث عن سؤال الأمان للبريد: $email');
//
//       final userResult = await _supabase
//           .from('users')
//           .select('user_id, full_name, email, security_question, answer_security_qu')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (userResult == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (userResult['security_question'] == null ||
//           userResult['security_question'].toString().trim().isEmpty) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين سؤال أمان لهذا الحساب',
//         };
//       }
//
//       return {
//         'success': true,
//         'user_name': userResult['full_name'],
//         'security_question': userResult['security_question'],
//         'has_security_answer': userResult['answer_security_qu'] != null,
//       };
//
//     } catch (e) {
//       print('💥 خطأ في getUserSecurityQuestion: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في الحصول على سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق من صحة البريد الإلكتروني
//   static bool isValidEmail(String email) {
//     return RegExp(r'^[\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
//   }
//
//   // فحص قوة كلمة المرور
//   static Map<String, dynamic> checkPasswordStrength(String password) {
//     if (password.length < 6) {
//       return {
//         'isStrong': false,
//         'message': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
//         'strength': 0,
//       };
//     }
//
//     int strength = 0;
//     String message = '';
//
//     if (password.length >= 8) strength++;
//     if (password.contains(RegExp(r'[A-Z]'))) strength++;
//     if (password.contains(RegExp(r'[a-z]'))) strength++;
//     if (password.contains(RegExp(r'[0-9]'))) strength++;
//     if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) strength++;
//
//     switch (strength) {
//       case 0:
//       case 1:
//         message = 'كلمة المرور ضعيفة جداً';
//         break;
//       case 2:
//         message = 'كلمة المرور ضعيفة';
//         break;
//       case 3:
//         message = 'كلمة المرور متوسطة';
//         break;
//       case 4:
//         message = 'كلمة المرور قوية';
//         break;
//       case 5:
//         message = 'كلمة المرور قوية جداً';
//         break;
//     }
//
//     return {
//       'isStrong': strength >= 3,
//       'message': message,
//       'strength': strength,
//     };
//   }
//
//   // تنظيف OTP المنتهية الصلاحية
//   static Future<void> cleanupExpiredOTPs() async {
//     try {
//       await _supabase
//           .from('password_reset_otps')
//           .delete()
//           .lt('expires_at', DateTime.now().toIso8601String());
//       print('🧹 تم تنظيف OTP المنتهية الصلاحية');
//     } catch (e) {
//       print('⚠️ خطأ في تنظيف OTP: $e');
//     }
//   }
// }


// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:crypt/crypt.dart';
//
// class OTPService {
//   static final _supabase = Supabase.instance.client;
//
//   // إرسال رابط تغيير كلمة المرور عبر البريد
//   static Future<Map<String, dynamic>> sendPasswordResetEmail(
//       String email) async {
//     try {
//       print('🚀 إرسال رابط تغيير كلمة المرور عبر البريد الإلكتروني: $email');
//
//       // التحقق من وجود البريد في قاعدة البيانات
//       final user = await _supabase
//           .from('users')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (user == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       // يرسل Supabase رابط تغيير كلمة المرور على البريد
//       await _supabase.auth.resetPasswordForEmail(
//         email.trim().toLowerCase(),
//         redirectTo: 'accessaddress://reset-password',
//       );
//
//       return {
//         'success': true,
//         'message': 'تم إرسال رابط تغيير كلمة المرور على البريد الإلكتروني',
//         'user_name': user['full_name'],
//       };
//     } catch (e) {
//       print('💥 خطأ في sendPasswordResetEmail: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في إرسال الرابط: ${e.toString()}',
//       };
//     }
//   }
//
//   // تغيير كلمة المرور بعد التحقق عبر الرابط
//   static Future<Map<String, dynamic>> resetPassword(
//       String newPassword) async {
//     try {
//       print('🔄 تغيير كلمة المرور');
//
//       final res = await _supabase.auth.updateUser(
//         UserAttributes(password: newPassword),
//       );
//
//       if (res.user == null) {
//         return {
//           'success': false,
//           'error': 'فشل في تغيير كلمة المرور',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم تغيير كلمة المرور بنجاح',
//         'user_name': res.user!.userMetadata?['full_name'] ?? 'مستخدم',
//         'username': res.user!.userMetadata?['username'] ?? 'غير معروف',
//       };
//     } catch (e) {
//       print('💥 خطأ في resetPassword: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في تغيير كلمة المرور: ${e.toString()}',
//       };
//     }
//   }
//
//   // التحقق عبر سؤال الأمان
//   static Future<Map<String, dynamic>> verifySecurityAnswer(
//       String email, String answer) async {
//     try {
//       print('🔍 التحقق عبر سؤال الأمان: $email');
//
//       final user = await _supabase
//           .from('users')
//           .select('*')
//           .eq('email', email.trim().toLowerCase())
//           .maybeSingle();
//
//       if (user == null) {
//         return {
//           'success': false,
//           'error': 'البريد الإلكتروني غير مسجل في النظام',
//         };
//       }
//
//       if (user['answer_security_qu'] == null) {
//         return {
//           'success': false,
//           'error': 'لم يتم تعيين إجابة على سؤال الأمان',
//         };
//       }
//
//       // التحقق
//       final stored = user['answer_security_qu'].toString();
//       final normalized = answer.trim().toLowerCase();
//
//       bool isCorrect = false;
//
//       try {
//         final crypt = Crypt(stored);
//         isCorrect = crypt.match(normalized);
//       } catch (e) {
//         isCorrect = stored.toLowerCase() == normalized;
//       }
//
//       if (!isCorrect) {
//         return {
//           'success': false,
//           'error': 'إجابة سؤال الأمان غير صحيحة',
//         };
//       }
//
//       return {
//         'success': true,
//         'message': 'تم التحقق عبر سؤال الأمان',
//         'user_name': user['full_name'],
//       };
//     } catch (e) {
//       print('💥 خطأ في verifySecurityAnswer: $e');
//       return {
//         'success': false,
//         'error': 'حدث خطأ في التحقق عبر سؤال الأمان: ${e.toString()}',
//       };
//     }
//   }
// }
//
//




import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypt/crypt.dart';

class OTPService {
  static final _supabase = Supabase.instance.client;

  // إرسال رابط تغيير كلمة المرور عبر البريد
  static Future<Map<String, dynamic>> sendPasswordResetEmail(
      String email) async {
    try {
      print('🚀 إرسال رابط تغيير كلمة المرور عبر البريد الإلكتروني: $email');

      // التحقق من وجود البريد في قاعدة البيانات
      final user = await _supabase
          .from('users')
          .select('*')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (user == null) {
        return {
          'success': false,
          'error': 'البريد الإلكتروني غير مسجل في النظام',
        };
      }

      // يرسل Supabase رابط تغيير كلمة المرور على البريد
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'accessaddress://reset-password',
      );

      return {
        'success': true,
        'message': 'تم إرسال رابط تغيير كلمة المرور على البريد الإلكتروني',
        'user_name': user['full_name'],
      };
    } catch (e) {
      print('💥 خطأ في sendPasswordResetEmail: $e');
      return {
        'success': false,
        'error': 'حدث خطأ في إرسال الرابط: ${e.toString()}',
      };
    }
  }

  // تغيير كلمة المرور بعد التحقق عبر الرابط
  // static Future<Map<String, dynamic>> resetPassword(
  //     String newPassword) async {
  //   try {
  //     print('🔄 تغيير كلمة المرور');
  //
  //     final UserResponse res = await _supabase.auth.updateUser(
  //       UserAttributes(password: newPassword),
  //     );
  //
  //     if (res.user == null) {
  //       return {
  //         'success': false,
  //         'error': 'فشل في تغيير كلمة المرور',
  //       };
  //     }
  //
  //     return {
  //       'success': true,
  //       'message': 'تم تغيير كلمة المرور بنجاح',
  //       'user_name': res.user!.userMetadata?['full_name'] ?? 'مستخدم',
  //       'username': res.user!.userMetadata?['username'] ?? 'غير معروف',
  //     };
  //   } catch (e) {
  //     print('💥 خطأ في resetPassword: $e');
  //     return {
  //       'success': false,
  //       'error': 'حدث خطأ في تغيير كلمة المرور: ${e.toString()}',
  //     };
  //   }
  // }

  static Future<Map<String, dynamic>> resetPassword(String email,String newPassword) async {
    try {
      print('🔄 تغيير كلمة المرور للبريد: ');

      // تشفير كلمة المرور الجديدة باستخدام نفس الطريقة المستخدمة في التطبيق
      final hashedPassword = _encryptPassword(newPassword);

      // تحديث كلمة المرور في جدول users
      final updateResult = await _supabase
          .from('users')
          .update({
        'password': hashedPassword,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('email', email.trim().toLowerCase())
          .select('full_name, username');

      if (updateResult.isEmpty) {
        return {
          'success': false,
          'error': 'فشل في تحديث كلمة المرور',
        };
      }

      print('✅ تم تغيير كلمة المرور بنجاح');

      return {
        'success': true,
        'message': 'تم تغيير كلمة المرور بنجاح',
        'updated_at': DateTime.now().toIso8601String(),
        'user_name': updateResult.first['full_name'],
        'username': updateResult.first['username'],
      };

    } catch (e) {
      print('💥 خطأ في resetPassword: $e');
      return {
        'success': false,
        'error': 'خطأ في تغيير كلمة المرور: ${e.toString()}',
      };
    }
  }
  // التحقق عبر سؤال الأمان
  static Future<Map<String, dynamic>> verifySecurityAnswer(
      String email, String answer) async {
    try {
      print('🔍 التحقق عبر سؤال الأمان: $email');

      final user = await _supabase
          .from('users')
          .select('*')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (user == null) {
        return {
          'success': false,
          'error': 'البريد الإلكتروني غير مسجل في النظام',
        };
      }

      if (user['answer_security_qu'] == null) {
        return {
          'success': false,
          'error': 'لم يتم تعيين إجابة على سؤال الأمان',
        };
      }

      // التحقق
      final stored = user['answer_security_qu'].toString();
      final normalized = answer.trim().toLowerCase();

      bool isCorrect = false;

      try {
        final crypt = Crypt(stored);
        isCorrect = crypt.match(normalized);
      } catch (e) {
        isCorrect = stored.toLowerCase() == normalized;
      }

      if (!isCorrect) {
        return {
          'success': false,
          'error': 'إجابة سؤال الأمان غير صحيحة',
        };
      }

      return {
        'success': true,
        'message': 'تم التحقق عبر سؤال الأمان',
        'user_name': user['full_name'],
      };
    } catch (e) {
      print('💥 خطأ في verifySecurityAnswer: $e');
      return {
        'success': false,
        'error': 'حدث خطأ في التحقق عبر سؤال الأمان: ${e.toString()}',
      };
    }
  }
  // تشفير كلمة المرور باستخدام نفس الطريقة المستخدمة في التطبيق
  static String _encryptPassword(String password) {
    try {
      // استخدام SHA-256 مع 10000 جولة كما هو محدد في PasswordCryptService
      final crypt = Crypt.sha256(password, rounds: 10000);
      return crypt.toString();
    } catch (e) {
      print('خطأ في تشفير كلمة المرور: $e');
      // fallback إلى تشفير بسيط
      final crypt = Crypt.sha256(password);
      return crypt.toString();
    }
  }

}


