import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/buildHeader.dart';
import 'add_vehicle_screen.dart';
import 'package:flutter/services.dart';

class MyVehiclesScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; // بيانات المستخدم
  const MyVehiclesScreen({super.key, this.userData});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final List<Map<String, dynamic>> _vehicles = [];
  final List<Map<String, dynamic>> _manufacturers = [];
  String _searchQuery = '';
  String _selectedBrand = 'الكل';
  late int userID;
  Timer? _timer;
  final TextEditingController _searchController =
      TextEditingController(); // TextEditingController للتحكم في مربع البحث

  @override
  void initState() {
    super.initState();
    userID = widget.userData?['user_id'] ?? 0;
    _fetchManufacturers();
    _fetchVehicles();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchVehicles(); // جلب المركبات كل 30 ثانية
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // إلغاء Timer عند التخلص من الشاشة
    _searchController.dispose(); // التخلص من TextEditingController
    super.dispose();
  }

  Future<void> _fetchManufacturers() async {
    try {
      final response =
          await Supabase.instance.client.from('manufacturers').select('name');

      if (response.isNotEmpty) {
        setState(() {
          _manufacturers.clear();
          _manufacturers.addAll(List<Map<String, dynamic>>.from(response));
        });
      } else {
      }
    } catch (error) {
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      final vehicleResponse = await Supabase.instance.client
          .from('vehicles')
          .select('*, manufacturers(name), models(name)')
          .eq('user_id', userID)
          .order('created_at', ascending: false);

      if (vehicleResponse.isNotEmpty) {
        setState(() {
          _vehicles.clear();
          _vehicles.addAll(List<Map<String, dynamic>>.from(vehicleResponse));
        });
      } else {
        // _showSnackbar(
        //     'لا توجد مركبات لهذا المستخدم.', 'تنبيه', SnackBarType.alert);
      }
    } catch (error) {
      _showSnackbar(
          'تنبيه', 'لا توجد مركبات لهذا المستخدم.', SnackBarType.alert);
    }
  }

  void _showSnackbar(String title, String message, SnackBarType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      IconSnackBar.show(
        context,
        snackBarType: type,
        label: message,
        backgroundColor: type == SnackBarType.fail ? Colors.red : Colors.green,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    final filteredVehicles = _vehicles.where((vehicle) {
      final modelName = vehicle['models']['name'].toString().toLowerCase();
      final manufacturerName =
          vehicle['manufacturers']['name'].toString().toLowerCase();
      final searchQueryLower = _searchQuery.toLowerCase();

      final matchesSearch = modelName.contains(searchQueryLower) ||
          manufacturerName.contains(searchQueryLower);
      final matchesBrand = _selectedBrand == 'الكل' ||
          vehicle['manufacturers']['name'] == _selectedBrand;
      return matchesSearch && matchesBrand;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            buildHeader(size, 'مركباتي', 'هنا يمكنك عرض وإدارة مركباتك',userID),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller:
                            _searchController, // تعيين TextEditingController
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value; // تحديث نص البحث
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مركبة...',
                          prefixIcon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch02,
                              color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = ''; // مسح النص
                                      _searchController
                                          .clear(); // مسح النص في TextField
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _showFilterDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A8A8).withValues(alpha:0.8),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const HugeIcon(
                              icon: HugeIcons.strokeRoundedFilter,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _selectedBrand == 'الكل'
                                ? 'فلترة'
                                : _selectedBrand, // عرض اسم العلامة التجارية المحددة
                            style: const TextStyle(
                              color: Colors.white,
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
            Expanded(
              child: filteredVehicles.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: _fetchVehicles,
                      child: LiveList(
                        showItemInterval:
                            Duration(milliseconds: 150), // تأخير بين العناصر
                        showItemDuration:
                            Duration(milliseconds: 300), // مدة الحركة
                        reAnimateOnVisibility: true, // إعادة التحريك عند الظهور
                        scrollDirection: Axis.vertical,
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index, animation) {
                          final vehicle = filteredVehicles[index];
                          return FadeTransition(
                            opacity: animation, // تأثير الشفافية التدريجي
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0.3, 0), // يبدأ من الأسفل قليلًا
                                end: Offset.zero,
                              ).animate(animation),
                              child: Dismissible(
                                key: Key(vehicle['vehicle_id'].toString()),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedDelete03,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedEdit01,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    _showEditDialog(vehicle);
                                    return false;
                                  } else if (direction ==
                                      DismissDirection.startToEnd) {
                                    return await _confirmDelete(vehicle);
                                  }
                                  return false;
                                },
                                child: _buildVehicleItem(vehicle),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/404.png', // تأكد من وجود الصورة في المسار الصحيح
                            height: 150,
                            width: 350,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد مركبات متاحة',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                AddVehicleScreen (
                        userData: widget.userData,
                        isDarkMode: AdaptiveTheme.of(context).brightness ==
                            Brightness.dark),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            ).then((value) {
              _fetchVehicles(); // Refresh the vehicle list after adding a new vehicle
            });
          },
          backgroundColor: isDarkMode ? Colors.grey[800] : Color(0xFF00A8A8),
          child: Icon(HugeIcons.strokeRoundedAddCircle,
              color: isDarkMode ? Colors.white : Colors.white),
        ),
      ),
    );
  }

  Widget _buildVehicleItem(Map<String, dynamic> vehicle) {
    final model = vehicle['models']['name'] ?? 'غير متوفر';
    // final year = vehicle['year'].toString();
    final brand = vehicle['manufacturers']['name'] ?? 'غير متوفر';
    final registrationStatus = vehicle['is_active']; // حالة التسجيل
    final renewalDate = vehicle['year'] ?? 'غير متوفر'; // تاريخ التجديد

    // تحديد لون الحالة
    Color statusColor;
    // String statusText;
    if (registrationStatus == true) {
      statusColor = Colors.green;
      // statusText = 'نشط';
    } else {
      statusColor = Colors.red;
      // statusText = 'خامل';
    }
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        _showVehicleDetailsDialog(vehicle); // استدعاء دالة عرض التفاصيل
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // صورة المركبة
            Image.asset(
              'assets/images/car.png', // تأكد من وجود الصورة في المسار الصحيح
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$model',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$brand',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // حالة التجديد
                      Row(
                        children: [
                          Text(
                            '$renewalDate',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.circle,
                          color: statusColor,
                          size: 18,
                        ),
                      ),
                      // زر التجديد
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> vehicle) {
    final TextEditingController modelController =
        TextEditingController(text: vehicle['models']['name']);
    final TextEditingController yearController =
        TextEditingController(text: vehicle['year'].toString());

    // Controllers for each part of the license plate
    final TextEditingController firstLetterController = TextEditingController(
        text: vehicle['plate_number']?.substring(0, 1) ?? '');
    final TextEditingController secondLetterController = TextEditingController(
        text: vehicle['plate_number']?.substring(1, 2) ?? '');
    final TextEditingController thirdLetterController = TextEditingController(
        text: vehicle['plate_number']?.substring(2, 3) ?? '');
    final TextEditingController plateNumbersController = TextEditingController(
        text: vehicle['plate_number']?.substring(3) ?? '');

    bool selectedStatus = vehicle['is_active'];

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        final isDarkMode =
            AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CB8C4),
                      Color(0xFF3CD3AD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(HugeIcons.strokeRoundedEdit02,
                        color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'تعديل بيانات المركبة',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // حقل اسم الطراز
                    TextField(
                      controller: modelController,
                      decoration: InputDecoration(
                        labelText: 'اسم الطراز',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    // حقل سنة الصنع
                    TextField(
                      controller: yearController,
                      decoration: InputDecoration(
                        labelText: 'سنة الصنع',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    // حقل رقم اللوحة
                    Column(
                      children: [
                        const Text(
                          'لوحة السيارة',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // First letter input
                            Expanded(
                              child: TextField(
                                controller: firstLetterController,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'حرف 1',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                                ),
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'[\u0621-\u064A]')), // Allow only Arabic letters
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Space between letters
                            // Second letter input
                            Expanded(
                              child: TextField(
                                controller: secondLetterController,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'حرف 2',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                                ),
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'[\u0621-\u064A]')), // Allow only Arabic letters
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Space between letters
                            // Third letter input
                            Expanded(
                              child: TextField(
                                controller: thirdLetterController,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'حرف 3',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                                ),
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      r'[\u0621-\u064A]')), // Allow only Arabic letters
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Space between letters
                            // Plate numbers input
                            Expanded(
                              child: TextField(
                                controller: plateNumbersController,
                                maxLength:
                                    4, // Assuming the plate number has 4 digits
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'الأرقام',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                                ),
                                keyboardType:
                                    TextInputType.number, // Only allow numbers
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')), // Allow only numbers
                                ],
                                onChanged: (value) {
                                  // Remove spaces
                                  plateNumbersController.text =
                                      value.replaceAll(' ', '');
                                  plateNumbersController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset:
                                            plateNumbersController.text.length),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // عنوان حالة السيارة
                    const Text(
                      'حالة السيارة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 10),
                    // أزرار الاختيار لاختيار حالة السيارة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedStatus
                                  ? Color(0xFF4CB8C4)
                                  : Colors.grey, // لون الزر النشط
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedStatus = true;
                              });
                            },
                            child: const Text(
                              'نشط',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !selectedStatus
                                  ? Color(0xFF3CD3AD)
                                  : Colors.grey, // لون الزر غير النشط
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedStatus = false;
                              });
                            },
                            child: const Text(
                              'غير نشط',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // زر إلغاء
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // تغيير اللون إلى الرمادي
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                // زر حفظ
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFF4CB8C4), // لون مقارب للون الخلفية
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15), // زيادة الحجم
                  ),
                  onPressed: () {
                    // التحقق من صحة المدخلات
                    final currentYear = DateTime.now().year;
                    final year = int.tryParse(yearController.text);
                    final licensePlate =
                        '${firstLetterController.text}${secondLetterController.text}${thirdLetterController.text}${plateNumbersController.text}';

                    // تحقق من سنة الصنع
                    if (year == null || year < 1998 || year > currentYear) {
                      _showSnackbar(
                          'خطأ',
                          'يرجى إدخال سنة صحيحة بين 1998 و $currentYear.',
                          SnackBarType.fail);
                      return;
                    }

                    final updatedVehicle = {
                      'manufacturer_id': vehicle['manufacturer_id'],
                      'model_id': vehicle['model_id'],
                      'vehicle_id': vehicle['vehicle_id'],
                      'year': year,
                      'plate_number': licensePlate,
                      'is_active': selectedStatus,
                    };
                    Supabase.instance.client
                        .from('vehicles')
                        .update(updatedVehicle)
                        .eq('vehicle_id', vehicle['vehicle_id'])
                        .then((value) => _showSnackbar('نجاح',
                            'تم تحديث المركبة بنجاح.', SnackBarType.success));
                    Navigator.of(context).pop();
                    _fetchVehicles();
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDelete(Map<String, dynamic> vehicle) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // زوايا مدورة
          ),
          contentPadding: const EdgeInsets.all(20),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha:0.1), // خلفية دائرية حمراء
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'حذف المركبة',
                style: TextStyle(
                  fontSize: 20, // حجم الخط
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هل أنت متأكد أنك تريد حذف هذه المركبة؟ هذه العملية لا يمكن التراجع عنها.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14, // حجم خط أصغر
                ),
              ),
              const SizedBox(height: 10),
              Text(
                vehicle['models']['name'] ?? 'غير متوفر',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // حجم خط أكبر
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: 100, // عرض زر الإلغاء
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // إلغاء
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300], // لون زر الإلغاء
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // زيادة ارتفاع الزر
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontSize: 16), // حجم خط أكبر
                ),
              ),
            ),
            const SizedBox(width: 10), // مسافة بين الأزرار
            SizedBox(
              width: 100, // عرض زر الحذف
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // إغلاق النافذة المنبثقة
                  _showLoadingDialog(); // إظهار نافذة التحميل

                  // تنفيذ عملية الحذف هنا
                  _deleteVehicle(vehicle);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red, // لون زر الحذف
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // زيادة ارتفاع الزر
                ),
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.white, // لون النص في زر الحذف
                    fontSize: 16, // حجم خط أكبر
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // منع إغلاق النافذة عند الضغط في أي مكان
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Text('جاري الحذف...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteVehicle(Map<String, dynamic> vehicle) async {
    final response = await Supabase.instance.client
        .from('vehicles')
        .delete()
        .eq('vehicle_id', vehicle['vehicle_id']);

    Navigator.of(context).pop(); // إغلاق نافذة التحميل

    if (response.error == null) {
      _showSuccessSnackbar('تم حذف المركبة بنجاح.');
      _fetchVehicles(); // تحديث قائمة المركبات
    } else {
      _showErrorSnackbar('خطأ في حذف المركبة: ${response.error!.message}');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر العلامة التجارية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(context, 'الكل'),
                  const SizedBox(height: 10),
                  ..._manufacturers.map((manufacturer) {
                    return _buildFilterOption(context, manufacturer['name']);
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showVehicleDetailsDialog(Map<String, dynamic> vehicle) {
  //   final model = vehicle['models']['name'] ?? 'غير متوفر';
  //   final year = vehicle['year'].toString();
  //   final brand = vehicle['manufacturers']['name'] ?? 'غير متوفر';
  //   final plateNumber = vehicle['plate_number'] ?? 'غير متوفر';
  //   final registrationStatus = vehicle['is_active'] ? 'نشط' : 'غير نشط';
  //   final statusColor = vehicle['is_active'] ? Colors.green : Colors.red;
  //
  //   // فصل الحروف والأرقام من رقم اللوحة
  //     final plateLetters = plateNumber.substring(0, 3); // أول 3 حروف
  //     final plateNumbers = plateNumber.substring(3); // الأرقام
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         insetPadding: EdgeInsets.all(20),
  //         child: Container(
  //           padding: EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [Colors.white, Color(0xFFF5F5F5)],
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //             ),
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     'تفاصيل المركبة',
  //                     style: TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF3CD3AD),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               Divider(color: Colors.grey[300], thickness: 1),
  //               SizedBox(height: 15),
  //
  //               // معلومات المركبة
  //               _buildDetailRow(Icons.directions_car, 'الموديل', model),
  //               _buildDetailRow(Icons.calendar_today, 'السنة', year),
  //               _buildDetailRow(Icons.branding_watermark, 'العلامة التجارية', brand),
  //               SizedBox(height: 20),
  //
  //               // حالة التسجيل
  //               Container(
  //                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //                 decoration: BoxDecoration(
  //                   color: statusColor.withValues(alpha:0.1),
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(Icons.circle, color: statusColor, size: 12),
  //                     SizedBox(width: 8),
  //                     Text(
  //                       'حالة المركبة: $registrationStatus',
  //                       style: TextStyle(
  //                         color: statusColor,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(height: 25),
  //
  //               // قسم لوحة السيارة (كما هو)
  //               Container(
  //                 padding: EdgeInsets.all(15),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(15),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 10,
  //                       offset: Offset(0, 4),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       'لوحة المركبة',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.grey[700],
  //                       ),
  //                     ),
  //                     SizedBox(height: 15),
  //                     Container(
  //                       padding: const EdgeInsets.all(10),
  //                       decoration: BoxDecoration(
  //                         border: Border.all(color: Colors.black, width: 2),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Expanded(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Image.asset(
  //                                   'assets/images/plate_logo.png', // تأكد من وجود الصورة في المسار الصحيح
  //                                   height:50, // حجم الشعار
  //                                 ),
  //
  //                               ],
  //                             ),
  //                           ),
  //                           const SizedBox(width: 10), // مسافة بين الشعار واللوحة
  //                           // عرض الحروف
  //                           for (var letter in plateLetters.split(''))
  //                             Expanded(
  //                               child: Container(
  //                                 height: 40,
  //                                 margin: const EdgeInsets.symmetric(horizontal: 4),
  //                                 decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.grey),
  //                                   borderRadius: BorderRadius.circular(5),
  //                                 ),
  //                                 child: Center(
  //                                   child: Text(
  //                                     letter,
  //                                     style: TextStyle(fontSize: 20,color:Colors.black87),
  //                                     textAlign: TextAlign.center,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           SizedBox(child:Text("|",style:TextStyle(fontSize:30),textAlign:TextAlign.center,)),
  //                           // عرض الأرقام
  //                           for (var number in plateNumbers.split(''))
  //                             Expanded(
  //                               flex:1,
  //                               child: Container(
  //                                 height: 40,
  //                                 margin: const EdgeInsets.symmetric(horizontal: 4),
  //                                 decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.grey),
  //                                   borderRadius: BorderRadius.circular(5),
  //                                 ),
  //                                 child: Center(
  //                                   child: Text(
  //                                     number,
  //                                     style: TextStyle(fontSize: 24,color:Colors.black87),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showVehicleDetailsDialog(Map<String, dynamic> vehicle) {
    final model = vehicle['models']['name'] ?? 'غير متوفر';
    final year = vehicle['year'].toString();
    final brand = vehicle['manufacturers']['name'] ?? 'غير متوفر';
    final plateNumber = vehicle['plate_number'] ?? 'غير متوفر';
    final registrationStatus = vehicle['is_active'] ? 'نشط' : 'غير نشط';
    final statusColor = vehicle['is_active'] ? Colors.green : Colors.red;

    // فصل الحروف والأرقام من رقم اللوحة
    final plateLetters = plateNumber.substring(0, 3); // أول 3 حروف
    final plateNumbers = plateNumber.substring(3); // الأرقام

    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تفاصيل المركبة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3CD3AD),
                      ),
                    )
                  ],
                ),
                Divider(color: Colors.grey[300], thickness: 1),
                SizedBox(height: 15),

                // معلومات المركبة
                _buildDetailRow(
                    Icons.directions_car, 'الموديل', model, isDarkMode),
                _buildDetailRow(
                    Icons.calendar_today, 'السنة', year, isDarkMode),
                _buildDetailRow(Icons.branding_watermark, 'العلامة التجارية',
                    brand, isDarkMode),
                SizedBox(height: 20),

                // حالة التسجيل
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: statusColor, size: 12),
                      SizedBox(width: 8),
                      Text(
                        'حالة المركبة: $registrationStatus',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // قسم لوحة السيارة (كما هو)
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'لوحة المركبة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    !isDarkMode?
                                    'assets/images/plate_logo.png': 'assets/images/plate_white_logo.png', // تأكد من وجود الصورة في المسار الصحيح
                                    height: 50, // حجم الشعار
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width: 10), // مسافة بين الشعار واللوحة
                            // عرض الحروف
                            for (var letter in plateLetters.split(''))
                              Expanded(
                                child: Container(
                                  height: 40,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                                child: Text("|",
                                    style: TextStyle(fontSize: 30),
                                    textAlign: TextAlign.center)),
                            // عرض الأرقام
                            for (var number in plateNumbers.split(''))
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 40,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      number,
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.black87),
                                    ),
                                  ),
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
        );
      },
    );
  }

  // Widget _buildDetailRow(IconData icon, String title, String value) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Color(0xFF3CD3AD).withValues(alpha:0.1),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Icon(icon, color: Color(0xFF3CD3AD), size: 22),
  //         ),
  //         SizedBox(width: 15),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //             SizedBox(height: 2),
  //             Text(
  //               value,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //                 color: Colors.grey[800],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDetailRow(
      IconData icon, String title, String value, bool isDarkMode) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF3CD3AD).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF3CD3AD), size: 22),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String brand) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrand = brand; // تحديث العلامة التجارية المحددة
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectedBrand == brand
              ? const Color(0xFF00A8A8).withValues(alpha:0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: _selectedBrand == brand
                  ? const Color(0xFF00A8A8)
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              brand,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedBrand == brand
                    ? const Color(0xFF00A8A8)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
