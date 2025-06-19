import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async'; // استيراد مكتبة async
import 'package:access_address_app/widgets/buildHeader.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // استيراد حزمة intl لتنسيق التاريخ
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart'; // استيراد حزمة snackbar

class MyOrdersScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; // بيانات المستخدم

  const MyOrdersScreen({super.key, this.userData});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> _orders = []; // قائمة الطلبات
  String _searchQuery = ''; // استعلام البحث
  String _selectedStatus = 'الكل'; // الحالة المحددة
  late int userID; // معرف المستخدم
  Timer? _timer; // متغير المؤقت
  RefreshController _refreshController =
  RefreshController(initialRefresh: false); // تحكم التحديث
  bool _isLoading = false; // حالة التحميل
  bool _isDisposed = false; // للتحقق من حالة dispose

  @override
  void initState() {
    super.initState();
    userID = widget.userData?['user_id'] ?? 0; // تعيين قيمة افتراضية إذا كانت null
    _fetchOrders(); // جلب الطلبات عند بدء الشاشة

    // إعداد المؤقت لتحديث الطلبات كل 30 ثانية (تحسين من 10 ثوانٍ)
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_isDisposed && mounted) {
        _fetchOrders();
      }
    });
  }

  // دالة لجلب الطلبات من قاعدة البيانات (محسنة)
  Future<void> _fetchOrders() async {
    if (_isLoading || _isDisposed) return; // تجنب التحميل المتعدد

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('maintenance_requests')
          .select(
          '*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description,request_id,service_provider') // استرجاع البيانات من الجداول المرتبطة
          .eq('user_id', userID)
          .order('created_at', ascending: false); // ترتيب حسب تاريخ الطلب

      if (!mounted || _isDisposed) return; // التحقق من mounted قبل setState

      if (response.isNotEmpty) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response); // تحديث قائمة الطلبات
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب الطلبات', SnackBarType.fail);
    }
  }

  // دالة لتحديث البيانات عند السحب للأسفل (محسنة)
  Future<void> _onRefresh() async {
    await _fetchOrders(); // تحديث البيانات
    if (mounted && !_isDisposed) {
      _refreshController.refreshCompleted(); // إكمال عملية التحديث
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // تعيين حالة dispose
    _timer?.cancel(); // إلغاء المؤقت
    _refreshController.dispose(); // إلغاء تحكم التحديث
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);

    // تصفية الطلبات بناءً على البحث والفلترة (محسنة)
    final filteredOrders = _orders.where((order) {
      final modelName = order['vehicles']?['models']?['name']?.toString().toLowerCase() ?? 'غير محدد';
      final vehicleYear = order['vehicles']?['year']?.toString().toLowerCase() ?? '';
      final statusId = order['status_id']?.toString() ?? '0';

      final matchesSearch = modelName.contains(_searchQuery.toLowerCase()) ||
          vehicleYear.contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'الكل' ||
          _getStatusText(int.tryParse(statusId) ?? 0) == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl, // تعيين اتجاه النص
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            buildHeader(
                size, 'طلباتي', 'هنا يمكنك عرض طلباتك السابقة', userID), // رأس الشاشة
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // شريط البحث (محسن)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          if (mounted && !_isDisposed) {
                            setState(() {
                              _searchQuery = value; // تحديث استعلام البحث
                            });
                          }
                        },
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن طلب...',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixIcon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch02,
                            color: isDarkMode
                                ? (Colors.grey[400] ?? Colors.grey)
                                : Colors.grey,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty // زر "X" لمسح النص
                              ? IconButton(
                            icon: Icon(Icons.clear,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey),
                            onPressed: () {
                              if (mounted && !_isDisposed) {
                                setState(() {
                                  _searchQuery = ''; // مسح النص
                                });
                              }
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // زر الفلترة (محسن)
                  GestureDetector(
                    onTap: () {
                      _showFilterDialog(context); // عرض نافذة الفلترة
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_selectedStatus),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedFilter,
                              color: Colors.white,
                              size: 24),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _selectedStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
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
              child: SmartRefresher(
                controller: _refreshController, // تحكم التحديث
                onRefresh: _onRefresh, // دالة التحديث عند السحب
                header: WaterDropHeader(
                  waterDropColor: Colors.tealAccent.shade400,
                  idleIcon: Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.tealAccent.shade700,
                  ),
                  refresh: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.tealAccent.shade700),
                    ),
                  ),
                  complete: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'تم التحديث',
                        style: TextStyle(
                            color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  completeDuration: Duration(milliseconds: 1000),
                ),
                child: _isLoading && _orders.isEmpty
                    ? Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : Colors.blue,
                  ),
                )
                    : filteredOrders.isNotEmpty
                    ? LiveList(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index, animation) {
                    final order = filteredOrders[index];
                    return FadeTransition(
                      opacity: animation,
                      child: Dismissible(
                        key: ValueKey('${order['request_id']}_$index'),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete03,
                                  color: Colors.white,
                                  size: 28),
                              SizedBox(width: 10),
                              HugeIcon(
                                  icon: HugeIcons.strokeRoundedSwipeLeft01,
                                  color: Colors.white,
                                  size: 28),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog(context);
                        },
                        onDismissed: (direction) async {
                          final requestId = order['request_id'];
                          if (requestId != null) {
                            if (mounted && !_isDisposed) {
                              setState(() {
                                _orders.removeWhere(
                                        (item) => item['request_id'] == requestId);
                              });
                            }
                            await _deleteOrderFromDatabase(requestId);
                          } else {
                            _showSnackbar('خطأ', 'معرف الطلب غير موجود',
                                SnackBarType.fail);
                          }
                        },
                        child: _buildOrderItem(
                          context,
                          order['vehicles']?['models']?['name'] ?? 'غير محدد',
                          order['vehicles']?['year']?.toString() ?? 'غير محدد',
                          order['request_type'] ?? 'غير محدد',
                          order['service_provider'] ?? 'غير محدد',
                          order['problem_description'] ?? 'غير محدد',
                          order['created_at'],
                          order['status_id']?.toString() ?? '0',
                          isDarkMode,
                        ),
                      ),
                    );
                  },
                )
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: size.height * 0.7,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          isDarkMode
                              ? 'assets/images/no_results_white.png'
                              : 'assets/images/no_results.png',
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد اي طلبات',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة
  //   final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
  //   final theme = Theme.of(context);
  //
  //   // تصفية الطلبات بناءً على البحث والفلترة (محسنة)
  //   final filteredOrders = _orders.where((order) {
  //     final modelName = order['vehicles']?['models']?['name']?.toString().toLowerCase() ?? 'غير محدد';
  //     final vehicleYear = order['vehicles']?['year']?.toString().toLowerCase() ?? '';
  //     final statusId = order['status_id']?.toString() ?? '0';
  //
  //     final matchesSearch = modelName.contains(_searchQuery.toLowerCase()) ||
  //         vehicleYear.contains(_searchQuery.toLowerCase());
  //     final matchesStatus = _selectedStatus == 'الكل' ||
  //         _getStatusText(int.tryParse(statusId) ?? 0) == _selectedStatus;
  //
  //     return matchesSearch && matchesStatus;
  //   }).toList();
  //
  //   return Directionality(
  //     textDirection: ui.TextDirection.rtl, // تعيين اتجاه النص
  //     child: Scaffold(
  //       backgroundColor: theme.scaffoldBackgroundColor,
  //       body: Column(
  //         children: [
  //           buildHeader(
  //               size, 'طلباتي', 'هنا يمكنك عرض طلباتك السابقة', userID), // رأس الشاشة
  //           Padding(
  //             padding:
  //             const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //             child: Row(
  //               children: [
  //                 // شريط البحث (محسن)
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(30),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withValues(alpha: 0.05),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 4),
  //                         ),
  //                       ],
  //                     ),
  //                     child: TextField(
  //                       onChanged: (value) {
  //                         if (mounted && !_isDisposed) {
  //                           setState(() {
  //                             _searchQuery = value; // تحديث استعلام البحث
  //                           });
  //                         }
  //                       },
  //                       style: TextStyle(
  //                         color: isDarkMode ? Colors.white : Colors.black,
  //                       ),
  //                       decoration: InputDecoration(
  //                         hintText: 'ابحث عن طلب...',
  //                         hintStyle: TextStyle(
  //                           color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
  //                         ),
  //                         prefixIcon: HugeIcon(
  //                           icon: HugeIcons.strokeRoundedSearch02,
  //                           color: isDarkMode ? (Colors.grey[400] ?? Colors.grey) : Colors.grey,
  //                         ),
  //                         suffixIcon: _searchQuery.isNotEmpty // زر "X" لمسح النص
  //                             ? IconButton(
  //                           icon: Icon(Icons.clear,
  //                               color: isDarkMode ? Colors.grey[400] : Colors.grey),
  //                           onPressed: () {
  //                             if (mounted && !_isDisposed) {
  //                               setState(() {
  //                                 _searchQuery = ''; // مسح النص
  //                               });
  //                             }
  //                           },
  //                         )
  //                             : null,
  //                         border: InputBorder.none,
  //                         contentPadding: EdgeInsets.symmetric(
  //                             vertical: 14, horizontal: 16),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 // زر الفلترة (محسن)
  //                 GestureDetector(
  //                   onTap: () {
  //                     _showFilterDialog(context); // عرض نافذة الفلترة
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 16, vertical: 12),
  //                     decoration: BoxDecoration(
  //                       color: _getStatusColor(_selectedStatus),
  //                       borderRadius: BorderRadius.circular(30),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withValues(alpha: 0.1),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 4),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         HugeIcon(
  //                             icon: HugeIcons.strokeRoundedFilter,
  //                             color: Colors.white,
  //                             size: 24),
  //                         const SizedBox(width: 8),
  //                         Flexible(
  //                           child: Text(
  //                             _selectedStatus,
  //                             style: const TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: SmartRefresher(
  //               controller: _refreshController, // تحكم التحديث
  //               onRefresh: _onRefresh, // دالة التحديث عند السحب
  //               header: WaterDropHeader(
  //                 waterDropColor: Colors.tealAccent.shade400,
  //                 idleIcon: Icon(
  //                   Icons.refresh,
  //                   size: 20,
  //                   color: Colors.tealAccent.shade700,
  //                 ),
  //                 refresh: SizedBox(
  //                   width: 24,
  //                   height: 24,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 3,
  //                     valueColor: AlwaysStoppedAnimation(Colors.tealAccent.shade700),
  //                   ),
  //                 ),
  //                 complete: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
  //                     SizedBox(width: 8),
  //                     Text(
  //                       'تم التحديث',
  //                       style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 completeDuration: Duration(milliseconds: 1000),
  //               ),
  //               child: _isLoading && _orders.isEmpty
  //                   ? Center(
  //                 child: CircularProgressIndicator(
  //                   color: isDarkMode ? Colors.white : Colors.blue,
  //                 ),
  //               )
  //                   : filteredOrders.isNotEmpty // التحقق من وجود نتائج
  //                   ? LiveList(
  //                 padding: const EdgeInsets.all(16.0),
  //                 itemCount: filteredOrders.length,
  //                 itemBuilder: (context, index, animation) {
  //                   final order = filteredOrders[index];
  //                   return FadeTransition(
  //                     opacity: animation,
  //                     child: Dismissible(
  //                       key: ValueKey('${order['request_id']}_$index'), // مفتاح فريد محسن
  //                       direction: DismissDirection.startToEnd,
  //                       background: Container(
  //                         alignment: Alignment.centerLeft,
  //                         padding: const EdgeInsets.symmetric(horizontal: 20),
  //                         decoration: BoxDecoration(
  //                           color: Colors.red,
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: const Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             HugeIcon(
  //                                 icon: HugeIcons.strokeRoundedDelete03,
  //                                 color: Colors.white,
  //                                 size: 28),
  //                             SizedBox(width: 10),
  //                             HugeIcon(
  //                                 icon: HugeIcons.strokeRoundedSwipeLeft01,
  //                                 color: Colors.white,
  //                                 size: 28),
  //                           ],
  //                         ),
  //                       ),
  //                       confirmDismiss: (direction) async {
  //                         // إضافة تأكيد قبل الحذف
  //                         return await _showDeleteConfirmationDialog(context);
  //                       },
  //                       onDismissed: (direction) async {
  //                         final requestId = order['request_id'];
  //                         if (requestId != null) {
  //                           // حذف العنصر من القائمة المحلية أولاً
  //                           if (mounted && !_isDisposed) {
  //                             setState(() {
  //                               _orders.removeWhere((item) => item['request_id'] == requestId);
  //                             });
  //                           }
  //                           // ثم حذفه من قاعدة البيانات
  //                           await _deleteOrderFromDatabase(requestId);
  //                         } else {
  //                           _showSnackbar('خطأ', 'معرف الطلب غير موجود', SnackBarType.fail);
  //                         }
  //                       },
  //                       child: _buildOrderItem(
  //                         context,
  //                         order['vehicles']?['models']?['name'] ?? 'غير محدد',
  //                         order['vehicles']?['year']?.toString() ?? 'غير محدد',
  //                         order['request_type'] ?? 'غير محدد',
  //                         order['service_provider'] ?? 'غير محدد',
  //                         order['problem_description'] ?? 'غير محدد',
  //                         order['created_at'],
  //                         order['status_id']?.toString() ?? '0',
  //                         isDarkMode,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               )
  //                   : Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Image.asset(
  //                       isDarkMode
  //                           ? 'assets/images/no_results_white.png'
  //                           : 'assets/images/no_results.png',
  //                       height: 150,
  //                     ), // صورة عند عدم العثور على نتائج
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       'لا توجد اي طلبات',
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           color: isDarkMode ? Colors.white70 : Colors.grey[600]
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // دالة لحذف الطلب من قاعدة البيانات فقط (محسنة)
  Future<void> _deleteOrderFromDatabase(int requestId) async {
    try {
      await Supabase.instance.client
          .from('maintenance_requests')
          .delete()
          .eq('request_id', requestId);

      if (mounted && !_isDisposed) {
        _showSnackbar('نجاح', 'تم حذف الطلب بنجاح', SnackBarType.success);
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        _showSnackbar('خطأ', 'حدث خطأ أثناء حذف الطلب', SnackBarType.fail);
        // إعادة تحميل البيانات في حالة الفشل
        _fetchOrders();
      }
    }
  }

  // دالة لعرض نافذة تأكيد الحذف (محسنة)
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
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
                  color: Colors.red.withValues(alpha: 0.1), // خلفية دائرية حمراء
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'حذف الطلب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل أنت متأكد أنك تريد حذف هذا الطلب؟ هذه العملية لا يمكن التراجع عنها.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // إلغاء
                    style: TextButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true), // تأكيد
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'حذف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // إرجاع القيمة
  }

  // دالة لعرض Snackbar (محسنة)
  void _showSnackbar(String title, String message, SnackBarType type) {
    if (!mounted || _isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        IconSnackBar.show(
          context,
          snackBarType: type,
          label: message,
          backgroundColor: type == SnackBarType.fail ? Colors.red : Colors.green,
        );
      }
    });
  }


  // دالة لإنشاء عنصر واجهة مستخدم يمثل طلبًا معينًا (محسنة)
  Widget _buildOrderItem(
      BuildContext context,
      String modelName, // اسم النموذج
      String vehicleYear, // سنة السيارة
      String requestType, // نوع الطلب
      String serviceProvider,
      String problemDes, // وصف المشكلة
      String createdAt, // تاريخ الإنشاء
      String statusId,
      bool isDarkMode) {
    // معرف الحالة

    // تنسيق التاريخ مع معالجة الأخطاء
    String formattedDate;
    try {
      final dateFormat = DateFormat('d-M-yyyy');
      formattedDate = dateFormat.format(DateTime.parse(createdAt));
    } catch (e) {
      formattedDate = 'تاريخ غير صحيح';
    }

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              child: Text(
                modelName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($vehicleYear)',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '-',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Text(
                requestType,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: _buildStatusButton(statusId, isDarkMode),
        onTap: () => _showOrderDetails(
            context,
            modelName,
            requestType,
            serviceProvider,
            problemDes,
            formattedDate,
            _getStatusColor(statusId),
            isDarkMode),
      ),
    );
  }

  // دالة لإنشاء زر الحالة (محسنة)
  Widget _buildStatusButton(String statusId, bool isDarkMode) {
    String statusText = _getStatusText(int.tryParse(statusId) ?? 0);
    Color statusColor = _getStatusColor(statusId);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // دالة لعرض تفاصيل الطلب (محسنة)
  void _showOrderDetails(BuildContext context, String modelName,
      String requestType, String serviceProvider, String problemDes, String date, Color statusColor, bool isDarkMode) {

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              children: [
                Icon(
                  Ionicons.information_circle,
                  size: 40,
                  color: Color(0xFF00A8A8),
                ),
                SizedBox(height: 8),
                Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF333333),
                  ),
                ),
              ],
            ),
            content: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('الموديل', modelName, Ionicons.car_sport_outline,
                        const Color(0xFF00A8A8), isDarkMode),
                    const SizedBox(height: 16),
                    _buildDetailRow('نوع الطلب', requestType,
                        HugeIcons.strokeRoundedGitPullRequestDraft, Colors.grey, isDarkMode),
                    const SizedBox(height: 16),
                    _buildDetailRow('مزود الخدمة', serviceProvider,
                        HugeIcons.strokeRoundedAiSetting, Color(0xFF3D9B9C), isDarkMode),
                    const SizedBox(height: 16),
                    _buildDetailRow('وصف المشكلة', problemDes,
                        HugeIcons.strokeRoundedInformationCircle, statusColor, isDarkMode,
                        isProblem: true),
                    const SizedBox(height: 16),
                    _buildDetailRow('التاريخ', date, HugeIcons.strokeRoundedCalendar01,
                        const Color(0xFF00A8A8), isDarkMode),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: const Color(0xFFf66e70).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة لإنشاء صف تفاصيل الطلب (محسنة)
  Widget _buildDetailRow(String label, String value, IconData icon, Color color, bool isDarkMode,
      {bool isProblem = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? color.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: isProblem ? TextOverflow.visible : TextOverflow.ellipsis,
                  maxLines: isProblem ? null : 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة للحصول على لون الحالة (محسنة)
  Color _getStatusColor(String statusId) {
    switch (statusId) {
      case '7': // قيد المراجعة
        return const Color(0xFFFFB74D);
      case '3': // قيد التنفيذ
        return Colors.orange;
      case '4': // مكتملة
        return Colors.green;
      case '6': // مرفوضة
        return Colors.red;
      case 'الكل':
        return const Color(0xFF00A8A8);
      case 'قيد المراجعة':
        return const Color(0xFFFFB74D);
      case 'قيد التنفيذ':
        return Colors.orange;
      case 'مكتملة':
        return Colors.green;
      case 'مرفوضة':
        return Colors.red;
      default:
        return const Color(0xFF00A8A8); // لون افتراضي
    }
  }

  // دالة للحصول على نص الحالة (محسنة)
  String _getStatusText(int statusId) {
    switch (statusId) {
      case 3:
        return 'قيد التنفيذ';
      case 4:
        return 'مكتملة';
      case 6:
        return 'مرفوضة';
      case 7:
        return 'قيد المراجعة';
      default:
        return 'غير محدد';
    }
  }

  // دالة لعرض نافذة الفلترة (محسنة)
  void _showFilterDialog(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Dialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر حالة الطلب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(context, 'الكل', Icons.all_inclusive,
                      const Color(0xFF00A8A8), isDarkMode),
                  const SizedBox(height: 10),
                  _buildFilterOption(context, 'قيد المراجعة',
                      HugeIcons.strokeRoundedClock01, Color(0xFFFFB74D), isDarkMode),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'قيد التنفيذ', Icons.timelapse, Colors.orange, isDarkMode),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'مكتملة', Icons.check_circle, Colors.green, isDarkMode),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'مرفوضة', Icons.cancel, Colors.red, isDarkMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // دالة لإنشاء خيار الفلترة (محسنة)
  Widget _buildFilterOption(
      BuildContext context, String status, IconData icon, Color color, bool isDarkMode) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        if (mounted && !_isDisposed) {
          setState(() {
            _selectedStatus = status; // تحديث الحالة المحددة
          });
        }
        Navigator.pop(context); // إغلاق النافذة
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : (isDarkMode ? Colors.white : Color(0xFF333333)),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

