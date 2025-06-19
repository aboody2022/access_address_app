// import 'package:access_address_app/screens/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:adaptive_theme/adaptive_theme.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:async';
// import 'dart:io';
//
// import '../services/otp_service.dart'; // تأكد من أن هذا المسار صحيح
//
// class ResetPasswordScreen extends StatefulWidget {
//   final String? email; // إضافة هذا السطر لاستقبال البريد الإلكتروني
//
//   const ResetPasswordScreen({super.key, this.email});
//
//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }
//
// class _ResetPasswordScreenState extends State<ResetPasswordScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _emailController =
//       TextEditingController(); // لإدارة حقل البريد الإلكتروني إذا كان موجودًا
//
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;
//
//   bool _isNewPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//
//   // Animation controllers
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _errorController;
//   late AnimationController _successController;
//   late AnimationController _buttonController;
//
//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _errorAnimation;
//   late Animation<double> _successAnimation;
//   late Animation<double> _buttonScaleAnimation;
//
//   // Color scheme
//   static const Color primaryColor = Color(0xFF4CB8C4);
//   static const Color secondaryColor = Color(0xFF3CD3AD);
//   static const Color gradientStart = primaryColor;
//   static const Color gradientEnd = secondaryColor;
//
//   // Countdown for auto navigation
//   Timer? _navigationTimer;
//   int _countdown = 3;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _startInitialAnimations();
//
//     // تعيين البريد الإلكتروني إذا تم تمريره إلى الشاشة
//     if (widget.email != null) {
//       _emailController.text = widget.email!;
//     }
//     print("Email::::::::${widget.email}");
//   }
//
//   void _initializeAnimations() {
//     // Fade animation for the entire form
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     // Slide animation for form elements
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
//
//     // Error animation
//     _errorController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _errorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _errorController, curve: Curves.elasticOut),
//     );
//
//     // Success animation
//     _successController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _successController, curve: Curves.bounceOut),
//     );
//
//     // Button scale animation
//     _buttonController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
//     );
//   }
//
//   void _startInitialAnimations() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) {
//         _fadeController.forward();
//         _slideController.forward();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     _emailController.dispose(); // لا تنسَ التخلص منه
//     _fadeController.dispose();
//     _slideController.dispose();
//     _errorController.dispose();
//     _successController.dispose();
//     _buttonController.dispose();
//     _navigationTimer?.cancel();
//     super.dispose();
//   }
//
//   // Enhanced error handling with specific error types
//   String _getEnhancedErrorMessage(dynamic error, Map<String, dynamic>? result) {
//     String errorString = error.toString().toLowerCase();
//
//     // Check for specific error types
//     if (errorString.contains('network') ||
//         errorString.contains('connection') ||
//         errorString.contains('timeout') ||
//         errorString.contains('unreachable')) {
//       return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
//     }
//
//     if (errorString.contains('same') ||
//         errorString.contains('current') ||
//         errorString.contains('identical') ||
//         (result != null && result['error_code'] == 'same_password')) {
//       return 'كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور الحالية';
//     }
//
//     if (errorString.contains('weak') ||
//         errorString.contains('simple') ||
//         (result != null && result['error_code'] == 'weak_password')) {
//       return 'كلمة المرور ضعيفة جداً، يرجى اختيار كلمة مرور أقوى';
//     }
//
//     if (errorString.contains('unauthorized') ||
//         errorString.contains('invalid_token') ||
//         errorString.contains('expired')) {
//       return 'انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول';
//     }
//
//     if (errorString.contains('rate_limit') ||
//         errorString.contains('too_many')) {
//       return 'تم تجاوز عدد المحاولات المسموح، يرجى المحاولة لاحقاً';
//     }
//
//     if (errorString.contains('validation') ||
//         errorString.contains('invalid_format')) {
//       return 'تنسيق كلمة المرور غير صحيح، يرجى المراجعة';
//     }
//
//     // Check for internet connectivity
//     if (errorString.contains('socketexception') ||
//         errorString.contains('no internet') ||
//         errorString.contains('dns')) {
//       return 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الاتصال';
//     }
//
//     // Default error message
//     return result?['error'] ?? 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
//   }
//
//   // Check internet connectivity
//   Future<bool> _checkInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }
//
//   void _showError(String message, {String? details}) {
//     setState(() {
//       _errorMessage = message;
//       _successMessage = null;
//     });
//     _errorController.reset();
//     _errorController.forward();
//
//     // Haptic feedback for error
//     HapticFeedback.heavyImpact();
//
//     // Log detailed error in debug mode
//     if (kDebugMode && details != null) {
//       print('Error Details: $details');
//     }
//   }
//
//   void _showSuccess(String message) {
//     setState(() {
//       _successMessage = message;
//       _errorMessage = null;
//     });
//     _successController.reset();
//     _successController.forward();
//
//     // Haptic feedback for success
//     HapticFeedback.mediumImpact();
//
//     // Start countdown for navigation
//     _startNavigationCountdown();
//   }
//
//   void _startNavigationCountdown() {
//     _countdown = 3;
//     _navigationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           _countdown--;
//         });
//
//         if (_countdown <= 0) {
//           timer.cancel();
//           _navigateToLogin();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   void _navigateToLogin() {
//     if (mounted) {
//       // Navigate to login screen and remove all previous routes
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//     }
//   }
//
//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     // Button press animation
//     _buttonController.forward().then((_) {
//       if (mounted) _buttonController.reverse();
//     });
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _successMessage = null;
//     });
//
//     await HapticFeedback.lightImpact();
//
//     try {
//       // Check internet connection first
//       final hasInternet = await _checkInternetConnection();
//       if (!hasInternet) {
//         _showError(
//             'لا يوجد اتصال بالإنترنت، يرجى التحقق من الاتصال والمحاولة مرة أخرى');
//         return;
//       }
//
//       final newPassword = _newPasswordController.text.trim();
//       final userEmail =
//           _emailController.text.trim(); // الحصول على البريد الإلكتروني
//       print(userEmail);
//       // التأكد من أن البريد الإلكتروني ليس فارغًا
//       if (userEmail.isEmpty) {
//         _showError("الرجاء إدخال البريد الإلكتروني.");
//         return;
//       }
//
//       // تمرير البريد الإلكتروني إلى دالة الخدمة
//       final result = await OTPService.resetPassword(userEmail, newPassword);
//
//       if (result["success"] == true) {
//         _showSuccess(result["message"] ?? "تم تغيير كلمة المرور بنجاح!");
//       } else {
//         String errorMsg = _getEnhancedErrorMessage(
//             result["error"] ?? "فشل في تغيير كلمة المرور", result);
//
//         // Enhanced error messages for debug mode
//         String? debugDetails;
//         if (kDebugMode) {
//           debugDetails = '''
// تفاصيل الخطأ (وضع التطوير):
// - الخطأ الأصلي: ${result["error"]}
// - تفاصيل إضافية: ${result["details"] ?? "غير متوفر"}
// - كود الخطأ: ${result["error_code"] ?? "غير محدد"}
// - الوقت: ${DateTime.now()}
// ''';
//         }
//
//         _showError(errorMsg, details: debugDetails);
//       }
//     } catch (e, stackTrace) {
//       String errorMsg = _getEnhancedErrorMessage(e, null);
//
//       // Detailed error message for debug mode
//       String? debugDetails;
//       if (kDebugMode) {
//         debugDetails = '''
// تفاصيل الخطأ (وضع التطوير):
// - نوع الخطأ: ${e.runtimeType}
// - الرسالة: ${e.toString()}
// - Stack Trace: ${stackTrace.toString()}
// - الوقت: ${DateTime.now()}
// ''';
//         print("خطأ في إعادة تعيين كلمة المرور: $e");
//         print("Stack Trace: $stackTrace");
//       }
//
//       _showError(errorMsg, details: debugDetails);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // Responsive helper methods
//   double _getResponsivePadding(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 600) return 16.0; // Mobile
//     if (screenWidth < 1200) return 32.0; // Tablet
//     return 64.0; // Desktop
//   }
//
//   double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 600) return baseFontSize * 0.9; // Mobile
//     if (screenWidth < 1200) return baseFontSize; // Tablet
//     return baseFontSize * 1.1; // Desktop
//   }
//
//   double _getMaxWidth(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 600) return screenWidth * 0.95; // Mobile
//     if (screenWidth < 1200) return 500; // Tablet
//     return 600; // Desktop
//   }
//
//   Widget _buildPasswordField({
//     required TextEditingController controller,
//     required String label,
//     required bool isVisible,
//     required VoidCallback onVisibilityToggle,
//     required String? Function(String?) validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: !isVisible,
//         style: TextStyle(fontSize: _getResponsiveFontSize(context, 16)),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(
//             color: primaryColor.withOpacity(0.8),
//             fontWeight: FontWeight.w500,
//             fontSize: _getResponsiveFontSize(context, 14),
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [gradientStart, gradientEnd],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.lock, color: Colors.white, size: 20),
//           ),
//           suffixIcon: IconButton(
//             icon: Icon(
//               isVisible ? Icons.visibility : Icons.visibility_off,
//               color: primaryColor,
//             ),
//             onPressed: onVisibilityToggle,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide:
//                 BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: primaryColor, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.red, width: 1),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.red, width: 2),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: _getResponsivePadding(context),
//             vertical: 16,
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }
//
//   Widget _buildAnimatedButton() {
//     return ScaleTransition(
//       scale: _buttonScaleAnimation,
//       child: Container(
//         width: double.infinity,
//         height: 56,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [gradientStart, gradientEnd],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: primaryColor.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: _isLoading ? null : _resetPassword,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           child: _isLoading
//               ? const SizedBox(
//                   height: 24,
//                   width: 24,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//               : Text(
//                   "إعادة تعيين كلمة المرور",
//                   style: TextStyle(
//                     fontSize: _getResponsiveFontSize(context, 18),
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorMessage() {
//     if (_errorMessage == null) return const SizedBox.shrink();
//
//     return ScaleTransition(
//       scale: _errorAnimation,
//       child: Container(
//         margin: const EdgeInsets.only(top: 20),
//         padding: EdgeInsets.all(_getResponsivePadding(context)),
//         decoration: BoxDecoration(
//           color: Colors.red.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.red.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.red.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 _errorMessage!,
//                 style: TextStyle(
//                   color: Colors.red.shade700,
//                   fontSize: _getResponsiveFontSize(context, 14),
//                   fontWeight: FontWeight.w500,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuccessMessage() {
//     if (_successMessage == null) return const SizedBox.shrink();
//
//     return ScaleTransition(
//       scale: _successAnimation,
//       child: Container(
//         margin: const EdgeInsets.only(top: 20),
//         padding: EdgeInsets.all(_getResponsivePadding(context)),
//         decoration: BoxDecoration(
//           color: secondaryColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: secondaryColor.withOpacity(0.3)),
//           boxShadow: [
//             BoxShadow(
//               color: secondaryColor.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.check_circle_outline,
//                     color: secondaryColor, size: 24),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     _successMessage!,
//                     style: TextStyle(
//                       color: secondaryColor.withOpacity(0.9),
//                       fontSize: _getResponsiveFontSize(context, 14),
//                       fontWeight: FontWeight.w500,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_countdown > 0) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: secondaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(secondaryColor),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       "سيتم الانتقال لشاشة تسجيل الدخول خلال $_countdown ثانية",
//                       style: TextStyle(
//                         color: secondaryColor.withOpacity(0.8),
//                         fontSize: _getResponsiveFontSize(context, 12),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: _navigateToLogin,
//                 child: Text(
//                   "الانتقال الآن",
//                   style: TextStyle(
//                     color: secondaryColor,
//                     fontSize: _getResponsiveFontSize(context, 12),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 600;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color(0xFFF8FDFF),
//                 Color(0xFFF0FFFE),
//                 Color(0xFFE8FFFD),
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: Center(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.all(_getResponsivePadding(context)),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         maxWidth: _getMaxWidth(context),
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header with back button
//                             Row(
//                               children: [
//                                 Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: primaryColor.withOpacity(0.1),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: IconButton(
//                                         icon: const Icon(Icons.arrow_back_ios,
//                                             color: primaryColor),
//                                         onPressed: () => Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       LoginPage()),
//                                             ))),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Text(
//                                     "إعادة تعيين كلمة المرور",
//                                     style: TextStyle(
//                                       fontSize:
//                                           _getResponsiveFontSize(context, 24),
//                                       fontWeight: FontWeight.bold,
//                                       color: primaryColor,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: isSmallScreen ? 30 : 40),
//
//                             // Title and description
//                             Container(
//                               padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: primaryColor.withOpacity(0.1),
//                                     blurRadius: 20,
//                                     offset: const Offset(0, 10),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(12),
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             colors: [
//                                               gradientStart,
//                                               gradientEnd
//                                             ],
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: const Icon(
//                                           Icons.security,
//                                           color: Colors.white,
//                                           size: 24,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       Expanded(
//                                         child: Text(
//                                           "أدخل كلمة المرور الجديدة",
//                                           style: TextStyle(
//                                             fontSize: _getResponsiveFontSize(
//                                                 context, 20),
//                                             fontWeight: FontWeight.bold,
//                                             color: primaryColor,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Text(
//                                     "يرجى إدخال كلمة مرور قوية تحتوي على 6 أحرف على الأقل وتختلف عن كلمة المرور الحالية",
//                                     style: TextStyle(
//                                       fontSize:
//                                           _getResponsiveFontSize(context, 14),
//                                       color: Colors.grey.shade600,
//                                       height: 1.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: isSmallScreen ? 24 : 32),
//
//                             // Email field (if not passed via constructor)
//                             if (widget.email == null) ...[
//                               _buildTextField(
//                                 controller: _emailController,
//                                 label: "البريد الإلكتروني",
//                                 icon: Icons.email,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return "الرجاء إدخال البريد الإلكتروني";
//                                   }
//                                   if (!RegExp(
//                                           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                                       .hasMatch(value)) {
//                                     return "الرجاء إدخال بريد إلكتروني صالح";
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//
//                             // Password fields
//                             _buildPasswordField(
//                               controller: _newPasswordController,
//                               label: "كلمة المرور الجديدة",
//                               isVisible: _isNewPasswordVisible,
//                               onVisibilityToggle: () {
//                                 setState(() {
//                                   _isNewPasswordVisible =
//                                       !_isNewPasswordVisible;
//                                 });
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "الرجاء إدخال كلمة المرور الجديدة";
//                                 }
//                                 if (value.length < 6) {
//                                   return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//
//                             _buildPasswordField(
//                               controller: _confirmPasswordController,
//                               label: "تأكيد كلمة المرور الجديدة",
//                               isVisible: _isConfirmPasswordVisible,
//                               onVisibilityToggle: () {
//                                 setState(() {
//                                   _isConfirmPasswordVisible =
//                                       !_isConfirmPasswordVisible;
//                                 });
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return "الرجاء تأكيد كلمة المرور الجديدة";
//                                 }
//                                 if (value != _newPasswordController.text) {
//                                   return "كلمتا المرور غير متطابقتين";
//                                 }
//                                 return null;
//                               },
//                             ),
//                             SizedBox(height: isSmallScreen ? 24 : 32),
//
//                             // Reset button
//                             _buildAnimatedButton(),
//
//                             // Error and success messages
//                             _buildErrorMessage(),
//                             _buildSuccessMessage(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // New helper for general text fields (for email if needed)
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         style: TextStyle(fontSize: _getResponsiveFontSize(context, 16)),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(
//             color: primaryColor.withOpacity(0.8),
//             fontWeight: FontWeight.w500,
//             fontSize: _getResponsiveFontSize(context, 14),
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [gradientStart, gradientEnd],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: Colors.white, size: 20),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide:
//                 BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: primaryColor, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.red, width: 1),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: const BorderSide(color: Colors.red, width: 2),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: _getResponsivePadding(context),
//             vertical: 16,
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/otp_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email; // البريد الإلكتروني الممرر كمعامل (اختياري)

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _userEmail; // البريد الإلكتروني المستخلص من Supabase أو المُمرر

  // متحكمات الحركة
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // متغيرات العد التنازلي للانتقال
  int _countdown = 0;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeEmail();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // بدء الحركات
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _initializeEmail() async {
    // محاولة الحصول على البريد الإلكتروني من عدة مصادر
    String? email;

    // 1. البريد الإلكتروني الممرر كمعامل
    if (widget.email != null && widget.email!.isNotEmpty) {
      email = widget.email;
      print('📧 تم الحصول على البريد الإلكتروني من المعامل: $email');
    }
    // 2. البريد الإلكتروني من المستخدم الحالي في Supabase
    else {
      try {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null && currentUser.email != null) {
          email = currentUser.email;
          print('📧 تم الحصول على البريد الإلكتروني من Supabase.auth.currentUser: $email');
        } else {
          print('⚠️ لا يوجد مستخدم حالي في Supabase.auth.currentUser');
        }
      } catch (e) {
        print('❌ خطأ في الحصول على البريد الإلكتروني من Supabase: $e');
      }
    }

    setState(() {
      _userEmail = email;
      if (email != null) {
        _emailController.text = email;
      }
    });

    print('📧 البريد الإلكتروني النهائي المستخدم: $_userEmail');
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
    HapticFeedback.lightImpact();
  }

  void _showSuccess(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // التحقق من الاتصال بالإنترنت
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        _showError("لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.");
        return;
      }

      final newPassword = _newPasswordController.text.trim();

      // الحصول على البريد الإلكتروني من عدة مصادر
      String? userEmail = _userEmail ?? _emailController.text.trim();

      // إذا لم يتم العثور على البريد الإلكتروني، محاولة الحصول عليه من Supabase مرة أخرى
      if (userEmail == null || userEmail.isEmpty) {
        try {
          final currentUser = Supabase.instance.client.auth.currentUser;
          if (currentUser != null && currentUser.email != null) {
            userEmail = currentUser.email;
            print('📧 تم الحصول على البريد الإلكتروني من Supabase في وقت التنفيذ: $userEmail');
          }
        } catch (e) {
          print('❌ خطأ في الحصول على البريد الإلكتروني من Supabase: $e');
        }
      }

      if (userEmail == null || userEmail.isEmpty) {
        _showError("لا يمكن تحديد البريد الإلكتروني. يرجى إدخال البريد الإلكتروني يدوياً.");
        return;
      }

      print('🔄 محاولة إعادة تعيين كلمة المرور للبريد الإلكتروني: $userEmail');

      // استدعاء دالة إعادة تعيين كلمة المرور مع تمرير البريد الإلكتروني
      final result = await OTPService.resetPassword(userEmail, newPassword);

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'تم تغيير كلمة المرور بنجاح!');

        // بدء العد التنازلي للانتقال
        _startCountdownAndNavigate();
      } else {
        // معالجة أنواع مختلفة من الأخطاء
        String errorMessage = result['error'] ?? 'فشل في تغيير كلمة المرور';

        if (errorMessage.contains('same as current')) {
          errorMessage = 'كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور الحالية';
        } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
          errorMessage = 'خطأ في الاتصال بالشبكة. يرجى المحاولة مرة أخرى';
        } else if (errorMessage.contains('invalid') || errorMessage.contains('not found')) {
          errorMessage = 'البريد الإلكتروني غير صحيح أو غير موجود';
        }

        _showError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('💥 خطأ في إعادة تعيين كلمة المرور: $e');
      print('📍 Stack trace: $stackTrace');

      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      }

      _showError(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCountdownAndNavigate() {
    setState(() {
      _showCountdown = true;
      _countdown = 5;
    });

    // العد التنازلي
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    }).then((_) {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
    }
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize * 0.9;
    } else if (screenWidth > 600) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  double _getResponsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return basePadding * 0.8;
    } else if (screenWidth > 600) {
      return basePadding * 1.2;
    }
    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final primaryColor = const Color(0xFF4CB8C4);
    final secondaryColor = const Color(0xFF3CD3AD);
    final screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(_getResponsivePadding(context, 24.0)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenSize.height * 0.05),

                      // Header Section
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(_getResponsivePadding(context, 32.0)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.lock_reset,
                                  size: _getResponsiveFontSize(context, 48),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'إعادة تعيين كلمة المرور',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 24),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أدخل كلمة المرور الجديدة الخاصة بك',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 14),
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: _getResponsivePadding(context, 32.0)),

                      // Email Display (if available)
                      if (_userEmail != null && _userEmail!.isNotEmpty) ...[
                        AnimationLimiter(
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 375),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                Container(
                                  padding: EdgeInsets.all(_getResponsivePadding(context, 16.0)),
                                  decoration: BoxDecoration(
                                    color: secondaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: secondaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        color: secondaryColor,
                                        size: _getResponsiveFontSize(context, 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'البريد الإلكتروني',
                                              style: TextStyle(
                                                fontSize: _getResponsiveFontSize(context, 12),
                                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              _userEmail!,
                                              style: TextStyle(
                                                fontSize: _getResponsiveFontSize(context, 14),
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: _getResponsivePadding(context, 24.0)),
                      ],

                      // Email Input (if email not available)
                      if (_userEmail == null || _userEmail!.isEmpty) ...[
                        AnimationLimiter(
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 375),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'البريد الإلكتروني',
                                    hintText: 'أدخل بريدك الإلكتروني',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال البريد الإلكتروني';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: _getResponsivePadding(context, 24.0)),
                      ],

                      // Password Fields
                      AnimationLimiter(
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(child: widget),
                            ),
                            children: [
                              // New Password Field
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: !_isNewPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور الجديدة',
                                  hintText: 'أدخل كلمة المرور الجديدة',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNewPasswordVisible = !_isNewPasswordVisible;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور الجديدة';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: _getResponsivePadding(context, 20.0)),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  hintText: 'أعد إدخال كلمة المرور الجديدة',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء تأكيد كلمة المرور';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'كلمتا المرور غير متطابقتين';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: _getResponsivePadding(context, 32.0)),

                      // Error Message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: EdgeInsets.all(_getResponsivePadding(context, 16.0)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: _getResponsiveFontSize(context, 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _getResponsivePadding(context, 16.0)),
                      ],

                      // Success Message
                      if (_successMessage != null) ...[
                        Container(
                          padding: EdgeInsets.all(_getResponsivePadding(context, 16.0)),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: _getResponsiveFontSize(context, 14),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _getResponsivePadding(context, 16.0)),
                      ],

                      // Reset Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'إعادة تعيين كلمة المرور',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Countdown and Navigation
                      if (_countdown > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "سيتم الانتقال لشاشة تسجيل الدخول خلال $_countdown ثانية",
                                style: TextStyle(
                                  color: secondaryColor.withOpacity(0.8),
                                  fontSize: _getResponsiveFontSize(context, 12),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            "الانتقال الآن",
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: _getResponsiveFontSize(context, 12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: _getResponsivePadding(context, 24.0)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

