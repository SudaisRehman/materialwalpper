import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkTheme = false;
  int _displayWallpaperColumns = 3;
  String _displayCategory = "List";
  static const String _themeKey = "isDarkTheme";
  static const String _columnsKey = "displayWallpaperColumns";
  static const String _categoryKey = "displayCategory";

  AppProvider() {
    _loadPreferences();
  }

  // Getters

  bool get isDarkTheme => _isDarkTheme;
  int get displayWallpaperColumns => _displayWallpaperColumns;
  String get displayCategory => _displayCategory;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_themeKey) ?? false;
    _displayWallpaperColumns = prefs.getInt(_columnsKey) ?? 3;
    _displayCategory = prefs.getString(_categoryKey) ?? "List";
    notifyListeners();
  }

  // Setters
  void toggleTheme(bool value) async {
    _isDarkTheme = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, value);
  }

  void setWallpaperColumns(int columns) async {
    _displayWallpaperColumns = columns;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_columnsKey, columns);
  }

  void setDisplayCategory(String category) async {
    _displayCategory = category;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_categoryKey, category);
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
