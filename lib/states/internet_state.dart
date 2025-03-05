import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetState extends ChangeNotifier {
  Future<bool> checkInternetStatus() async {
    List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.isNotEmpty && !connectivityResults.contains(ConnectivityResult.none);
  }
}
