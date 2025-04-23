import 'package:flutter/material.dart';
import 'package:splash_view/splash_view.dart';
import 'package:access_address_app/screens/onboard_screen.dart'; // تأكد من استيراد OnboardScreen
import 'package:animated_text_kit/animated_text_kit.dart'; // استيراد مكتبة AnimatedTextKit

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CB8C4), // Top gradient color
            Color(0xFF3CD3AD), // Bottom gradient color
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SplashView(
        duration: Duration(seconds: 3), // مدة عرض الشاشة (3 ثواني)
        logo: Image.asset(
          height: 200,
          width: 200,
          'assets/images/logoGif.gif', // عرض الصورة
          fit: BoxFit.contain, // ملاءمة الصورة داخل الدائرة
        ),
        title: Container(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'عنوان الوصول',
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CB8C4), // لون النص
                ),
                speed: const Duration(milliseconds: 100), // سرعة الكتابة
              ),
            ],
            totalRepeatCount: 1, // عدد مرات تكرار الرسالة
            pause: const Duration(milliseconds: 1000), // فترة الانتظار بعد الانتهاء
            displayFullTextOnTap: true, // عرض النص بالكامل عند النقر
            stopPauseOnTap: true, // إيقاف التوقف عند النقر
          ),
        ),
        backgroundColor: Colors.transparent, // اجعل لون الخلفية شفافًا
        done: Done(OnboardScreen()), // الانتقال إلى OnboardScreen بعد انتهاء مدة العرض
      ),
    );
  }
}