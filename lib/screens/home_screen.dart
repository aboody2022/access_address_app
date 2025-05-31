// import 'dart:async';
// import 'dart:ui' as ui;
//
// import 'package:auto_animated/auto_animated.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
// import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
// import 'package:provider/provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:adaptive_theme/adaptive_theme.dart';
//
// import '../features/auth/home_model.dart';
// import '../widgets/new_request.dart';
// import '../widgets/notification_button.dart';
// import '../widgets/show_custom_snackbar.dart';
//
//
// class HomeScreen extends StatefulWidget {
//   final Map<String, dynamic>? userData;
//
//   const HomeScreen({super.key, this.userData});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late ScrollController _scrollController;
//   bool _isScrolled = false;
//   late int userID;
//   late StreamSubscription<List<ConnectivityResult>> _subscription;
//   bool _isOffline = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     monitorInternetConnection();
//     userID = widget.userData?['user_id'];
//
//     final homeModel = Provider.of<HomeModel>(context, listen: false);
//     homeModel.fetchOrders(userID);
//     homeModel.fetchVehicles(userID);
//
//     _scrollController.addListener(() {
//       if (_scrollController.offset > 50 && !_isScrolled) {
//         setState(() {
//           _isScrolled = true;
//         });
//       } else if (_scrollController.offset <= 50 && _isScrolled) {
//         setState(() {
//           _isScrolled = false;
//         });
//       }
//     });
//   }
//
//   void monitorInternetConnection() {
//     _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
//       bool isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
//
//       if (!isConnected) {
//         if (!_isOffline) {
//           setState(() {
//             _isOffline = true;
//           });
//           showCustomSnackbar(context, "⚠️ لا يوجد اتصال بالإنترنت", SnackBarType.alert);
//         }
//       } else {
//         if (_isOffline) {
//           setState(() {
//             _isOffline = false;
//           });
//           showCustomSnackbar(context, "✅ تمت استعادة الاتصال بالإنترنت", SnackBarType.success);
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   String formatDate(String dateString) {
//     DateTime dateTime = DateTime.parse(dateString);
//     return DateFormat('d-M-yyyy').format(dateTime);
//   }
//
//   Widget buildSkeletonLine(double width, double height, {BorderRadius? borderRadius}) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     return Skeleton(
//       isLoading: true,
//       skeleton: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           borderRadius: borderRadius ?? BorderRadius.circular(8),
//           color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
//         ),
//       ),
//       child: SizedBox(
//         width: width,
//         height: height,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     final theme = Theme.of(context);
//     String fullName = widget.userData?['full_name'] ?? 'مستخدم';
//     String firstName = fullName.split(' ').first;
//     String displayName = '$firstName...';
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         body: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             SliverAppBar(
//               automaticallyImplyLeading: false,
//               centerTitle: true,
//               toolbarHeight: size.height * 0.1,
//               title: Padding(
//                 padding: EdgeInsets.only(top: size.height * 0.01),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // استبدال Container الأول بزر الإشعارات
//                       NotificationButton(
//                         isDarkMode: isDarkMode,
//                         userId: userID,
//                       ),
//                       // الشعار يبقى كما هو
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha:0.05),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.all(10),
//                         child: Image.asset(
//                           'assets/images/logo_white.png',
//                           height: size.height * 0.035,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               backgroundColor: _isScrolled
//                   ? isDarkMode
//                   ? const Color(0xFF1E1E1E)
//                   : const Color(0xFF3CD3AD)
//                   : Colors.transparent,
//               elevation: _isScrolled ? (isDarkMode ? 8 : 4) : 0,
//               pinned: true,
//               expandedHeight: size.height * 0.23,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isDarkMode
//                           ? [
//                         const Color(0xFF2C2C2C),
//                         const Color(0xFF1E1E1E),
//                       ]
//                           : [
//                         const Color(0xFF4CB8C4),
//                         const Color(0xFF3CD3AD),
//                       ],
//                       begin: Alignment.topRight,
//                       end: Alignment.bottomLeft,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: !_isScrolled
//                       ? Padding(
//                     padding: EdgeInsets.only(
//                       top: size.height * 0.12,
//                       right: size.width * 0.05,
//                       left: size.width * 0.05,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'مرحباً، $displayName',
//                           style: TextStyle(
//                             fontSize: size.width * 0.05,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.01),
//                         Text(
//                           'تحتاج أي مساعدة اليوم؟',
//                           style: TextStyle(
//                             fontSize: size.width * 0.04,
//                             color: Colors.white.withValues(alpha:0.9),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                       : null,
//                 ),
//               ),
//               systemOverlayStyle: SystemUiOverlayStyle(
//                 statusBarColor: Colors.transparent,
//                 statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//               sliver: Consumer<HomeModel>(
//                 builder: (context, homeModel, child) {
//                   return SliverList(
//                     delegate: SliverChildListDelegate([
//                       SizedBox(height: size.height * 0.03),
//                       _buildCreateRequestButton(size, homeModel),
//                       SizedBox(height: size.height * 0.03),
//                       _buildSectionTitle('طلباتي', onMorePressed: () {
//                         // التنقل إلى شاشة الطلبات
//                       }),
//                       SizedBox(height: size.height * 0.02),
//                       homeModel.isOrdersLoading ? _buildSkeletonOrderList(size) : _buildAnimatedRequestList(size, homeModel),
//                       SizedBox(height: size.height * 0.03),
//                       _buildSectionTitle('مركباتي', onMorePressed: () {
//                         // التنقل إلى شاشة المركبات
//                       }),
//                       SizedBox(height: size.height * 0.02),
//                       homeModel.isVehiclesLoading ? _buildSkeletonVehicleList(size) : _buildAnimatedVehicleList(size, homeModel),
//                     ]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCreateRequestButton(Size size, HomeModel homeModel) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: () async {
//         final result = await showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(20),
//             ),
//           ),
//           builder: (context) => NewRequestModal(
//             isDarkMode: isDarkMode,
//             userData: widget.userData,
//           ),
//         );
//
//         if (result != null) {
//           print('Request Data: $result');
//           // تحديث البيانات بعد إضافة الطلب
//           await homeModel.fetchOrders(userID);
//           await homeModel.fetchVehicles(userID);
//         }
//       },
//       child: Container(
//         height: size.height * 0.15,
//         padding: EdgeInsets.all(size.width * 0.04),
//         decoration: BoxDecoration(
//           color: isDarkMode ? theme.cardColor : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: isDarkMode ? Colors.black.withValues(alpha:0.3) : Color(0xFF3CD3AD).withValues(alpha:0.3),
//               blurRadius: 5,
//               spreadRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//             BoxShadow(
//               color: Colors.grey.withValues(alpha:0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) {
//                 return const LinearGradient(
//                   colors: [
//                     Color(0xFF4CB8C4),
//                     Color(0xFF3CD3AD),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ).createShader(bounds);
//               },
//               blendMode: BlendMode.srcIn,
//               child: const Text(
//                 'إنشاء طلب جديد',
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ShaderMask(
//               shaderCallback: (Rect bounds) {
//                 return const LinearGradient(
//                   colors: [
//                     Color(0xFF4CB8C4),
//                     Color(0xFF3CD3AD),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ).createShader(bounds);
//               },
//               blendMode: BlendMode.srcIn,
//               child: Image.asset(
//                 'assets/images/repair.png',
//                 width: size.width * 0.3,
//                 height: size.height * 0.1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, {required VoidCallback onMorePressed}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF4B4B4B),
//           ),
//         ),
//         GestureDetector(
//           onTap: onMorePressed,
//           child: const Text(
//             'المزيد',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white54,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAnimatedRequestList(Size size, HomeModel homeModel) {
//     if (homeModel.orders.isEmpty) {
//       return _buildNoDataMessage('لا توجد طلبات', size,'طلب');
//     }
//
//     return LiveList(
//       showItemInterval: const Duration(milliseconds: 100),
//       showItemDuration: const Duration(milliseconds: 500),
//       reAnimateOnVisibility: true,
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: homeModel.orders.length,
//       itemBuilder: (context, index, animation) {
//         final order = homeModel.orders[index];
//         final vehicle = order['vehicles'];
//         final status = order['request_status']['status_name'];
//         final modelName = vehicle != null ? vehicle['models']['name'] : 'غير متوفر';
//         final year = vehicle != null ? vehicle['year']?.toString() : 'غير متوفر';
//         final problemDescription = order['problem_description'] ?? 'لا توجد تفاصيل';
//         final formattedDate = formatDate(order['created_at']);
//
//         Color statusColor;
//         switch (status) {
//           case 'مكتملة':
//             statusColor = Colors.green;
//             break;
//           case 'مرفوضة':
//             statusColor = Colors.red;
//             break;
//           case 'قيد المراجعة':
//             statusColor = const Color(0xFFFFB74D);
//             break;
//           case 'قيد التنفيذ':
//             statusColor = Colors.orange;
//             break;
//           default:
//             statusColor = Colors.grey;
//         }
//
//         return FadeTransition(
//           opacity: animation,
//           child: _buildRequestItem(
//             '$modelName $year',
//             status,
//             formattedDate,
//             statusColor,
//             size,
//             problemDescription,
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildRequestItem(String car, String status, String date, Color color, Size size, String problemDescription) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     final theme = Theme.of(context);
//     return Container(
//       margin: EdgeInsets.only(bottom: size.height * 0.02),
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: isDarkMode ? theme.cardColor : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode ? Colors.black.withValues(alpha:0.3) : Colors.grey.withValues(alpha:0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   car,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: theme.textTheme.bodyLarge?.color,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.03,
//                   vertical: size.height * 0.01,
//                 ),
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha:0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             'تفاصيل المشكلة: $problemDescription',
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             date,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimatedVehicleList(Size size, HomeModel homeModel) {
//     if (homeModel.vehicles.isEmpty) {
//       return _buildNoDataMessage('لا توجد مركبات', size,'مركبة');
//     }
//
//     return LiveList(
//       showItemInterval: const Duration(milliseconds: 150),
//       showItemDuration: const Duration(milliseconds: 300),
//       reAnimateOnVisibility: true,
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: homeModel.vehicles.length,
//       itemBuilder: (context, index, animation) {
//         final vehicle = homeModel.vehicles[index];
//         final modelName = vehicle['models'] != null ? vehicle['models']['name'] : 'غير متوفر';
//         final manufacturerName = vehicle['manufacturers'] != null ? vehicle['manufacturers']['name'] : 'غير متوفر';
//         final year = vehicle['year']?.toString() ?? 'غير متوفر';
//
//         return FadeTransition(
//           opacity: animation,
//           child: _buildVehicleItem(
//             '$modelName $year',
//             manufacturerName,
//             size,
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildVehicleItem(String modelAndYear, String brand, Size size) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//     final theme = Theme.of(context);
//     return Container(
//       margin: EdgeInsets.only(bottom: size.height * 0.02),
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: isDarkMode ? theme.cardColor : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode ? Colors.black.withValues(alpha:0.3) : Colors.grey.withValues(alpha:0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   modelAndYear,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: theme.textTheme.bodyLarge?.color,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   brand,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Image.asset(
//             'assets/images/car.png',
//             height: size.height * 0.08,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoDataMessage(String message, Size size,String word) {
//     final theme = Theme.of(context);
//     return Column(
//       children: [
//         Text(
//           message,
//           style: TextStyle(fontSize: 16, color: theme.textTheme.bodySmall?.color),
//         ),
//         SizedBox(height: size.height * 0.02),
//         ElevatedButton(
//           onPressed: () {
//             // التنقل إلى شاشة إضافة طلب أو مركبة
//
//           },
//           child: Text('قم بإضافة ${word} '),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSkeletonOrderList(Size size) {
//     return Column(
//       children: List.generate(3, (index) => _buildSkeletonOrderItem(size)),
//     );
//   }
//
//   Widget _buildSkeletonOrderItem(Size size) {
//     return Container(
//       margin: EdgeInsets.only(bottom: size.height * 0.02),
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha:0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               buildSkeletonLine(size.width * 0.4, 16, borderRadius: BorderRadius.circular(8)),
//               buildSkeletonLine(size.width * 0.2, 16, borderRadius: BorderRadius.circular(8)),
//             ],
//           ),
//           SizedBox(height: size.height * 0.01),
//           buildSkeletonLine(size.width * 0.6, 14, borderRadius: BorderRadius.circular(8)),
//           SizedBox(height: size.height * 0.01),
//           buildSkeletonLine(size.width * 0.3, 14, borderRadius: BorderRadius.circular(8)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSkeletonVehicleList(Size size) {
//     return Column(
//       children: List.generate(3, (index) => _buildSkeletonVehicleItem(size)),
//     );
//   }
//
//   Widget _buildSkeletonVehicleItem(Size size) {
//     return Container(
//       margin: EdgeInsets.only(bottom: size.height * 0.02),
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha:0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 buildSkeletonLine(size.width * 0.4, 16, borderRadius: BorderRadius.circular(8)),
//                 SizedBox(height: size.height * 0.01),
//                 buildSkeletonLine(size.width * 0.3, 14, borderRadius: BorderRadius.circular(8)),
//               ],
//             ),
//           ),
//           buildSkeletonLine(size.width * 0.2, size.height * 0.08, borderRadius: BorderRadius.circular(8)),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

// --- تأكد من صحة المسارات لهذه الملفات في مشروعك ---
import '../features/auth/home_model.dart';
import '../widgets/new_request.dart';
import '../widgets/notification_button.dart';
import '../widgets/show_custom_snackbar.dart';
import 'add_vehicle_screen.dart'; // <<< استيراد شاشة إضافة مركبة (يجب أن تكون موجودة)
// ----------------------------------------------------

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;
  late int userID;
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    monitorInternetConnection();
    userID = widget.userData?['user_id'] ?? 0;

    if (userID != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final homeModel = Provider.of<HomeModel>(context, listen: false);
          homeModel.fetchOrders(userID);
          homeModel.fetchVehicles(userID);
        }
      });
    }

    _scrollController.addListener(() {
      if (!mounted) return;
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  void monitorInternetConnection() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!mounted) return;
      bool isConnected = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (!isConnected) {
        if (!_isOffline) {
          setState(() {
            _isOffline = true;
          });
          if (mounted) {
            showCustomSnackbar(
                context, "⚠️ لا يوجد اتصال بالإنترنت", SnackBarType.alert);
          }
        }
      } else {
        if (_isOffline) {
          setState(() {
            _isOffline = false;
          });
          if (mounted) {
            showCustomSnackbar(context, "✅ تمت استعادة الاتصال بالإنترنت",
                SnackBarType.success);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('d-M-yyyy').format(dateTime);
    } catch (e) {
      print("Error parsing date: $dateString - $e");
      return "تاريخ غير صالح";
    }
  }

  Widget buildSkeletonLine(double width, double height,
      {BorderRadius? borderRadius}) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Skeleton(
      isLoading: true,
      skeleton: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        ),
      ),
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    String fullName = widget.userData?['full_name'] ?? 'مستخدم';
    String firstName = fullName.split(' ').first;
    String displayName = '$firstName...';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              toolbarHeight: size.height * 0.1,
              title: Padding(
                padding: EdgeInsets.only(top: size.height * 0.01),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NotificationButton(
                        isDarkMode: isDarkMode,
                        userId: userID,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/logo_white.png',
                          height: size.height * 0.035,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: _isScrolled
                  ? isDarkMode
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFF3CD3AD)
                  : Colors.transparent,
              elevation: _isScrolled ? (isDarkMode ? 8 : 4) : 0,
              pinned: true,
              expandedHeight: size.height * 0.23,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [
                              const Color(0xFF2C2C2C),
                              const Color(0xFF1E1E1E),
                            ]
                          : [
                              const Color(0xFF4CB8C4),
                              const Color(0xFF3CD3AD),
                            ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: !_isScrolled
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: size.height * 0.12,
                            right: size.width * 0.05,
                            left: size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً، $displayName',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                'تحتاج أي مساعدة اليوم؟',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.white.withValues(alpha:0.9),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDarkMode ? Brightness.light : Brightness.dark,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              sliver: Consumer<HomeModel>(
                builder: (context, homeModel, child) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: size.height * 0.03),
                      _buildCreateRequestButton(size, homeModel),
                      SizedBox(height: size.height * 0.03),
                      _buildSectionTitle('طلباتي', onMorePressed: () {
                        // TODO: Implement navigation to Orders Screen
                      }),
                      SizedBox(height: size.height * 0.02),
                      homeModel.isOrdersLoading
                          ? _buildSkeletonOrderList(size)
                          : _buildAnimatedRequestList(size, homeModel),
                      SizedBox(height: size.height * 0.03),
                      _buildSectionTitle('مركباتي', onMorePressed: () {
                        // TODO: Implement navigation to Vehicles Screen
                      }),
                      SizedBox(height: size.height * 0.02),
                      homeModel.isVehiclesLoading
                          ? _buildSkeletonVehicleList(size)
                          : _buildAnimatedVehicleList(size, homeModel),
                      SizedBox(height: size.height * 0.02),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRequestButton(Size size, HomeModel homeModel) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    final buttonGradient = LinearGradient(
      colors: isDarkMode
          ? [theme.colorScheme.primary, theme.colorScheme.secondary]
          : [const Color(0xFF4CB8C4), const Color(0xFF3CD3AD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: theme.cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) => NewRequestModal(
            isDarkMode: isDarkMode,
            userData: widget.userData,
          ),
        );

        if (result != null) {
          print('Request Data: $result');
          if (userID != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                homeModel.fetchOrders(userID);
                homeModel.fetchVehicles(userID);
              }
            });
          }
        }
      },
      child: Container(
        height: size.height * 0.15,
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha:isDarkMode ? 0.3 : 0.2),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => buttonGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'إنشاء طلب جديد',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => buttonGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                'assets/images/repair.png',
                width: size.width * 0.3,
                height: size.height * 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title,
      {required VoidCallback onMorePressed}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        GestureDetector(
          onTap: onMorePressed,
          child: Text(
            'المزيد',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================================
  // START: تعديل لون الزر في _buildNoDataMessage
  // ======================================================================
  Widget _buildNoDataMessage(
      BuildContext context, String message, Size size, String word) {
    final theme = Theme.of(context);
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final homeModel = Provider.of<HomeModel>(context, listen: false);

    // تحديد اللون الأساسي بناءً على وضع السمة
    final Color primaryButtonColor = isDarkMode
        ? theme.colorScheme.primary // استخدم اللون الأساسي للثيم الداكن
        : const Color(0xFF3CD3AD); // استخدم اللون الأخضر/السماوي للثيم الفاتح

    // تحديد لون النص على الزر لضمان التباين
    final Color onPrimaryButtonColor = isDarkMode
        ? theme.colorScheme.onPrimary // استخدم لون النص المناسب للثيم الداكن
        : Colors.white; // استخدم اللون الأبيض للنص في الثيم الفاتح

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: size.height * 0.05),
        Text(
          message,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 16, color: theme.textTheme.bodySmall?.color),
        ),
        SizedBox(height: size.height * 0.02),
        ElevatedButton(
          onPressed: () async {
            if (word == 'طلب') {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: theme.cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (modalContext) => NewRequestModal(
                  isDarkMode: isDarkMode,
                  userData: widget.userData,
                ),
              );

              if (result != null) {
                print('Request Data from NoDataMessage: $result');
                if (userID != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      homeModel.fetchOrders(userID);
                      homeModel.fetchVehicles(userID);
                    }
                  });
                }
              }
            } else if (word == 'مركبة') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVehicleScreen(
                    userData: widget.userData,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ).then((_) {
                if (userID != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      homeModel.fetchVehicles(userID);
                    }
                  });
                }
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor, // <<< استخدام اللون المحدد
            foregroundColor:
                onPrimaryButtonColor, // <<< استخدام لون النص المحدد
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('قم بإضافة ${word} ',style:TextStyle(fontFamily:'Cairo'),),
        ),
        SizedBox(height: size.height * 0.05),
      ],
    );
  }
  // ======================================================================
  // END: تعديل لون الزر
  // ======================================================================

  Widget _buildAnimatedRequestList(Size size, HomeModel homeModel) {
    if (homeModel.orders.isEmpty) {
      return _buildNoDataMessage(context, 'لا توجد طلبات حالية', size, 'طلب');
    }

    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 500),
      reAnimateOnVisibility: true,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: homeModel.orders.length > 3 ? 3 : homeModel.orders.length,
      itemBuilder: (context, index, animation) {
        final order = homeModel.orders[index];
        final vehicle = order['vehicles'];
        final status = order['request_status']?['status_name'] ?? 'غير محدد';
        final modelName = vehicle?['models']?['name'] ?? 'غير متوفر';
        final year = vehicle?['year']?.toString() ?? '';
        final problemDescription =
            order['problem_description'] ?? 'لا توجد تفاصيل';
        final formattedDate =
            formatDate(order['created_at'] ?? DateTime.now().toIso8601String());

        Color statusColor;
        switch (status) {
          case 'مكتملة':
            statusColor = Colors.green;
            break;
          case 'مرفوضة':
            statusColor = Colors.red;
            break;
          case 'قيد المراجعة':
            statusColor = const Color(0xFFFFB74D);
            break;
          case 'قيد التنفيذ':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = Colors.grey;
        }

        return FadeTransition(
          opacity: animation,
          child: _buildRequestItem(
            '$modelName $year'.trim(),
            status,
            formattedDate,
            statusColor,
            size,
            problemDescription,
          ),
        );
      },
    );
  }

  Widget _buildRequestItem(String car, String status, String date, Color color,
      Size size, String problemDescription) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:isDarkMode ? 0.3 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  car,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'المشكلة: ${problemDescription.length > 50 ? problemDescription.substring(0, 50) + '...' : problemDescription}',
            style: TextStyle(
                fontSize: 14, color: theme.textTheme.bodyMedium?.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'تاريخ الإنشاء: $date',
            style: TextStyle(
                fontSize: 12, color: theme.textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonOrderList(Size size) {
    return Column(
      children: List.generate(3, (index) => _buildSkeletonOrderItem(size)),
    );
  }

  Widget _buildSkeletonOrderItem(Size size) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:isDarkMode ? 0.3 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSkeletonLine(size.width * 0.4, 20),
              buildSkeletonLine(size.width * 0.2, 20,
                  borderRadius: BorderRadius.circular(8)),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          buildSkeletonLine(size.width * 0.7, 18),
          SizedBox(height: size.height * 0.01),
          buildSkeletonLine(size.width * 0.5, 16),
        ],
      ),
    );
  }

  Widget _buildAnimatedVehicleList(Size size, HomeModel homeModel) {
    if (homeModel.vehicles.isEmpty) {
      return _buildNoDataMessage(
          context, 'لا توجد مركبات مضافة', size, 'مركبة');
    }

    return LiveList(
      showItemInterval: const Duration(milliseconds: 100),
      showItemDuration: const Duration(milliseconds: 500),
      reAnimateOnVisibility: true,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: homeModel.vehicles.length > 3 ? 3 : homeModel.vehicles.length,
      itemBuilder: (context, index, animation) {
        final vehicle = homeModel.vehicles[index];
        final modelName = vehicle['models']?['name'] ?? 'غير متوفر';
        final brandName = vehicle['models']?['brands']?['name'] ?? 'غير متوفر';
        final year = vehicle['year']?.toString() ?? '';
        final plateNumber = vehicle['plate_number'] ?? 'غير متوفر';

        return FadeTransition(
          opacity: animation,
          child: _buildVehicleItem(
            '$brandName $modelName $year'.trim(),
            plateNumber,
            size,
          ),
        );
      },
    );
  }

  Widget _buildVehicleItem(String vehicleName, String plateNumber, Size size) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:isDarkMode ? 0.3 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car,
              size: 40, color: theme.colorScheme.primary),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'لوحة: $plateNumber',
                  style: TextStyle(
                      fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonVehicleList(Size size) {
    return Column(
      children: List.generate(2, (index) => _buildSkeletonVehicleItem(size)),
    );
  }

  Widget _buildSkeletonVehicleItem(Size size) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:isDarkMode ? 0.3 : 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          buildSkeletonLine(40, 40, borderRadius: BorderRadius.circular(20)),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSkeletonLine(size.width * 0.5, 20),
                SizedBox(height: size.height * 0.005),
                buildSkeletonLine(size.width * 0.3, 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
