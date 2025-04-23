import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

Widget buildBottomNavBar(BuildContext context, int selectedIndex, Function(int) changeTab) {
  final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

  return Container(
    // إضافة تأثير الظل من خلال Container
    decoration: BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.3) // لون الظل في الوضع الليلي
              : Colors.black.withOpacity(0.1), // لون الظل في الوضع الفاتح
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Directionality(
      textDirection: TextDirection.rtl, // تغيير اتجاه النص إلى من اليمين إلى اليسار
      child: ResponsiveNavigationBar(
        fontSize: 16, // حجم النص في شريط التنقل
        animationDuration: const Duration(milliseconds: 400), // مدة الحركة
        backgroundGradient: LinearGradient(
          colors: isDarkMode
              ? [
            const Color(0xFF1E1E1E), // لون التدرج العلوي للوضع الليلي
            const Color(0xFF2C2C2C), // لون التدرج السفلي للوضع الليلي
          ]
              : [
            const Color(0xFF3CD3AD), // لون التدرج العلوي للوضع الفاتح
            const Color(0xFF4CB8C4), // لون التدرج السفلي للوضع الفاتح
          ],
        ),
        activeIconColor: isDarkMode
            ? Colors.white // لون الأيقونة النشطة في الوضع الليلي
            : const Color(0xFF4CB8C4), // لون الأيقونة النشطة في الوضع الفاتح
        inactiveIconColor: isDarkMode
            ? Colors.white.withOpacity(0.6) // لون الأيقونة غير النشطة في الوضع الليلي
            : Colors.white, // لون الأيقونة غير النشطة في الوضع الفاتح
        selectedIndex: selectedIndex, // الشاشة المحددة حاليًا
        onTabChange: changeTab, // استدعاء الدالة عند تغيير الشاشة
        textStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF4CB8C4), // لون النص
          fontWeight: FontWeight.bold, // سمك النص
          fontSize: 14,
        ),
        navigationBarButtons: <NavigationBarButton>[
          NavigationBarButton(
            text: 'الرئيسية', // النص المعروض
            icon: HugeIcons.strokeRoundedHome01, // أيقونة الشاشة الرئيسية
            backgroundGradient: LinearGradient(
              colors: isDarkMode
                  ? [
                Colors.white.withOpacity(0.1), // لون خلفية الزر في الوضع الليلي
                Colors.white.withOpacity(0.05),
              ]
                  : [
                Colors.white, // لون خلفية الزر في الوضع الفاتح
                Colors.white,
              ],
            ),
          ),
          NavigationBarButton(
            text: 'طلباتي', // النص المعروض
            icon: HugeIcons.strokeRoundedRepair, // أيقونة الطلبات
            backgroundGradient: LinearGradient(
              colors: isDarkMode
                  ? [
                Colors.white.withOpacity(0.1), // لون خلفية الزر في الوضع الليلي
                Colors.white.withOpacity(0.05),
              ]
                  : [
                Colors.white, // لون خلفية الزر في الوضع الفاتح
                Colors.white,
              ],
            ),
          ),
          NavigationBarButton(
            text: 'مركباتي', // النص المعروض
            icon: HugeIcons.strokeRoundedCarParking01, // أيقونة المركبات
            backgroundGradient: LinearGradient(
              colors: isDarkMode
                  ? [
                Colors.white.withOpacity(0.1), // لون خلفية الزر في الوضع الليلي
                Colors.white.withOpacity(0.05),
              ]
                  : [
                Colors.white, // لون خلفية الزر في الوضع الفاتح
                Colors.white,
              ],
            ),
          ),
          NavigationBarButton(
            text: 'حسابي', // النص المعروض
            icon: HugeIcons.strokeRoundedUser, // أيقونة الحساب
            backgroundGradient: LinearGradient(
              colors: isDarkMode
                  ? [
                Colors.white.withOpacity(0.1), // لون خلفية الزر في الوضع الليلي
                Colors.white.withOpacity(0.05),
              ]
                  : [
                Colors.white, // لون خلفية الزر في الوضع الفاتح
                Colors.white,
              ],
            ),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // المسافات الداخلية للشريط
      ),
    ),
  );
}