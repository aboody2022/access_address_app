// import 'package:flutter/material.dart';
//
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed; // This should be nullable
//   final bool isLoading; // New property to indicate loading state
//
//   const CustomButton({
//     Key? key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false, // Default to false
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF4CB8C4), // Top-left gradient color
//               Color(0xFF3CD3AD), // Bottom-right gradient color
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12.0), // Rounded corners
//           border: Border.all(color: Colors.white, width: 2), // حواف بيضاء
//         ),
//         child: ElevatedButton(
//           onPressed: isLoading ? null : onPressed, // Disable button when loading
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent, // Make button background transparent
//             shadowColor: Colors.transparent, // Remove shadow
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 2,
//           ),
//           child: isLoading
//               ? SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               strokeWidth: 2,
//             ),
//           )
//               : Text(
//             text,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white, // Text color
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:adaptive_theme/adaptive_theme.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//
//   const CustomButton({
//     Key? key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
//
//     return SizedBox(
//       width: double.infinity,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isDarkMode
//                 ? [
//               Colors.white.withOpacity(0.1),
//               Colors.white.withOpacity(0.2),
//             ]
//                 : [
//               const Color(0xFF4CB8C4),
//               const Color(0xFF3CD3AD),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12.0),
//           border: Border.all(
//             color: isDarkMode
//                 ? Colors.white.withOpacity(0.2)
//                 : Colors.white,
//             width: 2,
//           ),
//           boxShadow: [
//             if (!isDarkMode)
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: isLoading ? null : onPressed,
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Colors.transparent),
//             shadowColor: MaterialStateProperty.all(Colors.transparent),
//             padding: MaterialStateProperty.all(
//               const EdgeInsets.symmetric(vertical: 16),
//             ),
//             shape: MaterialStateProperty.all(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             elevation: MaterialStateProperty.all(0),
//             overlayColor: MaterialStateProperty.resolveWith<Color>(
//                   (Set<MaterialState> states) {
//                 if (states.contains(MaterialState.pressed)) {
//                   return isDarkMode
//                       ? Colors.white.withOpacity(0.1)
//                       : Colors.white.withOpacity(0.1);
//                 }
//                 if (states.contains(MaterialState.hovered)) {
//                   return isDarkMode
//                       ? Colors.white.withOpacity(0.05)
//                       : Colors.white.withOpacity(0.05);
//                 }
//                 return Colors.transparent;
//               },
//             ),
//           ),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: isLoading
//                 ? SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   isDarkMode ? Colors.white70 : Colors.white,
//                 ),
//                 strokeWidth: 2,
//               ),
//             )
//                 : Text(
//               text,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white70 : Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDarkMode; // إضافة معامل isDarkMode

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    required this.isDarkMode, // جعل المعامل إلزامي
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.2),
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
                ? Colors.white.withOpacity(0.2)
                : Colors.white,
            width: 2,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevation: MaterialStateProperty.all(0),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.1);
                }
                if (states.contains(MaterialState.hovered)) {
                  return isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.05);
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