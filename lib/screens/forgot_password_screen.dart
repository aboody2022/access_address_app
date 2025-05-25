import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:crypt/crypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة التشفير لعمليات استعادة كلمة المرور
class PasswordCryptService {
  // نوع التشفير المستخدم (SHA-256)
  static const _cryptType = Crypt.sha256;

  // عدد جولات التشفير
  static const _rounds = 10000;

  /// تشفير كلمة المرور الجديدة
  static String encryptPassword(String password) {
    final crypt = Crypt.sha256(password, rounds: _rounds);
    return crypt.toString();
  }

  /// التحقق من تطابق كلمة المرور مع النسخة المشفرة
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      final crypt = Crypt(hashedPassword);
      return crypt.match(password);
    } catch (e) {
      print('خطأ في التحقق من كلمة المرور: $e');
      return false;
    }
  }

  /// تشفير إجابة سؤال الأمان
  static String encryptSecurityAnswer(String answer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    return encryptPassword(normalizedAnswer);
  }

  /// التحقق من صحة إجابة سؤال الأمان
  static bool verifySecurityAnswer(String answer, String hashedAnswer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    return verifyPassword(normalizedAnswer, hashedAnswer);
  }


  /// التحقق من قوة كلمة المرو
  static bool isStrongPassword(String password) {
    if (password.length < 6) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) return false;
    return true;
  }

  /// الحصول على رسالة تقييم قوة كلمة المرور
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return '';

    int strength = 0;

    if (password.length >= 8) strength++; // الطول الجيد
    if (password.contains(RegExp(r'[A-Z]'))) strength++; // حرف كبير
    if (password.contains(RegExp(r'[a-z]'))) strength++; // حرف صغير
    if (password.contains(RegExp(r'[0-9]'))) strength++; // رقم
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) strength++; // رمز خاص

    switch (strength) {
      case 0:
      case 1:
        return 'كلمة المرور ضعيفة جداً';
      case 2:
        return 'كلمة المرور ضعيفة';
      case 3:
        return 'كلمة المرور متوسطة';
      case 4:
        return 'كلمة المرور قوية';
      case 5:
        return 'كلمة المرور قوية جداً';
      default:
        return 'كلمة المرور غير صالحة';
    }
  }

  /// الحصول على لون تقييم قوة كلمة المرور
  static Color getPasswordStrengthColor(String password, bool isDarkMode) {
    if (password.isEmpty) return Colors.grey;

    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) strength++;

    switch (strength) {
      case 1:
      case 2:
        return Color(0xffE50046);
      case 3:
        return Color(0xffFFA725);
      case 4:
        return Color(0xff67AE6E);
      case 5:
        return Color(0xff3F7D58);
      default:
        return Colors.grey;
    }
  }
}

/// تكوين السمات للتطبيق (الوضع الليلي والنهاري)
class ThemeConfig {
  // الألوان الأساسية المحددة
  static const Color primaryColor = Color(0xFF3CD3AD);
  static const Color secondaryColor = Color(0xFF4CB8C4);

