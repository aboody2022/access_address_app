import 'package:access_address_app/screens/login_page.dart';
import 'package:access_address_app/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/otp_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// تعريف خطوات الاستعادة
enum RecoveryStep {
  findUser,
  chooseMethod,
  securityQuestion,
  contactCompany,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _answerController = TextEditingController();
  final _emailController = TextEditingController();

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

  // متغيرات طريقة الاستعادة
  String _recoveryMethod = 'security'; // 'security' أو 'email'

  @override
  void dispose() {
    _usernameController.dispose();
    _answerController.dispose();
    _emailController.dispose();
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
      // استعلام Supabase للبحث عن المستخدم باسم المستخدم أو البريد الإلكتروني
      final response = await Supabase.instance.client
          .from('users')
          .select('user_id, username, email, security_question, full_name')
          .or('username.eq.${_usernameController.text},email.eq.${_usernameController.text.toLowerCase()}')
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        setState(() {
          _foundUsername = response['username'];
          _securityQuestion = response['security_question'];
          _userId = response['user_id'];
          _userEmail = response['email'];
          _emailController.text = response['email'] ?? '';
          _currentStep = RecoveryStep.chooseMethod;
        });
      } else {
        setState(() {
          _errorMessage = "لم يتم العثور على المستخدم";
        });
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

  // دالة لإرسال رابط إعادة تعيين كلمة المرور عبر البريد الإلكتروني
  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await HapticFeedback.lightImpact();

    try {
      // استخدام OTPService لإرسال رابط إعادة تعيين كلمة المرور
      final result = await OTPService.sendPasswordResetEmail(_userEmail!);
      if (result["success"] == true) {
        setState(() {
          _successMessage = result["message"] ??
              "تم إرسال رابط إعادة تعيين كلمة المرور بنجاح إلى بريدك الإلكتروني.";
        });

        // عرض شاشة منبثقة بدلاً من الانتقال التلقائي
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // يمنع إغلاق الشاشة بالنقر خارجها
            builder: (BuildContext dialogContext) {
              final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
              return AlertDialog(
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                title: Text(
                  "تحقق من بريدك الإلكتروني",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى \n${_userEmail!}.\n\nيرجى النقر على الرابط في البريد الإلكتروني لإكمال عملية إعادة تعيين كلمة المرور.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "حسناً",
                      style: TextStyle(color: isDarkMode ? Color(0xff2AB0BF) : Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // إغلاق الشاشة المنبثقة
                      Navigator.of(context).pop(); // العودة إلى الشاشة السابقة (عادةً شاشة تسجيل الدخول)
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = result["error"] ?? "فشل في إرسال رابط إعادة تعيين كلمة المرور";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ غير متوقع: ${e.toString()}";
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
      // استخدام OTPService للتحقق من إجابة سؤال الأمان
      final result = await OTPService.verifySecurityAnswer(
        _userEmail!,
        _answerController.text.trim(),
      );

      if (result["success"] == true) {
        setState(() {
          _successMessage = "تم التحقق من إجابة سؤال الأمان بنجاح. يرجى الآن إعادة تعيين كلمة المرور في الشاشة التالية.";
        });
        // بعد التحقق من سؤال الأمان، يجب توجيه المستخدم إلى شاشة إدخال كلمة المرور الجديدة
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: _userEmail), // تمرير البريد الإلكتروني
            ),
          ); // التوجيه إلى شاشة إعادة تعيين كلمة المرور
        }
      } else {
        setState(() {
          _errorMessage = result["error"] ?? "إجابة سؤال الأمان غير صحيحة";
        });
      }
    } catch (e) {
      print("خطأ في التحقق من الإجابة: $e");
      setState(() {
        _errorMessage = "حدث خطأ أثناء التحقق من الإجابة";
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

  // دالة للعودة إلى اختيار الطريقة
  void _backToChooseMethod() {
    setState(() {
      _currentStep = RecoveryStep.chooseMethod;
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
      _usernameController.clear();
      _answerController.clear();
      _emailController.clear();
      _foundUsername = null;
      _securityQuestion = null;
      _userId = null;
      _userEmail = null;
    });
    HapticFeedback.lightImpact();
  }

  // دالة لفتح تطبيق الهاتف للاتصال برقم الشركة
  Future<void> _callCompany() async {
    final Uri phoneUri = Uri(scheme: "tel", path: "+966543313881");
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
                            : [
                          const Color(0xFF4CB8C4),
                          const Color(0xFF3CD3AD)
                        ],
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
                          Icons.lock_reset,
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
                            SizedBox(height:25),
                            _buildBackToLoginButton(size,isDarkMode)

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
                color: isError ? Colors.red : Colors.green,
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
      case RecoveryStep.chooseMethod:
        return _buildChooseMethodStep(size, isDarkMode);
      case RecoveryStep.securityQuestion:
        return _buildSecurityQuestionStep(size, isDarkMode);
      case RecoveryStep.contactCompany:
        return _buildContactCompanyStep(size, isDarkMode);
    }
  }

  // بناء خطوة البحث عن المستخدم
  Widget _buildFindUserStep(Size size, bool isDarkMode) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "اسم المستخدم أو البريد الإلكتروني",
                hintText: "أدخل اسم المستخدم أو البريد الإلكتروني الخاص بك",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال اسم المستخدم أو البريد الإلكتروني";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _findUser,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isDarkMode ? Colors.blueGrey[700] : const Color(0xFF4CB8C4),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("بحث عن المستخدم"),
            ),
          ],
        ),
      ),
    );
  }

  // بناء خطوة اختيار طريقة الاستعادة
  Widget _buildChooseMethodStep(Size size, bool isDarkMode) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            Text(
              "مرحباً بك، $_foundUsername! كيف تود استعادة كلمة المرور؟",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            _buildRecoveryMethodCard(
              icon: Icons.email_outlined,
              title: "عبر البريد الإلكتروني",
              description: "سنرسل رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني المسجل.",
              method: 'email',
              currentMethod: _recoveryMethod,
              onTap: () {
                setState(() {
                  _recoveryMethod = 'email';
                });
                _sendPasswordResetEmail();
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 20),
            _buildRecoveryMethodCard(
              icon: Icons.security_outlined,
              title: "عبر سؤال الأمان",
              description: "أجب عن سؤال الأمان الذي قمت بتعيينه مسبقاً.",
              method: 'security',
              currentMethod: _recoveryMethod,
              onTap: () {
                setState(() {
                  _recoveryMethod = 'security';
                  _currentStep = RecoveryStep.securityQuestion;
                });
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: _backToFindUser,
              child: Text(
                "ليس أنا؟ ابحث عن مستخدم آخر",
                style: TextStyle(
                  color: isDarkMode ? Colors.blueAccent[200] : Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: _switchToContactOption,
              child: Text(
                "لا يمكنني استخدام أي من هذه الخيارات",
                style: TextStyle(
                  color: isDarkMode ? Colors.blueAccent[200] : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء بطاقة طريقة الاستعادة
  Widget _buildRecoveryMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required String method,
    required String currentMethod,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final bool isSelected = method == currentMethod;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blueGrey[800] : Colors.blue[50])
              : (isDarkMode ? Colors.grey[850] : Colors.white),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? Colors.blueAccent : Colors.blue)
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? (isDarkMode ? Colors.blueAccent : Colors.blue)
                  : (isDarkMode ? Colors.white70 : Colors.grey[600]),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء خطوة سؤال الأمان
  Widget _buildSecurityQuestionStep(Size size, bool isDarkMode) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            Text(
              "سؤال الأمان الخاص بك:",
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _securityQuestion ?? "لا يوجد سؤال أمان محدد.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: "إجابتك",
                hintText: "أدخل إجابة سؤال الأمان",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال إجابة سؤال الأمان";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifySecurityAnswer,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isDarkMode ? Colors.blueGrey[700] : const Color(0xFF4CB8C4),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("التحقق من الإجابة"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _backToChooseMethod,
              child: Text(
                "العودة لاختيار طريقة أخرى",
                style: TextStyle(
                  color: isDarkMode ? Colors.blueAccent[200] : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء خطوة الاتصال بالشركة
  Widget _buildContactCompanyStep(Size size, bool isDarkMode) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            Text(
              "تواصل مع الدعم الفني",
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "إذا لم تتمكن من استعادة كلمة المرور بالطرق المتاحة، يمكنك التواصل مع فريق الدعم الفني للحصول على المساعدة.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.phone,
                    size: 50,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "رقم الدعم الفني",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "+966507274427",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.blueAccent : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "ساعات العمل: من الأحد إلى الخميس، 9 صباحاً - 5 مساءً",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _callCompany,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isDarkMode ? Colors.green[700] : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone),
                  const SizedBox(width: 10),
                  Text("اتصل الآن"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _backToChooseMethod,
              child: Text(
                "العودة لاختيار طريقة أخرى",
                style: TextStyle(
                  color: isDarkMode ? Colors.blueAccent[200] : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton(Size size, bool isDarkMode) {
    final baseColor = !isDarkMode ? Color(0xFF3CD3AD) : Colors.teal.shade600;

    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          bool isPressed = false;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
                onTapUp: (_) {
                  setState(() => isPressed = false);
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const beginOffset = Offset(0.0, 1.0);
                      const endOffset = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: beginOffset, end: endOffset).chain(CurveTween(curve: curve));
                      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: FadeTransition(
                          opacity: animation.drive(fadeTween),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ));
                },
              onTapCancel: () => setState(() => isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: size.width * 0.12),
                decoration: BoxDecoration(
                  color: isPressed
                      ? baseColor.withOpacity(0.2)
                      : isHovered
                      ? baseColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: baseColor.withOpacity(0.7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'العودة إلى تسجيل الدخول',
                  style: TextStyle(
                    color: baseColor,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.045,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}





