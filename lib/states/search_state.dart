import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _search = "";
  String get search => _search;

  void updateSearch(String newSearch) {
    _search = newSearch;
    notifyListeners();
  }
}