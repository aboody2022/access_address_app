import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDarkMode; // إضافة معامل isDarkMode

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    required this.isDarkMode, // جعل المعامل إلزامي
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              Colors.white.withValues(alpha:0.1),
              Colors.white.withValues(alpha:0.2),
            ]
                : [
              const Color(0xFF4CB8C4),
              const Color(0xFF3CD3AD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha:0.2)
                : Colors.white,
            width: 2,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
            overlayColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return isDarkMode
                      ? Colors.white.withValues(alpha:0.1)
                      : Colors.white.withValues(alpha:0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return isDarkMode
                      ? Colors.white.withValues(alpha:0.05)
                      : Colors.white.withValues(alpha:0.05);
                }
                return Colors.transparent;
              },
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.white70 : Colors.white,
                ),
                strokeWidth: 2,
              ),
            )
                : Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}