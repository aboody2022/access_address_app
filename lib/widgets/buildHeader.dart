import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'notification_button.dart';

Widget buildHeader(Size size, String title, String subtitle,int userID) {
  return Builder(
    builder: (context) {
      final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.03,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              Colors.grey[900]!,
              Colors.grey[800]!,
            ]
                : const [
              Color(0xFF4CB8C4),
              Color(0xFF3CD3AD),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha:0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر الإشعارات المخصص
                NotificationButton(
                  isDarkMode: isDarkMode,userId:userID,),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]?.withValues(alpha:0.5)
                        : Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logo_white.png',
                    height: size.height * 0.04,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha:0.3)
                        : Colors.black.withValues(alpha:0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(title),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: size.width * 0.04,
                color: isDarkMode
                    ? Colors.grey[300]
                    : Colors.white.withValues(alpha:0.9),
                shadows: [
                  Shadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha:0.3)
                        : Colors.black.withValues(alpha:0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Text(subtitle),
            ),
          ],
        ),
      );
    },
  );
}