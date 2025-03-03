import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetState extends ChangeNotifier {
  Future<bool> checkInternetStatus() async {
    // Get the list of connectivity results
    List<ConnectivityResult> connectRes = await Connectivity().checkConnectivity();

    // Check if the list contains either mobile or wifi connectivity
    if (connectRes.contains(ConnectivityResult.mobile) || connectRes.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }
}