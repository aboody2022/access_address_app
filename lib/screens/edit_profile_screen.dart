/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String initialName;
  final String initialEmail;
  final String initialPhoneNumber;
  final String initialPassword;
  final bool isDarkMode;

  const EditProfileScreen({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhoneNumber,
    required this.initialPassword,
    required this.isDarkMode,
    this.userData,
  }) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // State Variables
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasChanges = false;
  late int userID;

  // Default Avatar URL
  static const String defaultAvatarUrl =
      'https://ui-avatars.com/api/?name=User&background=random';

  // Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Colors
  Color get primaryColor =>
      widget.isDarkMode ? Colors.tealAccent : const Color(0xFF4CB8C4);
  Color get backgroundColor =>
      widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => widget.isDarkMode ? Colors.white : Colors.black;
  Color get inputFillColor =>
      widget.isDarkMode ? Colors.grey[800]! : Colors.white;

  @override
  void initState() {
    super.initState();
    userID = widget.userData!['user_id'];
    _initializeData();
  }

  void _initializeData() {
    if (!_validateUserData()) return;
    _initializeControllers();
  }

  bool _validateUserData() {
    if (widget.userData == null || widget.userData!['user_id'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorMessage('خطأ: لم يتم العثور على بيانات المستخدم');
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return false;
    }
    return true;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
    _passwordController = TextEditingController(text: widget.initialPassword);

    void updateChanges() {
      if (!mounted) return;
      setState(() => _hasChanges = true);
    }

    _nameController.addListener(updateChanges);
    _emailController.addListener(updateChanges);
    _phoneController.addListener(updateChanges);
    _passwordController.addListener(updateChanges);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final userData = {
        'username': _emailController.text.split('@')[0],
        'password': _passwordController.text,
        'full_name': _nameController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text,
        'profile_picture': defaultAvatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .update(userData)
          .eq('user_id', userID)
          .select();

      if (mounted) {
        _showSuccessMessage('تم تحديث البيانات بنجاح');
        setState(() => _hasChanges = false);

        Navigator.pop(context, {
          ...userData,
          'user_id': userID,
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('حدث خطأ أثناء تحديث البيانات: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        widget.isDarkMode ? Colors.red[300] : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        widget.isDarkMode ? Colors.green[300] : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) {
          Navigator.pop(context);
          return true;
        }

        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor:
            widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'تنبيه',
              style: GoogleFonts.cairo(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              'هناك تغييرات لم يتم حفظها. هل تريد المغادرة؟',
              style: GoogleFonts.cairo(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'البقاء',
                  style: GoogleFonts.cairo(
                    color: widget.isDarkMode
                        ? Colors.white
                        : const Color(0xFF4CB8C4),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'مغادرة',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (result ?? false) {
          if (mounted) {
            Navigator.pop(context);
          }
          return true;
        }
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'تعديل الملف الشخصي',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: widget.isDarkMode
                        ? [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF2C2C2C),
                    ]
                        : [
                      const Color(0xFF4CB8C4),
                      const Color(0xFF3CD3AD),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildProfileImage(),
                        const SizedBox(height: 30),
                        _buildFormFields(),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: defaultAvatarUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 80,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('الاسم الكامل', Icons.person),
          validator: (value) =>
          value?.isEmpty ?? true ? 'يرجى إدخال الاسم الكامل' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('البريد الإلكتروني', Icons.email),
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('رقم الجوال', Icons.phone),
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('كلمة المرور', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: widget.isDarkMode ? Colors.white70 : Colors.white70,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: _validatePassword,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
          backgroundColor: widget.isDarkMode
              ? Colors.tealAccent
              : const Color(0xFF4CB8C4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: widget.isDarkMode ? 2 : 3,
        ),
        child: Text(
          'حفظ التغييرات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري حفظ البيانات...',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(
        color: widget.isDarkMode ? Colors.white70 : Colors.white70,
      ),
      prefixIcon: Icon(
        icon,
        color: widget.isDarkMode ? Colors.white70 : Colors.white70,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.white24 : Colors.white30,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.white : const Color(0xFF3CD3AD),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: widget.isDarkMode
          ? Colors.white.withValues(alpha:0.05)
          : Colors.white.withValues(alpha:0.1),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم جوال صحيح (10 أرقام)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}*/


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypt/crypt.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String initialName;
  final String initialEmail;
  final String initialPhoneNumber;
  final String initialPassword;
  final bool isDarkMode;

  const EditProfileScreen({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhoneNumber,
    required this.initialPassword,
    required this.isDarkMode,
    this.userData,
  }) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _securityQuestionController;
  late final TextEditingController _securityAnswerController;

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // State Variables
  bool _obscurePassword = true;
  bool _obscureSecurityAnswer = true;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _showSecurityFields = false;
  late int userID;

  // Default Avatar URL
  static const String defaultAvatarUrl =
      'https://ui-avatars.com/api/?name=User&background=random';

  // Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Colors
  Color get primaryColor =>
      widget.isDarkMode ? Colors.tealAccent : const Color(0xFF4CB8C4);
  Color get backgroundColor =>
      widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => widget.isDarkMode ? Colors.white : Colors.black;
  Color get inputFillColor =>
      widget.isDarkMode ? Colors.grey[800]! : Colors.white;

  @override
  void initState() {
    super.initState();
    userID = widget.userData!['user_id'];
    _initializeData();
  }

  void _initializeData() {
    if (!_validateUserData()) return;
    _initializeControllers();
    _loadSecurityQuestion();
  }

  bool _validateUserData() {
    if (widget.userData == null || widget.userData!['user_id'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorMessage('خطأ: لم يتم العثور على بيانات المستخدم');
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return false;
    }
    return true;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _securityQuestionController = TextEditingController();
    _securityAnswerController = TextEditingController();

    void updateChanges() {
      if (!mounted) return;
      setState(() => _hasChanges = true);
    }

    _nameController.addListener(updateChanges);
    _emailController.addListener(updateChanges);
    _phoneController.addListener(updateChanges);
    _passwordController.addListener(updateChanges);
    _securityQuestionController.addListener(updateChanges);
    _securityAnswerController.addListener(updateChanges);
  }

  // تحميل سؤال الأمان الحالي إذا كان موجوداً
  Future<void> _loadSecurityQuestion() async {
    try {
      final response = await _supabase
          .from('users')
          .select('security_question')
          .eq('user_id', userID)
          .single();

      if (response != null && response['security_question'] != null) {
        setState(() {
          _securityQuestionController.text = response['security_question'];
          _showSecurityFields = true;
        });
      }
    } catch (e) {
      print('خطأ في تحميل سؤال الأمان: $e');
    }
  }

  // تشفير إجابة سؤال الأمان
  String _encryptSecurityAnswer(String answer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    final crypt = Crypt.sha256(normalizedAnswer, rounds: 10000);
    return crypt.toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final userData = {
        'username': _emailController.text.split('@')[0],
        'password': _passwordController.text,
        'full_name': _nameController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text,
        'profile_picture': defaultAvatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // إضافة سؤال الأمان وإجابته إذا كان مفعلاً
      if (_showSecurityFields) {
        if (_securityQuestionController.text.isNotEmpty) {
          userData['security_question'] = _securityQuestionController.text;
        }

        if (_securityAnswerController.text.isNotEmpty) {
          // تشفير إجابة سؤال الأمان قبل حفظها
          userData['answer_security_qu'] = _securityAnswerController.text;
        }
      } else {
        // إذا تم إلغاء تفعيل سؤال الأمان، نحذف القيم الموجودة
        userData['security_question'] = " ";
        userData['answer_security_qu'] = " ";
      }

      final response = await _supabase
          .from('users')
          .update(userData)
          .eq('user_id', userID)
          .select();

      if (mounted) {
        _showSuccessMessage('تم تحديث البيانات بنجاح');
        setState(() => _hasChanges = false);

        Navigator.pop(context, {
          ...userData,
          'user_id': userID,
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('حدث خطأ أثناء تحديث البيانات: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _securityQuestionController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        widget.isDarkMode ? Colors.red[300] : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        widget.isDarkMode ? Colors.green[300] : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) {
          Navigator.pop(context);
          return true;
        }

        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor:
            widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'تنبيه',
              style: GoogleFonts.cairo(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: Text(
              'هناك تغييرات لم يتم حفظها. هل تريد المغادرة؟',
              style: GoogleFonts.cairo(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'البقاء',
                  style: GoogleFonts.cairo(
                    color: widget.isDarkMode
                        ? Colors.white
                        : const Color(0xFF4CB8C4),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'مغادرة',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (result ?? false) {
          if (mounted) {
            Navigator.pop(context);
          }
          return true;
        }
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, // نتركها false لأننا نضيف زر مخصص
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: widget.isDarkMode
                    ? const Color(0xFF2D3748).withOpacity(0.7) // خلفية داكنة شفافة
                    : const Color(0xFF3CD3AD).withOpacity(0.3), // خلفية خضراء فاتحة شفافة
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: widget.isDarkMode
                      ? Colors.tealAccent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.3),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: widget.isDarkMode ? Colors.white : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'تعديل الملف الشخصي',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: widget.isDarkMode
                        ? [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF2C2C2C),
                    ]
                        : [
                      const Color(0xFF4CB8C4),
                      const Color(0xFF3CD3AD),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildProfileImage(),
                        const SizedBox(height: 30),
                        _buildFormFields(),
                        const SizedBox(height: 20),
                        _buildSecuritySwitch(),
                        if (_showSecurityFields) ...[
                          const SizedBox(height: 20),
                          _buildSecurityFields(),
                        ],
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isDarkMode ? Colors.grey[800] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: defaultAvatarUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 80,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('الاسم الكامل', Icons.person),
          validator: (value) =>
          value?.isEmpty ?? true ? 'يرجى إدخال الاسم الكامل' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('البريد الإلكتروني', Icons.email),
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('رقم الجوال', Icons.phone),
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('كلمة المرور', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: widget.isDarkMode ? Colors.white70 : Colors.white70,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: _validatePassword,
        ),
      ],
    );
  }

  // بناء زر تفعيل سؤال الأمان
  Widget _buildSecuritySwitch() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white24 : Colors.white30,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'تفعيل سؤال الأمان',
              style: GoogleFonts.cairo(
                color: widget.isDarkMode ? Colors.white : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: _showSecurityFields,
            onChanged: (value) {
              setState(() {
                _showSecurityFields = value;
                _hasChanges = true;
              });
            },
            activeColor: widget.isDarkMode ? Colors.tealAccent : const Color(0xFF3CD3AD),
            activeTrackColor: widget.isDarkMode ? Colors.tealAccent.withValues(alpha: 0.5) : const Color(0xFF4CB8C4).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  // بناء حقول سؤال الأمان والإجابة
  Widget _buildSecurityFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 5),
          child: Text(
            'إعدادات سؤال الأمان',
            style: GoogleFonts.cairo(
              color: widget.isDarkMode ? Colors.white : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: _securityQuestionController,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('سؤال الأمان', Icons.help_outline),
          validator: (value) => _showSecurityFields && (value?.isEmpty ?? true)
              ? 'يرجى إدخال سؤال الأمان'
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _securityAnswerController,
          obscureText: _obscureSecurityAnswer,
          style: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.white : Colors.white,
          ),
          decoration: _buildInputDecoration('إجابة سؤال الأمان', Icons.question_answer).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSecurityAnswer ? Icons.visibility : Icons.visibility_off,
                color: widget.isDarkMode ? Colors.white70 : Colors.white70,
              ),
              onPressed: () =>
                  setState(() => _obscureSecurityAnswer = !_obscureSecurityAnswer),
            ),
          ),
          validator: (value) => _showSecurityFields && (value?.isEmpty ?? true)
              ? 'يرجى إدخال إجابة سؤال الأمان'
              : null,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ملاحظة: سؤال الأمان يستخدم لاستعادة كلمة المرور في حال نسيانها',
            style: GoogleFonts.cairo(
              color: widget.isDarkMode ? Colors.white70 : Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
          backgroundColor: widget.isDarkMode
              ? Colors.tealAccent
              : const Color(0xFF4CB8C4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: widget.isDarkMode ? 2 : 3,
        ),
        child: Text(
          'حفظ التغييرات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isDarkMode ? Colors.white : const Color(0xFF4CB8C4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري حفظ البيانات...',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(
        color: widget.isDarkMode ? Colors.white70 : Colors.white70,
      ),
      prefixIcon: Icon(
        icon,
        color: widget.isDarkMode ? Colors.white70 : Colors.white70,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.white24 : Colors.white30,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.white : const Color(0xFF3CD3AD),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.1),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم جوال صحيح (10 أرقام)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}
