import 'dart:ui';
import 'package:access_address_app/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:crypt/crypt.dart';
import 'package:hugeicons/hugeicons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 2).animate(_animationController);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _getGradientStartColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF4CB8C4);
  }

  Color _getGradientEndColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFF3CD3AD);
  }

  Future<void> _performRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar('تنبيه', 'كلمات المرور غير متطابقة', SnackBarType.alert);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', _emailController.text.trim())
          .maybeSingle();

      if (existingUser != null) {
        _showSnackbar('تنبيه', 'هذا البريد الإلكتروني مسجل بالفعل.', SnackBarType.alert);
        return;
      }

      final hashedPassword = Crypt.sha256(_passwordController.text).toString();

      final response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'username': _usernameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'full_name': _fullNameController.text.trim(),
        },
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }

      await _supabase.from('users').insert({
        'uid': response.user!.id,
        'full_name': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'password': hashedPassword,
        'email': _emailController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSnackbar('نجاح', 'تم إنشاء الحساب بنجاح!', SnackBarType.success);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } on AuthException catch (e) {
      _showSnackbar('خطأ', 'فشل في إنشاء الحساب: ${e.message}', SnackBarType.fail);
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ: $e', SnackBarType.fail);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                        _getGradientStartColor(isDarkMode),
                        _getGradientEndColor(isDarkMode),
                        _animation.value
                    )!,
                    Color.lerp(
                        _getGradientEndColor(isDarkMode),
                        _getGradientStartColor(isDarkMode),
                        _animation.value
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isDarkMode ? 5.0 : 10.0,
                      sigmaY: isDarkMode ? 5.0 : 10.0,
                    ),
                    child: Container(
                      color: (isDarkMode ? Colors.black : Colors.white)
                          .withValues(alpha:0.1),
                    ),
                  ),
                  SafeArea(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 120,
                                color: isDarkMode ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'عنوان الوصول',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            CustomTextField(
                              controller: _fullNameController,
                              hintText: 'ادخل اسمك الكامل',
                              icon: HugeIcons.strokeRoundedText,
                              isDarkMode: isDarkMode,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'الرجاء إدخال الاسم الكامل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _usernameController,
                              hintText: 'ادخل اسم المستخدم الخاص بك',
                              icon: HugeIcons.strokeRoundedUser,
                              isDarkMode: isDarkMode,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'الرجاء إدخال اسم المستخدم';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: 'ادخل رقم هاتفك',
                              icon: HugeIcons.strokeRoundedSmartPhone01,
                              isDarkMode: isDarkMode,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                                }
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },

                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'ادخل البريد الإلكتروني',
                              icon: HugeIcons.strokeRoundedMail01,
                              isDarkMode: isDarkMode,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                                }
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'ادخل كلمة المرور',
                              icon: HugeIcons.strokeRoundedLockPassword,
                              isDarkMode: isDarkMode,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
                                }
                                return null;
                              },

                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'تأكيد كلمة المرور',
                              icon: HugeIcons.strokeRoundedLockPassword,
                              isDarkMode: isDarkMode,
                              isPassword: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'يرجى تأكيد كلمة المرور';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                              text: _isLoading ? 'جاري التسجيل...' : 'تسجيل',
                              onPressed: _isLoading ? null : _performRegistration,
                              isLoading: _isLoading,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        var slideAnimation = animation.drive(slideTween);

                                        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
                                        var scaleAnimation = animation.drive(scaleTween);

                                        var fadeAnimation = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                                        var fadeTransition = animation.drive(fadeAnimation);

                                        return SlideTransition(
                                          position: slideAnimation,
                                          child: ScaleTransition(
                                            scale: scaleAnimation,
                                            child: FadeTransition(
                                              opacity: fadeTransition,
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'هل لديك حساب؟',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.tealAccent : Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: (isDarkMode ? Colors.black : Colors.white).withValues(alpha:0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnackbar(String title, String message, SnackBarType type) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      IconSnackBar.show(
        context,
        snackBarType: type,
        label: message,
        backgroundColor: type == SnackBarType.fail
            ? (isDarkMode ? Colors.red[900]! : Colors.red)
            : type == SnackBarType.success
            ? (isDarkMode ? Colors.green[900]! : Colors.green)
            : (isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xffec942c)),
      );
    });
  }
}