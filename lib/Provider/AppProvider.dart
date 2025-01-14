import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkTheme = false;
  int _displayWallpaperColumns = 3;
  String _displayCategory = "List";

  // Getters
  bool get isDarkTheme => _isDarkTheme;
  int get displayWallpaperColumns => _displayWallpaperColumns;
  String get displayCategory => _displayCategory;

  // Setters
  void toggleTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  void setWallpaperColumns(int columns) {
    _displayWallpaperColumns = columns;
    notifyListeners();
  }

  void setDisplayCategory(String category) {
    _displayCategory = category;
    notifyListeners();
  }

  void clearCache() {
    // Perform cache clearing logic here
    notifyListeners();
  }

  void clearSearchHistory() {
    // Perform search history clearing logic here
    notifyListeners();
  }

  int _tapCount = 0;

  int get tapCount => _tapCount;

  void incrementTapCount() {
    _tapCount++;
    notifyListeners();
  }
}
