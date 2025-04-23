import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async'; // استيراد مكتبة async
import 'package:access_address_app/widgets/buildHeader.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // استيراد حزمة intl لتنسيق التاريخ
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart'; // استيراد حزمة snackbar
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'; // استيراد مكتبة السحب للتحديث

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

  @override
  void initState() {
    super.initState();
    userID =
        widget.userData?['user_id'] ?? 0; // تعيين قيمة افتراضية إذا كانت null
    _fetchOrders(); // جلب الطلبات عند بدء الشاشة

    // إعداد المؤقت لتحديث الطلبات كل 30 ثانية
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchOrders();
    });
  }

  // دالة لجلب الطلبات من قاعدة البيانات
  Future<void> _fetchOrders() async {
    final response = await Supabase.instance.client
        .from('maintenance_requests')
        .select(
            '*, vehicles(model_id, models(name), year), request_status(*, status_name), problem_description,request_id,service_provider') // استرجاع البيانات من الجداول المرتبطة
        .eq('user_id', userID).order('created_at', ascending: false); // ترتيب حسب تاريخ الطلب;

    if (response.isNotEmpty) {
      setState(() {
        _orders =
            List<Map<String, dynamic>>.from(response); // تحديث قائمة الطلبات
      });
    } else {
      // التعامل مع الخطأ
      print('Error fetching orders: ${response}');
    }
  }

  // دالة لتحديث البيانات عند السحب للأسفل
  Future<void> _onRefresh() async {
    await _fetchOrders(); // تحديث البيانات
    _refreshController.refreshCompleted(); // إكمال عملية التحديث
  }

  @override
  void dispose() {
    _timer?.cancel(); // إلغاء المؤقت
    _refreshController.dispose(); // إلغاء تحكم التحديث
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    // تصفية الطلبات بناءً على البحث والفلترة
    final filteredOrders = _orders.where((order) {
      final modelName = order['vehicles']['models']['name']?.toLowerCase() ??
          'غير محدد'; // استخدام اسم الموديل
      final vehicleYear = order['vehicles']['year']?.toString().toLowerCase() ??
          ''; // استخدام سنة الصنع مع التحقق من null
      final statusId = order['status_id']?.toString() ??
          '0'; // تعيين قيمة افتراضية إذا كانت null
      final matchesSearch = modelName.contains(_searchQuery.toLowerCase()) ||
          vehicleYear.contains(
              _searchQuery.toLowerCase()); // البحث غير حساس لحالة الأحرف
      final matchesStatus = _selectedStatus == 'الكل' ||
          _getStatusText(int.tryParse(statusId) ?? 0) ==
              _selectedStatus; // استخدام tryParse مع قيمة افتراضية
      return matchesSearch && matchesStatus; // إرجاع النتيجة النهائية
    }).toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl, // تعيين اتجاه النص
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            buildHeader(
                size, 'طلباتي', 'هنا يمكنك عرض طلباتك السابقة',userID), // رأس الشاشة
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // شريط البحث
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value; // تحديث استعلام البحث
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث عن طلب...',
                          prefixIcon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch02,
                              color: Colors.grey),
                          suffixIcon: _searchQuery
                                  .isNotEmpty // زر "X" لمسح النص
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = ''; // مسح النص
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // زر الفلترة
                  GestureDetector(
                    onTap: () {
                      _showFilterDialog(context); // عرض نافذة الفلترة
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_selectedStatus),
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
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedFilter,
                              color: Colors.white,
                              size:24),
                          const SizedBox(width: 8),
                          Text(
                            _selectedStatus,
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
              child: SmartRefresher(
                controller: _refreshController, // تحكم التحديث
                onRefresh: _onRefresh, // دالة التحديث عند السحب
                child: filteredOrders.isNotEmpty // التحقق من وجود نتائج
                    ? LiveList(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index, animation) {
                    final order = filteredOrders[index];
                    return FadeTransition(
                      opacity: animation,
                      child: Dismissible(
                        key: ValueKey(order['request_id']?.toString() ?? '0'),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
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
                        onDismissed: (direction) async {
                          final requestId = order['request_id'];
                          if (requestId != null) {
                            await _deleteOrder(requestId);
                            setState(() {
                              _orders.removeAt(index);
                            });
                          } else {
                            _showSnackbar('خطأ', 'معرف الطلب غير موجود', SnackBarType.fail);
                          }
                        },
                        child: _buildOrderItem(
                          context,
                          order['vehicles']['models']['name'] ?? 'غير محدد',
                          order['vehicles']['year']?.toString() ?? 'غير محدد',
                          order['request_type'] ?? 'غير محدد',
                          order['service_provider'] ?? 'غير محدد',
                          order['problem_description'] ?? 'غير محدد',
                          order['created_at'],
                          order['status_id']?.toString() ?? '0',
                        ),
                      ),
                    );
                  },
                )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/no_results.png',
                                height: 100,color: isDarkMode ? Colors.grey[700] : null), // صورة عند عدم العثور على نتائج
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد اي طلبات',
                              style:
                                  TextStyle(fontSize: 18, color: theme.textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لحذف الطلب
  Future<void> _deleteOrder(int requestId) async {
    // عرض نافذة تحقق قبل الحذف
    final shouldDelete = await _showDeleteConfirmationDialog(context);
    if (shouldDelete) {
      try {
        final response = await Supabase.instance.client
            .from('maintenance_requests')
            .delete()
            .eq('request_id', requestId);

        if (response == null) {
          _showSnackbar('نجاح', 'تم حذف الطلب بنجاح', SnackBarType.success);
        } else {
          _showSnackbar('فشل', 'فشل في حذف الطلب', SnackBarType.fail);
        }
      } catch (e) {
        print('Error deleting order: $e');
        _showSnackbar('خطأ', 'حدث خطأ أثناء حذف الطلب', SnackBarType.fail);
      }
    }
  }

  // دالة لعرض نافذة تأكيد الحذف
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) {
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
                'حذف الطلب',
                style: TextStyle(
                  fontSize: 18, // حجم خط أصغر
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هل أنت متأكد أنك تريد حذف هذا الطلب؟ هذه العملية لا يمكن التراجع عنها.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14, // حجم خط أصغر
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: 100, // عرض زر الإلغاء
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false), // إلغاء
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
                onPressed: () => Navigator.of(context).pop(true), // تأكيد
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
    ).then((value) => value ?? false); // إرجاع القيمة
  }

  // دالة لعرض Snackbar
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

  // دالة لإنشاء عنصر واجهة مستخدم يمثل طلبًا معينًا
  Widget _buildOrderItem(
      BuildContext context,
      String modelName, // اسم النموذج
      String vehicleYear, // سنة السيارة
      String requestType, // نوع الطلب
      String serviceProvider,
      String problemDes, // وصف المشكلة
      String createdAt, // تاريخ الإنشاء
      String statusId) {
    // معرف الحالة

    // تنسيق التاريخ
    final dateFormat = DateFormat('d-M-yyyy'); // صيغة التاريخ المطلوبة
    final formattedDate = dateFormat
        .format(DateTime.parse(createdAt)); // تحويل التاريخ إلى الصيغة المطلوبة


    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // إضافة مسافة أسفل العنصر
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white, // لون الخلفية
        borderRadius: BorderRadius.circular(12), // زوايا مدورة
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1), // لون الظل
            blurRadius: 8, // درجة تشتت الظل
            offset: const Offset(0, 4), // موضع الظل
          ),
        ],
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              modelName, // عرض اسم النموذج
              style: const TextStyle(fontWeight: FontWeight.bold), // نمط النص
            ),
            const SizedBox(width: 8), // إضافة مسافة بين العناصر
            Text(
              '($vehicleYear)', // عرض سنة الصنع بلون رمادي
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start, // توزيع العناصر
          children: [
            Text(formattedDate), // عرض التاريخ المنسق
            SizedBox(
              width: 25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('-'),
              ),
            ),
            Text(
              requestType, // عرض نوع الطلب
              style: const TextStyle(
                  color: Colors.grey), // عرض نوع الطلب بلون رمادي
            ),
          ],
        ),
        trailing: _buildStatusButton(statusId), // استخدام دالة لإنشاء زر الحالة
        onTap: () => _showOrderDetails(
            context,
            modelName,
            requestType,
            serviceProvider,
            problemDes,
            formattedDate,
            _getStatusColor(statusId)), // عند الضغط على العنصر
      ),
    );
  }

  // دالة لإنشاء زر الحالة
  Widget _buildStatusButton(String statusId) {
    String statusText =
        _getStatusText(int.parse(statusId)); // الحصول على نص الحالة
    Color statusColor = _getStatusColor(statusId); // الحصول على لون الحالة

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 12, vertical: 12), // إضافة حشوة داخل الزر
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha:0.3), // لون الزر
        borderRadius: BorderRadius.circular(8), // زوايا مدورة
      ),
      child: Text(
        statusText, // عرض نص الحالة
        style: TextStyle(
          color: statusColor, // لون النص
          fontWeight: FontWeight.w900, // نمط النص
        ),
      ),
    );
  }

  // دالة لعرض تفاصيل الطلب
  void _showOrderDetails(BuildContext context, String modelName,
      String requestType,String serviceProvider, String problemDes, String date, Color statusColor) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );
    // final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeIn,
              ),
            ),
            child: AlertDialog(
              backgroundColor: theme.dialogBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding: const EdgeInsets.all(20),
              title: const Column(
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
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // عرض النافذة المنبثقة
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('الموديل', modelName, Ionicons.car_sport_outline,
                        const Color(0xFF00A8A8)),
                    const SizedBox(height: 16),
                    _buildDetailRow('نوع الطلب', requestType,
                        HugeIcons.strokeRoundedGitPullRequestDraft, Colors.grey),  const SizedBox(height: 16),
                    _buildDetailRow('مزود الخدمة', serviceProvider,
                        HugeIcons.strokeRoundedAiSetting, Color(0xFF3D9B9C)),
                    const SizedBox(height: 16),
                    _buildDetailRow('وصف المشكلة', problemDes,
                        HugeIcons.strokeRoundedInformationCircle, statusColor,
                        isProblem: true),
                    const SizedBox(height: 16),
                    _buildDetailRow('التاريخ', date, HugeIcons.strokeRoundedCalendar01,
                        const Color(0xFF00A8A8)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.reverse().then((_) {
                      Navigator.of(context)
                          .pop(); // إغلاق النافذة بعد الانتهاء من التلاشي
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: const Color(0xFFf66e70).withValues(alpha:0.5),
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
          ),
        );
      },
    );

    controller.forward(); // بدء الأنيميشن عند فتح النافذة
  }

  // دالة لإنشاء صف تفاصيل الطلب
  Widget _buildDetailRow(String label, String value, IconData icon, Color color,
      {bool isProblem = false})
  {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    // final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? color.withValues(alpha: 0.2)
            : color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                // استخدام Text مع overflow
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: isProblem
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible, // تقليص النص إذا كان كبيرًا
                  maxLines: isProblem ? 5 : 1, // تحديد عدد الأسطر
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة للحصول على لون الحالة
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
      default:
        return const Color(0xC700A8A8); // لون افتراضي
    }
  }

  // دالة للحصول على نص الحالة
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

  // دالة لعرض نافذة الفلترة
  void _showFilterDialog(BuildContext context) {
    // final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Dialog(
            backgroundColor: theme.dialogBackgroundColor,
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
                    'اختر حالة الطلب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(context, 'الكل', Icons.all_inclusive,
                      const Color(0xFF00A8A8)),
                  const SizedBox(height: 10),
                  _buildFilterOption(context, 'قيد المراجعة',
                      HugeIcons.strokeRoundedClock01, Color(0xFFFFB74D)),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'قيد التنفيذ', Icons.timelapse, Colors.orange),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'مكتملة', Icons.check_circle, Colors.green),
                  const SizedBox(height: 10),
                  _buildFilterOption(
                      context, 'مرفوضة', Icons.cancel, Colors.red),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // دالة لإنشاء خيار الفلترة
  Widget _buildFilterOption(
      BuildContext context, String status, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status; // تحديث الحالة المحددة
        });
        Navigator.pop(context); // إغلاق نافذة الفلترة
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
