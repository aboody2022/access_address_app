import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';


void showCustomSnackbar(BuildContext context,String message, SnackBarType type) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    IconSnackBar.show(
      context,
      snackBarType: type,
      label: message,
      backgroundColor: type == SnackBarType.fail
          ? Colors.red
          : type == SnackBarType.success
          ? Colors.green
          : Color(0xffec942c),
      iconColor: Colors.white,
    );
  });
}