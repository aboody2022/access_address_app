import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final bool isDarkMode;

  const AddVehicleScreen({
    super.key,
    this.userData,
    required this.isDarkMode,
  });

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  // Text Controllers
  TextEditingController _manufacturerController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _firstLetterController = TextEditingController();
  TextEditingController _secondLetterController = TextEditingController();
  TextEditingController _thirdLetterController = TextEditingController();
  TextEditingController _plateNumbersController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  // Form Data
  String? _manufacturerId;
  String? _modelId;
  String? _year;
  String? _plateNumber;
  late int userID;
  List<Map<String, dynamic>> _manufacturers = [];
  List<Map<String, dynamic>> _models = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingModels = false;
  bool _isLoadingManufacturers = false;

  // Dynamic colors
  Color get backgroundColor =>
      widget.isDarkMode ? Colors.grey[900]! : Colors.white;

  Color get textColor => widget.isDarkMode ? Colors.white : Colors.black;

  Color get hintColor =>
      widget.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  Color get fieldColor =>
      widget.isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;

  Color get borderColor =>
      widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

  Color get cardColor => widget.isDarkMode ? Colors.grey[850]! : Colors.white;

  Color get shadowColor =>
      widget.isDarkMode ? Colors.black54 : Colors.grey[300]!;

  final arabicLettersPattern = RegExp(r'^[أبحدرسصطعقكلمنهوي]$');
  final numbersPattern = RegExp(r'^[0-9]+$');

  @override
  void initState() {
    super.initState();
    userID = widget.userData?['user_id'];
    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _buttonScale =
        Tween<double>(begin: 1.0, end: 1.1).animate(_buttonController);
    _fetchManufacturers();
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _modelController.dispose();
    _firstLetterController.dispose();
    _secondLetterController.dispose();
    _thirdLetterController.dispose();
    _plateNumbersController.dispose();
    _yearController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _fetchManufacturers() async {
    setState(() {
      _isLoadingManufacturers = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('manufacturers')
          .select('manufacturer_uuid, name')
          .order('name');

      if (!mounted) return;

      setState(() {
        _isLoadingManufacturers = false;
        if (response.isNotEmpty) {
          _manufacturers = List<Map<String, dynamic>>.from(response);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingManufacturers = false;
      });
      _showErrorSnackBar('حدث خطأ في جلب بيانات الشركات المصنعة');
    }
  }

  Future<void> _fetchModels(String manufacturerId) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
      _modelId = null;
      _modelController.clear();
    });

    try {
      final response = await Supabase.instance.client
          .from('models')
          .select('model_id, name')
          .eq('manufacturer_id', manufacturerId)
          .order('name');

      if (!mounted) return;

      setState(() {
        _isLoadingModels = false;
        if (response.isNotEmpty) {
          _models = List<Map<String, dynamic>>.from(response);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingModels = false;
      });
      _showErrorSnackBar('حدث خطأ في جلب بيانات الموديلات');
    }
  }

  void _showManufacturerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CB8C4), Color(0xFF3CD3AD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(
                    'اختر الشركة المصنعة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height * 0.5,
                ),
                child: _isLoadingManufacturers
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3CD3AD)),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _manufacturers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _manufacturers[index]['name'],
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _manufacturerId =
                          _manufacturers[index]['manufacturer_uuid'];
                          _manufacturerController.text =
                          _manufacturers[index]['name'];
                        });
                        Navigator.pop(context);
                        _fetchModels(_manufacturerId!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModelPopup() {
    if (_manufacturerId == null) {
      _showErrorSnackBar('يرجى اختيار الشركة المصنعة أولاً');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CB8C4), Color(0xFF3CD3AD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(
                    'اختر الموديل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height * 0.5,
                ),
                child: _isLoadingModels
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3CD3AD)),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _models[index]['name'],
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _modelId = _models[index]['model_id'];
                          _modelController.text = _models[index]['name'];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLetterField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha:0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'ح',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 12,
          ),
          errorStyle: TextStyle(
            height: 0,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'مطلوب';
          }
          if (!isArabicLetter(value)) {
            return 'غير صالح';
          }
          return null;
        },
        maxLength: 1,
        buildCounter: (context,
            {required currentLength, required isFocused, maxLength}) => null,
        onChanged: (value) {
          if (value.length == 1) {
            // الانتقال التلقائي إلى الحقل التالي
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  Widget _buildSaudiLicensePlate() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة السيارة',
            style: TextStyle(
              color: textColor,
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha:0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  // إضافة الشعار
                  Expanded(
                    child: SizedBox(
                      width: 40, // عرض الشعار
                      height: 65, // ارتفاع الشعار
                      child: Image.asset(
                        !widget.isDarkMode?
                        'assets/images/plate_logo.png':'assets/images/plate_white_logo.png',
                        // تأكد من وضع الشعار في المسار الصحيح
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: borderColor, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: _buildLetterField(_firstLetterController),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: _buildLetterField(_secondLetterController),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: _buildLetterField(_thirdLetterController),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _plateNumbersController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'الأرقام',
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontFamily: 'Cairo',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'أدخل الأرقام';
                        }
                        if (value.length != 4) {
                          return 'يجب إدخال 4 أرقام';
                        }
                        if (!numbersPattern.hasMatch(value)) {
                          return 'أرقام غير صالحة';
                        }
                        return null;
                      },
                      maxLength: 4,
                      buildCounter: (context,
                          {required currentLength, required isFocused, maxLength}) => null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: hintColor),
                SizedBox(width: 8),
                Text(
                  'مثال: ح ر ب 1234',
                  style: TextStyle(
                    color: hintColor,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontFamily: 'Cairo',
          ),
          filled: true,
          fillColor: fieldColor,
          prefixIcon: Icon(icon, color: hintColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF3CD3AD), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildManufacturerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        readOnly: true,
        controller: _manufacturerController,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'اختر الشركة المصنعة',
          hintStyle: TextStyle(
            color: hintColor,
            fontFamily: 'Cairo',
          ),
          filled: true,
          fillColor: fieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        onTap: _showManufacturerPopup,
        validator: (value) =>
        value == null || value.isEmpty ? 'يرجى اختيار الشركة المصنعة' : null,
      ),
    );
  }

  Widget _buildModelField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        readOnly: true,
        controller: _modelController,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'اختر موديل السيارة',
          hintStyle: TextStyle(
            color: hintColor,
            fontFamily: 'Cairo',
          ),
          filled: true,
          fillColor: fieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        onTap: () {
          if (_manufacturerId != null) {
            _showModelPopup();
          } else {
            _showErrorSnackBar('يرجى اختيار الشركة المصنعة أولاً');
          }
        },
        validator: (value) =>
        value == null || value.isEmpty ? 'يرجى اختيار موديل السيارة' : null,
      ),
    );
  }

  Widget _buildYearField() {
    return _buildTextField(
      hintText: 'سنة الصنع',
      keyboardType: TextInputType.number,
      icon: Icons.calendar_today,
      controller: _yearController,
      onSaved: (value) => _year = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال سنة الصنع';
        }
        if (!RegExp(r'^\d{4}$').hasMatch(value) ||
            int.parse(value) > DateTime
                .now()
                .year) {
          return 'السنة غير صحيحة، يرجى التحقق منها';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(double screenHeight, double screenWidth) {
    return GestureDetector(
      onTapDown: _isLoading ? null : (_) => _buttonController.forward(),
      onTapUp: _isLoading
          ? null
          : (_) {
        _buttonController.reverse();
        _submitForm();
      },
      child: ScaleTransition(
        scale: _buttonScale,
        child: Container(
          height: screenHeight * 0.06,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
                  ? [Colors.grey, Colors.grey.shade400]
                  : [Color(0xFF4CB8C4), Color(0xFF3CD3AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
              height: screenHeight * 0.03,
              width: screenHeight * 0.03,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )
                : Text(
              'إضافة',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_manufacturerId == null || _modelId == null) {
        _showErrorSnackBar('يرجى اختيار الشركة المصنعة والموديل');
        return;
      }

      final plateLetters = '${_firstLetterController
          .text}${_secondLetterController.text}${_thirdLetterController.text}';
      final plateNumbers = _plateNumbersController.text.trim();

      if (plateLetters.length != 3 || plateNumbers.isEmpty) {
        _showErrorSnackBar('يرجى إدخال رقم اللوحة بشكل صحيح');
        return;
      }

      final year = _yearController.text.trim();
      if (year.isEmpty || !RegExp(r'^\d{4}$').hasMatch(year)) {
        _showErrorSnackBar('يرجى إدخال سنة صنع صحيحة');
        return;
      }

      _year = year;
      _plateNumber = '$plateLetters $plateNumbers';

      _addVehicle();
    } else {
      _showErrorSnackBar('يرجى التأكد من صحة جميع البيانات المدخلة');
    }
  }

  Future<void> _addVehicle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.from('vehicles').insert({
        'manufacturer_id': _manufacturerId,
        'model_id': _modelId,
        'plate_number': _plateNumber,
        'year': _year,
        'user_id': userID,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة المركبة بنجاح!',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء إضافة المركبة');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        backgroundColor: widget.isDarkMode ? Colors.red[700] : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Stack(
                children: [
                  Container(
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CB8C4), Color(0xFF3CD3AD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'إضافة مركبة جديدة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: screenHeight * 0.02,
                    right: screenWidth * 0.05,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.black.withValues(alpha:0.3)
                              : Colors.white.withValues(alpha:0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedArrowRight01,
                          color: widget.isDarkMode ? Colors.white : Colors
                              .black54,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Form
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildManufacturerField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildModelField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildYearField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSaudiLicensePlate(),
                      SizedBox(height: screenHeight * 0.03),
                      _buildSubmitButton(screenHeight, screenWidth),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isArabicLetter(String letter) {
    // تحقق مما إذا كان الحرف هو حرف عربي
    return RegExp(r'^[\u0621-\u064A]$').hasMatch(letter);
  }
}