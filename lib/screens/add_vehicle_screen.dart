import 'package:access_address_app/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer; // Import for developer.log

// Helper function to convert Arabic numerals to English numerals
String convertArabicToEnglishNumbers(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const english = '0123456789';
  return input.replaceAllMapped(RegExp('[٠-٩]'), (match) {
    return english[arabic.indexOf(match.group(0)!)];
  });
}

// Helper function to convert English numerals to Arabic numerals
String convertEnglishToArabicNumbers(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const english = '0123456789';
  return input.replaceAllMapped(RegExp('[0-9]'), (match) {
    return arabic[english.indexOf(match.group(0)!)];
  });
}

// Helper function to check if a character is an Arabic letter
bool isArabicLetter(String char) {
  final arabicLettersPattern = RegExp(r'^[أبجدهوزحطيكلمنسعفصقرتثخذضظغشءؤئلا]$');
  return arabicLettersPattern.hasMatch(char);
}

class AddVehicleScreen extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic>? userData;

  const AddVehicleScreen({
    Key? key,
    required this.isDarkMode,
    this.userData,
  }) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
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
  String? _plateNumber; // This will be constructed from separate fields
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

  // Updated regex to support both Arabic and English numbers for the numbers part of the plate
  final numbersPattern = RegExp(r'^[0-9٠-٩]+$');

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
      final List<Map<String, dynamic>> response = await Supabase.instance.client
          .from('manufacturers')
          .select('manufacturer_uuid, name')
          .order('name');

      if (!mounted) return;

      setState(() {
        _isLoadingManufacturers = false;
        _manufacturers = response;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingManufacturers = false;
      });
      developer.log('Error fetching manufacturers: ${e.message}', name: 'AddVehicleScreen');
      _showErrorSnackBar('حدث خطأ في جلب بيانات الشركات المصنعة.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingManufacturers = false;
      });
      developer.log('Unexpected error fetching manufacturers: ${error.toString()}', name: 'AddVehicleScreen');
      _showErrorSnackBar('حدث خطأ غير متوقع في جلب بيانات الشركات المصنعة.');
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
      final List<Map<String, dynamic>> response = await Supabase.instance.client
          .from('models')
          .select('model_id, name')
          .eq('manufacturer_id', manufacturerId)
          .order('name');

      if (!mounted) return;

      setState(() {
        _isLoadingModels = false;
        _models = response;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingModels = false;
      });
      developer.log('Error fetching models: ${e.message}', name: 'AddVehicleScreen');
      _showErrorSnackBar('حدث خطأ في جلب بيانات الموديلات.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingModels = false;
      });
      developer.log('Unexpected error fetching models: ${error.toString()}', name: 'AddVehicleScreen');
      _showErrorSnackBar('حدث خطأ غير متوقع في جلب بيانات الموديلات.');
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
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String yearEnglish = convertArabicToEnglishNumbers(_yearController.text);
        final String combinedPlateNumber =
            _firstLetterController.text +
                _secondLetterController.text +
                _thirdLetterController.text +
                convertArabicToEnglishNumbers(_plateNumbersController.text);

        // Await the insert operation. On success, this returns List<Map<String, dynamic>>.
        // On error, it throws a PostgrestException.
        final List<Map<String, dynamic>> data = await Supabase.instance.client.from('vehicles').insert({
          'user_id': userID,
          'manufacturer_id': _manufacturerId,
          'model_id': _modelId,
          'plate_number': combinedPlateNumber,
          'year': int.parse(yearEnglish),
        }).select(); // .select() is crucial for getting data back or throwing an error

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // If we reach here, it means the insert was successful and .select() returned data
        if (data.isNotEmpty) {
          developer.log('Supabase Insert Success: Data received: $data', name: 'AddVehicleScreen');
          _showSuccessSnackBar('تمت إضافة المركبة بنجاح!');
          Navigator.pop(context); // Navigate back on success
        } else {
          // This case might happen if .select() returns an empty list on success for some reason
          developer.log('Supabase Insert Success: Empty data received, but no error. Assuming success.', name: 'AddVehicleScreen');
          _showSuccessSnackBar('تمت إضافة المركبة بنجاح!');
          Navigator.pop(context); // Navigate back on success
        }

      } on PostgrestException catch (e) {
        // This block catches all Postgrest-specific exceptions thrown by the client
        // (e.g., network issues, invalid API key, unique constraint violation, etc.)
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        developer.log(
          'Supabase PostgrestException (caught): ${e.message} ' +
              '(Code: ${e.code}, Details: ${e.details}, Hint: ${e.hint})',
          name: 'AddVehicleScreen',
        );
        if (e.code == '23505') { // Unique constraint violation
          _showErrorSnackBar('رقم اللوحة موجود بالفعل.');
        } else {
          _showErrorSnackBar('فشل إضافة المركبة.');
        }
      } catch (error) {
        // This catches any other unexpected errors (e.g., general Dart errors, parsing errors)
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        developer.log('Unexpected Error during vehicle addition (general catch): ${error.toString()}', name: 'AddVehicleScreen');
        _showErrorSnackBar('حدث خطأ غير متوقع أثناء إضافة المركبة.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'إضافة مركبة جديدة',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Manufacturer Field
              Text(
                'الشركة المصنعة',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _showManufacturerPopup,
                child: AbsorbPointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withValues(alpha:0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _manufacturerController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'اختر الشركة المصنعة',
                              hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo'),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(color: textColor, fontFamily: 'Cairo'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء اختيار الشركة المصنعة';
                              }
                              return null;
                            },
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: textColor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Model Field
              Text(
                'الموديل',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _showModelPopup,
                child: AbsorbPointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'اختر الموديل',
                              hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo'),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(color: textColor, fontFamily: 'Cairo'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء اختيار الموديل';
                              }
                              return null;
                            },
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: textColor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Plate Number Fields
              Text(
                'رقم اللوحة',
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // First Letter
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _firstLetterController,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: textColor, fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'ح',
                          hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo', fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ''; // No error message for empty single field
                          } else if (!isArabicLetter(value)) {
                            return ''; // No error message for invalid single field
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
                  // Second Letter
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _secondLetterController,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: textColor, fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'ر',
                          hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo', fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          } else if (!isArabicLetter(value)) {
                            return '';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
                  // Third Letter
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _thirdLetterController,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: textColor, fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'ف',
                          hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo', fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          } else if (!isArabicLetter(value)) {
                            return '';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
                  // Plate Numbers
                  SizedBox(width:5),
                  Expanded(flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _plateNumbersController,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: '1234',
                          hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo', fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          } else if (convertArabicToEnglishNumbers(value).length != 4 || !numbersPattern.hasMatch(value)) {
                            return '';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Combined Plate Number Validator (for overall validation message)
              Builder(
                builder: (BuildContext context) {
                  final String firstLetter = _firstLetterController.text;
                  final String secondLetter = _secondLetterController.text;
                  final String thirdLetter = _thirdLetterController.text;
                  final String plateNumbers = _plateNumbersController.text;

                  if (firstLetter.isEmpty || secondLetter.isEmpty || thirdLetter.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'الرجاء إدخال ثلاثة أحرف للوحة.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  } else if (!isArabicLetter(firstLetter) || !isArabicLetter(secondLetter) || !isArabicLetter(thirdLetter)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'الرجاء إدخال أحرف عربية صحيحة.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  } else if (plateNumbers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'الرجاء إدخال أربعة أرقام للوحة.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  } else if (convertArabicToEnglishNumbers(plateNumbers).length != 4 || !numbersPattern.hasMatch(plateNumbers)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'الرجاء إدخال أربعة أرقام صحيحة للوحة.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 16),

              // Year Field
              Text(
                'سنة الصنع',
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
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor, fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    hintText: 'أدخل سنة الصنع (مثال: 2023)',
                    hintStyle: TextStyle(color: hintColor, fontFamily: 'Cairo'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال سنة الصنع';
                    }
                    final year = int.tryParse(convertArabicToEnglishNumbers(value));
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'الرجاء إدخال سنة صنع صالحة';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 24),

              // Add Vehicle Button
              ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    _buttonController.forward().then((_) => _buttonController.reverse());
                    await _addVehicle();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF3CD3AD), // Button background color
                    foregroundColor: Colors.white, // Text color
                    elevation: 5,
                    shadowColor: Color(0xFF3CD3AD).withValues(alpha:0.4),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'إضافة المركبة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
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
}

