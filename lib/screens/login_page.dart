import 'dart:ui';
import 'package:access_address_app/screens/register_screen.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart'; // إضافة مكتبة AdaptiveTheme
import '../core/services/biometric_service.dart';
import '../widgets/check_internet_status.dart';
import 'baes_screen.dart';
import '../injection.dart';
import 'forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // المتغيرات الأساسية
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _canUseBiometrics = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  late BiometricService _biometricService = getIt<BiometricService>();

  // متغيرات الوضع الليلي
  bool get isDarkMode => AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

  // الألوان الأساسية
  Color get primaryColor => isDarkMode ? Colors.tealAccent : const Color(0xFF4CB8C4);
  Color get secondaryColor => isDarkMode ? Colors.tealAccent.shade700 : const Color(0xFF3CD3AD);
  Color get textColor => isDarkMode ? Colors.white : Colors.black;
  Color get inputFillColor => isDarkMode ? Colors.grey[800]! : Colors.white;

  @override
  void initState() {
    super.initState();
    checkInternetConnection(context);
    // _checkInternetConnection();
    _checkBiometrics();

    _initializeBiometrics();

    // تهيئة المتحكم في الحركة
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // إنشاء الحركة
    _animation = Tween<double>(begin: 0, end: 2).animate(_animationController);
  }

  // التحقق من توفر المصادقة البيومترية
  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _biometricService.canCheckBiometrics();
      final hasStoredCredentials = await _biometricService.getStoredCredentials() != null;

      if (mounted) {
        setState(() {
          _canUseBiometrics = isAvailable && hasStoredCredentials;
        });
      }
    } catch (e) {
      print('Error checking biometrics: $e');
      if (mounted) {
        setState(() {
          _canUseBiometrics = false;
        });
      }
    }
  }

  void _showSnackbar(String title, String message, SnackBarType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      IconSnackBar.show(
        context,
        snackBarType: type,
        label: message,
        backgroundColor: type == SnackBarType.fail
            ? (isDarkMode ? Colors.red[700] : Colors.red)
            : type == SnackBarType.success
            ? (isDarkMode ? Colors.green[700] : Colors.green)
            : (isDarkMode ? Color(0xff8b5c1c) : Color(0xffec942c)),
      );
    });
  }

  void _navigateToRegister() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RegisterScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // الخلفية المتحركة
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [
                        Color.lerp(Colors.grey[900]!, Colors.grey[800]!, _animation.value)!,
                        Color.lerp(Colors.grey[800]!, Colors.grey[900]!, _animation.value)!,
                      ]
                          : [
                        Color.lerp(Color(0xFF4CB8C4), Color(0xFF3CD3AD), _animation.value)!,
                        Color.lerp(Color(0xFF3CD3AD), Color(0xFF4CB8C4), _animation.value)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // طبقة الضبابية
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: (isDarkMode ? Colors.black : Colors.white).withValues(alpha:0.1),
                  ),
                ),
                // المحتوى الرئيسي
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          // الشعار
                          Image.asset(
                            'assets/images/logo.png',
                            height: 150,
                            color: isDarkMode ? Colors.white : null,
                          ),
                          const SizedBox(height: 20),
                          // عنوان التطبيق
                          Text(
                            'عنوان الوصول',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // حقل اسم المستخدم
                          _buildTextField(
                            controller: _usernameController,
                            hintText: 'ادخل اسم المستخدم أو رقم هاتفك',
                            icon: HugeIcons.strokeRoundedUser,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم المستخدم';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // حقل كلمة المرور
                          _buildPasswordField(),
                          const SizedBox(height: 10),
                          // زر نسيت كلمة المرور
                          _buildForgotPasswordButton(),
                          const SizedBox(height: 20),
                          // أزرار تسجيل الدخول
                          _buildLoginButtons(),
                          const SizedBox(height: 20),
                          // صف التسجيل
                          _buildRegisterRow(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // بناء حقل النص
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      obscureText: isPassword && _isPasswordHidden,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800]!.withValues(alpha:0.8) : Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(
          color: (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withValues(alpha:0.8),
        ),
        prefixIcon: HugeIcon(
          icon: icon,
          color: (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withValues(alpha:0.8) ?? Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),
    );  }

  // بناء حقل كلمة المرور
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      textDirection: TextDirection.rtl,
      obscureText: _isPasswordHidden,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800]!.withValues(alpha:0.8) : Colors.white,
        hintText: 'أدخل كلمة المرور الخاصة بك',
        hintStyle: TextStyle(
          color: (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withValues(alpha:0.8),
        ),
        prefixIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedLockPassword,
          color: (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withValues(alpha:0.8) ?? Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff,
            color: (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withValues(alpha:0.8) ?? Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }
  // بناء زر نسيت كلمة المرور
  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () async {
          // استدعاء شاشة استعادة كلمة المرور وانتظار النتيجة
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
          );

          // التحقق من وجود اسم مستخدم مرجع
          if (result != null && mounted) {
            setState(() {
              // استخدام اسم المستخدم المرجع في حقل اسم المستخدم
              _usernameController.text = result;
            });
          }
        },
        child: Text(
          'هل نسيت كلمة المرور؟',
          style: TextStyle(
            color: Colors.teal,
          ),
        ),
      ),
    );
  }


  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            'سجل الآن',
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // التحقق من اتصال الإنترنت
  // Future<bool> _checkInternetConnection() async {
  //   try {
  //     // التحقق من الاتصال
  //     var connectivityResult = await Connectivity().checkConnectivity();
  //     print('حالة الاتصال: $connectivityResult');
  //
  //     if (connectivityResult == ConnectivityResult.none) {
  //       // عرض رسالة عدم وجود اتصال
  //       _showSnackbar(
  //         'تنبيه',
  //         'لا يوجد اتصال بالإنترنت. الرجاء التحقق من الشبكة.',
  //         SnackBarType.alert,
  //       );
  //       return false;
  //     }
  //
  //     return true;
  //   } catch (e) {
  //     print('خطأ في التحقق من الاتصال: $e');
  //     _showSnackbar(
  //       'خطأ',
  //       'حدث خطأ أثناء التحقق من الاتصال.',
  //       SnackBarType.fail,
  //     );
  //     return false;
  //   }
  // }



  //--------------------
  Future<void> _initializeBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricService = BiometricService(prefs);

    final isAvailable = await _biometricService.canCheckBiometrics();
    final hasStoredCredentials = await _biometricService.getStoredCredentials() != null;

    if (mounted) {
      setState(() {
        _canUseBiometrics = isAvailable && hasStoredCredentials;
      });
    }
  }

  // تعديل handleLogin لدعم حفظ البيانات للمصادقة البيومترية
  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', _usernameController.text)
          .single();

      if (response.isEmpty) {
        _showSnackbar('خطأ', 'اسم المستخدم غير موجود.', SnackBarType.fail);
        return;
      }

      final storedHashedPassword = response['password'];
      if (Crypt(storedHashedPassword).match(_passwordController.text)) {
        // حفظ البيانات للمصادقة البيومترية
        await _biometricService.saveCredentials(
          _usernameController.text,
          _passwordController.text,
        );

        final userData = {
          'user_id': response['user_id'],
          'username': response['username'],
          'email': response['email'],
          'full_name': response['full_name'],
          'phone_number': response['phone_number'],
          'password': response['password'],
          'profileImagePath': response['profile_picture'],
        };

        // الانتقال إلى الشاشة الرئيسية
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            maintainState: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainScreen(userData: userData),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 5.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      } else {
        _showSnackbar('خطأ', 'كلمة المرور غير صحيحة.', SnackBarType.fail);
      }
    } catch (e) {
      print('Login error: $e');
      _showSnackbar('خطأ', 'حدث خطأ غير متوقع.', SnackBarType.fail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // إضافة دالة المصادقة البيومترية
  Future<void> _handleBiometricLogin() async {
    try {
      // التحقق من توفر المصادقة البيومترية
      final canUseBiometrics = await _biometricService.canCheckBiometrics();
      if (!canUseBiometrics) {
        _showSnackbar(
          'تنبيه',
          'المصادقة البيومترية غير متوفرة على هذا الجهاز',
          SnackBarType.alert,
        );
        return;
      }

      // محاولة المصادقة
      final isAuthenticated = await _biometricService.authenticate();
      if (!isAuthenticated) {
        _showSnackbar(
          'تنبيه',
          'فشلت المصادقة البيومترية',
          SnackBarType.alert,
        );
        return;
      }

      // استرجاع البيانات المحفوظة
      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null) {
        _showSnackbar(
          'تنبيه',
          'لم يتم العثور على بيانات محفوظة',
          SnackBarType.alert,
        );
        return;
      }

      // تعبئة البيانات وتسجيل الدخول
      _usernameController.text = credentials['username']!;
      _passwordController.text = credentials['password']!;
      await handleLogin();
    } catch (e) {
      print('Biometric authentication error: $e');
      _showSnackbar(
        'خطأ',
        'حدث خطأ أثناء المصادقة البيومترية',
        SnackBarType.fail,
      );
    }
  }
  // تعديل _buildLoginButtons لإضافة زر البصمة
  Widget _buildLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.tealAccent, Colors.tealAccent.shade700]
                    : [Color(0xFF4CB8C4), Color(0xFF3CD3AD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _isLoading ? null : handleLogin,
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              )
                  : Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (_canUseBiometrics) ...[
          const SizedBox(width: 10),
          IconButton(
            onPressed: _handleBiometricLogin,
            icon: Icon(
              Icons.fingerprint,
              color: isDarkMode ? Colors.white : Colors.white,
              size: 50,
            ),
          ),
        ],
      ],
    );
  }





  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}