import 'package:access_address_app/widgets/show_custom_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';


Future<void> checkInternetConnection(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    showCustomSnackbar(context, "لا يوجد اتصال بالإنترنت", SnackBarType.alert);
  }
}


