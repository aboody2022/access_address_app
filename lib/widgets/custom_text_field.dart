import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isDarkMode; // إضافة معامل isDarkMode

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
    required this.isDarkMode, // جعل المعامل إلزامي
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withValues(alpha:0.1)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        textAlign: TextAlign.right,
        obscureText: widget.isPassword && _obscureText,
        keyboardType: widget.keyboardType,
        style: GoogleFonts.cairo(
          color: widget.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.cairo(
            color: widget.isDarkMode
                ? Colors.white.withValues(alpha:0.5)
                : Colors.grey.withValues(alpha:0.8),
            fontSize: 14,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText
                  ? HugeIcons.strokeRoundedViewOff
                  : HugeIcons.strokeRoundedView,
              color: widget.isDarkMode ? Colors.white70 : Colors.grey,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
          prefixIcon: Icon(
            widget.icon,
            color: widget.isDarkMode ? Colors.white70 : Colors.grey,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.isDarkMode
                  ? Colors.white.withValues(alpha:0.1)
                  : Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.isDarkMode
                  ? Colors.white.withValues(alpha:0.2)
                  : const Color(0xFF4CB8C4),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.red.shade700 : Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.red.shade700 : Colors.red,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: GoogleFonts.cairo(
            color: widget.isDarkMode ? Colors.red.shade300 : Colors.red,
            fontSize: 12,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}