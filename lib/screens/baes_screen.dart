import 'package:flutter/material.dart';
import 'package:access_address_app/screens/home_screen.dart';
import 'package:access_address_app/screens/my_orders_screen.dart';
import 'package:access_address_app/screens/my_vehicles_screen.dart';
import 'package:access_address_app/screens/account_screen.dart';
import 'package:adaptive_theme/adaptive_theme.dart'; // إضافة مكتبة الثيم

import '../widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; // بيانات المستخدم القابلة للإلغاء

  const MainScreen({super.key, this.userData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0; // مؤشر الشاشة المحددة
  final List<Widget> _screens = []; // قائمة الشاشات

  @override
  void initState() {
    super.initState();
    // إضافة مراقب لتغييرات النظام
    WidgetsBinding.instance.addObserver(this);

    // إضافة الشاشات مع تمرير بيانات المستخدم
    _screens.addAll([
      HomeScreen(userData: widget.userData), // تمرير البيانات للشاشة الرئيسية
      MyOrdersScreen(userData: widget.userData), // تمرير البيانات لشاشة الطلبات
      MyVehiclesScreen(userData: widget.userData), // تمرير البيانات لشاشة المركبات
      AccountScreen(userData: widget.userData), // تمرير البيانات لشاشة الحساب
    ]);
  }

  @override
  void dispose() {
    // إزالة المراقب عند إغلاق الشاشة
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // دالة تغيير الشاشة المحددة
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حالة الوضع الليلي
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      // تحديث لون الخلفية بناءً على الوضع
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      // استخدام IndexedStack للحفاظ على حالة الشاشات
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // إضافة شريط التنقل السفلي مع تمرير السياق
      bottomNavigationBar: buildBottomNavBar(
          context,
          _selectedIndex,
          changeTab
      ),
    );
  }
}