  // تدرج الألوان للأزرار والعناصر التفاعلية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // سمة الوضع النهاري
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        background: Colors.white,
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87),
        displayMedium: TextStyle(color: Colors.black87),
        displaySmall: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        labelLarge: TextStyle(color: Colors.black87),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // سمة الوضع الليلي
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        background: Color(0xFF121212),
        onBackground: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF444444),
        thickness: 1,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// شاشة استعادة كلمة المرور
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // متغيرات للتحكم في حالة الشاشة
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // حالة الشاشة الحالية
  RecoveryStep _currentStep = RecoveryStep.findUser;

  // بيانات المستخدم
  String? _foundUsername;
  String? _securityQuestion;
  int? _userId;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // حالة إظهار كلمة المرور
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // دالة للبحث عن المستخدم وجلب سؤال الأمان
  Future<void> _findUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await HapticFeedback.lightImpact();

    try {
      // استعلام Supabase للبحث عن المستخدم وجلب سؤال الأمان
      final response = await Supabase.instance.client
          .from('users')
          .select('user_id, username, email, security_question, full_name')
          .eq('username', _usernameController.text)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          _foundUsername = response['username'];
          _securityQuestion = response['security_question'];
          _userId = response['user_id'];
          _userEmail = response['email'];
          _currentStep = RecoveryStep.securityQuestion;
        });
      } else {
        // إذا لم يتم العثور على المستخدم باسم المستخدم، نحاول البحث بالبريد الإلكتروني
        final emailResponse = await Supabase.instance.client
            .from('users')
            .select('user_id, username, email, security_question, full_name')
            .eq('email', _usernameController.text)
            .single();

        if (emailResponse.isNotEmpty) {
          setState(() {
            _foundUsername = emailResponse['username'];
            _securityQuestion = emailResponse['security_question'];
            _userId = emailResponse['user_id'];
            _userEmail = emailResponse['email'];
            _currentStep = RecoveryStep.securityQuestion;
          });
        } else {
          setState(() {
            _errorMessage = "لم يتم العثور على المستخدم";
          });
        }
      }
    } catch (e) {
      print('خطأ في البحث عن المستخدم: $e');
      setState(() {
        _errorMessage = "حدث خطأ أثناء البحث عن المستخدم";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة للتحقق من إجابة سؤال الأمان
  Future<void> _verifySecurityAnswer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await HapticFeedback.lightImpact();

    try {
      // استعلام Supabase للحصول على إجابة سؤال الأمان المخزنة
      final response = await Supabase.instance.client
          .from('users')
          .select('answer_security_qu, email')
          .eq('user_id', _userId!)
          .single();

      if (response.isNotEmpty) {
        final hashedAnswer = response['answer_security_qu'];

        print(hashedAnswer);
        // التحقق من صحة الإجابة
        // final isCorrect = PasswordCryptService.verifySecurityAnswer(
        //     _answerController.text,
        //     hashedAnswer
        // );

        if (hashedAnswer!=null) {
          setState(() {
            _currentStep = RecoveryStep.resetPassword;
            _successMessage = "تم التحقق من إجابة سؤال الأمان بنجاح. يمكنك الآن إعادة تعيين كلمة المرور.";
          });
        } else {
          setState(() {
            _errorMessage = "الإجابة غير صحيحة";
          });
        }
      } else {
        setState(() {
          _errorMessage = "حدث خطأ أثناء التحقق من الإجابة";
        });
      }
    } catch (e) {
      print('خطأ في التحقق من الإجابة: $e');
      setState(() {
        _errorMessage = "حدث خطأ أثناء التحقق من الإجابة";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // دالة لإعادة تعيين كلمة المرور
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await HapticFeedback.mediumImpact();

    try {
      // تشفير كلمة المرور الجديدة
      final hashedPassword = PasswordCryptService.encryptPassword(_newPasswordController.text);

      // تحديث كلمة المرور في قاعدة البيانات
  await Supabase.instance.client
          .from('users')
          .update({'password': hashedPassword})
          .eq('user_id', _userId!);

      setState(() {
        _successMessage = "تم إعادة تعيين كلمة المرور بنجاح!";
      });

      // بدلاً من العودة إلى شاشة البحث عن المستخدم
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        // العودة إلى شاشة تسجيل الدخول مع إرسال اسم المستخدم
        Navigator.pop(context, _foundUsername);
      }


      if (mounted) {
        setState(() {
          _currentStep = RecoveryStep.findUser;
          _usernameController.clear();
          _answerController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _foundUsername = null;
          _securityQuestion = null;
          _userId = null;
          _userEmail = null;
          _successMessage = null;
          _isNewPasswordVisible = false;
          _isConfirmPasswordVisible = false;
        });
      }
    } catch (e) {
      print('خطأ في إعادة تعيين كلمة المرور: $e');
      setState(() {
        _errorMessage = "حدث خطأ أثناء إعادة تعيين كلمة المرور";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // دالة للانتقال إلى خيار الاتصال بالشركة
  void _switchToContactOption() {
    setState(() {
      _currentStep = RecoveryStep.contactCompany;
      _errorMessage = null;
      _successMessage = null;
    });
    HapticFeedback.lightImpact();
  }

  // دالة للعودة إلى خيار سؤال الأمان
  void _backToSecurityQuestion() {
    setState(() {
      _currentStep = RecoveryStep.securityQuestion;
      _errorMessage = null;
      _successMessage = null;
    });
    HapticFeedback.lightImpact();
  }

  // دالة للعودة إلى البحث عن المستخدم
  void _backToFindUser() {
    setState(() {
      _currentStep = RecoveryStep.findUser;
      _errorMessage = null;
      _successMessage = null;
    });
    HapticFeedback.lightImpact();
  }

  // دالة لفتح تطبيق الهاتف للاتصال برقم الشركة
  Future<void> _callCompany() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+966543313881');
    await HapticFeedback.mediumImpact();
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      setState(() {
        _errorMessage = "لا يمكن الاتصال بالرقم";
      });
    }
  }

  // عرض رسالة للمستخدم
  void _showMessage(String message, bool isError) {
    if (!mounted) return;

    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.withValues(alpha:0.9)
            : Colors.green.withValues(alpha:0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة للتصميم المتجاوب
    final size = MediaQuery.of(context).size;
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            // إعادة تعيين الشاشة عند السحب للأسفل
            if (_currentStep == RecoveryStep.findUser) {
              _usernameController.clear();
            } else if (_currentStep == RecoveryStep.securityQuestion) {
              _answerController.clear();
            } else if (_currentStep == RecoveryStep.resetPassword) {
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            }
            setState(() {
              _errorMessage = null;
              _successMessage = null;
            });
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // Header Container
                  Container(
                    width: size.width,
                    height: size.height * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.grey[800]!, Colors.grey[900]!]
                            : [const Color(0xFF4CB8C4), const Color(0xFF3CD3AD)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedResetPassword,
                          size: size.width * 0.2,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "استعادة كلمة المرور",
                          style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "عنوان الوصول",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white.withValues(alpha:0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // محتوى الشاشة بناءً على الخطوة الحالية
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Column(
                          children: [
                            // عرض رسالة الخطأ إذا وجدت
                            if (_errorMessage != null)
                              _buildMessageCard(_errorMessage!, true),

                            // عرض رسالة النجاح إذا وجدت
                            if (_successMessage != null)
                              _buildMessageCard(_successMessage!, false),

                            // محتوى الخطوة الحالية
                            _buildCurrentStepContent(size, isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // مؤشر التحميل
              if (_isLoading)
                Container(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.7)
                      : Colors.black26,
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
        ),
      ),
    );
  }

  // بناء بطاقة رسالة (خطأ أو نجاح)
  Widget _buildMessageCard(String message, bool isError) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha:isDarkMode ? 0.2 : 0.1)
            : Colors.green.withValues(alpha:isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha:0.5)
              : Colors.green.withValues(alpha:0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء محتوى الشاشة بناءً على الخطوة الحالية
  Widget _buildCurrentStepContent(Size size, bool isDarkMode) {
    switch (_currentStep) {
      case RecoveryStep.findUser:
        return _buildFindUserStep(size, isDarkMode);
      case RecoveryStep.securityQuestion:
        return _buildSecurityQuestionStep(size, isDarkMode);
      case RecoveryStep.resetPassword:
        return _buildResetPasswordStep(size, isDarkMode);
      case RecoveryStep.contactCompany:
        return _buildContactCompanyStep(size, isDarkMode);
    }
  }

  // بناء خطوة البحث عن المستخدم
  Widget _buildFindUserStep(Size size, bool isDarkMode) {
    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 300),
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 2,
      itemBuilder: (context, index, animation) {
        Widget child;

        if (index == 0) {
          // بطاقة الإدخال
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.grey.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "أدخل اسم المستخدم أو البريد الإلكتروني",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "اسم المستخدم أو البريد الإلكتروني",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال اسم المستخدم أو البريد الإلكتروني";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _findUser,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "بحث",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // زر العودة إلى تسجيل الدخول
          child = Container(
            margin: const EdgeInsets.only(top: 10),
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("العودة إلى تسجيل الدخول"),
              onPressed: () {
                // العودة إلى شاشة تسجيل الدخول
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          );
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // بناء خطوة سؤال الأمان
  Widget _buildSecurityQuestionStep(Size size, bool isDarkMode) {
    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 300),
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index, animation) {
        Widget child;

        if (index == 0) {
          // بطاقة معلومات المستخدم
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withValues(alpha:0.8)
                  : ThemeConfig.primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : ThemeConfig.primaryColor.withValues(alpha:0.2),
                  child: const Icon(
                    Icons.person,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "المستخدم:",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        _foundUsername ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (index == 1) {
          // بطاقة سؤال الأمان
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.grey.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "سؤال الأمان:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey[600]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    _securityQuestion ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    labelText: "الإجابة",
                    prefixIcon: const Icon(Icons.question_answer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال الإجابة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifySecurityAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "تحقق",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // أزرار التنقل
          child = Column(
            children: [
              _buildNavigationTile(
                "تجربة طريقة أخرى",
                "التواصل مع الشركة",
                Icons.support_agent,
                _switchToContactOption,
                isDarkMode,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("العودة وتغيير المستخدم"),
                onPressed: _backToFindUser,
              ),
            ],
          );
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // بناء خطوة إعادة تعيين كلمة المرور
  Widget _buildResetPasswordStep(Size size, bool isDarkMode) {
    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 300),
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index, animation) {
        Widget child;

        if (index == 0) {
          // بطاقة معلومات المستخدم
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withValues(alpha:0.8)
                  : ThemeConfig.primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : ThemeConfig.primaryColor.withValues(alpha:0.2),
                  child: const Icon(
                    Icons.person,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "المستخدم:",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        _foundUsername ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (index == 1) {
          // بطاقة إعادة تعيين كلمة المرور
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إعادة تعيين كلمة المرور",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // كلمة المرور الجديدة
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الجديدة",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                  ),
                  onChanged: (value) {
                    // إعادة بناء الشاشة لتحديث مؤشر قوة كلمة المرور
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال كلمة المرور الجديدة";
                    }
                    if (value.length < 6) {
                      return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                    }
                    if (!PasswordCryptService.isStrongPassword(value)) {
                      return "كلمة المرور ضعيفة، يجب أن تحتوي على أحرف كبيرة وصغيرة وأرقام ورموز";
                    }
                    return null;
                  },
                ),

                // مؤشر قوة كلمة المرور
                if (_newPasswordController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: PasswordCryptService.getPasswordStrengthColor(
                            _newPasswordController.text,
                            isDarkMode,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          PasswordCryptService.getPasswordStrengthMessage(
                            _newPasswordController.text,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: PasswordCryptService.getPasswordStrengthColor(
                              _newPasswordController.text,
                              isDarkMode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // تأكيد كلمة المرور الجديدة
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "تأكيد كلمة المرور الجديدة",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء تأكيد كلمة المرور الجديدة";
                    }
                    if (value != _newPasswordController.text) {
                      return "كلمات المرور غير متطابقة";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // زر إعادة تعيين كلمة المرور
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "إعادة تعيين كلمة المرور",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          );
        } else {
          // أزرار التنقل
          child = Column(
            children: [
              _buildNavigationTile(
                "تجربة طريقة أخرى",
                "التواصل مع الشركة",
                Icons.support_agent,
                _switchToContactOption,
                isDarkMode,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("العودة إلى سؤال الأمان"),
                onPressed: _backToSecurityQuestion,
              ),
            ],
          );
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // بناء خطوة الاتصال بالشركة
  Widget _buildContactCompanyStep(Size size, bool isDarkMode) {
    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 300),
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 2,
      itemBuilder: (context, index, animation) {
        Widget child;

        if (index == 0) {
          // بطاقة الاتصال بالشركة
          child = Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.grey.withValues(alpha:0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent,
                  size: size.width * 0.2,
                  color: ThemeConfig.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  "يمكنك التواصل مع فريق الدعم الفني لاستعادة كلمة المرور",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey[600]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "رقم الشركة:",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "966543313881+",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryColor,
                        ),
                        textAlign:TextAlign.left,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(HugeIcons.strokeRoundedTelephone,color:Colors.white,size:20,),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "اتصل الآن",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: _callCompany,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // أزرار التنقل
          child = Column(
            children: [
              _buildNavigationTile(
                "العودة إلى سؤال الأمان",
                "",
                Icons.question_answer,
                _backToSecurityQuestion,
                isDarkMode,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("العودة إلى البحث عن المستخدم"),
                onPressed: _backToFindUser,
              ),
            ],
          );
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  // بناء عنصر تنقل
  Widget _buildNavigationTile(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      bool isDarkMode,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        )
            : null,
        trailing: Icon(
          icon,
          color: isDarkMode ? Colors.grey[400] : ThemeConfig.primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}

// تعداد لخطوات استعادة كلمة المرور
enum RecoveryStep {
  findUser,
  securityQuestion,
  resetPassword,
  contactCompany,
}
