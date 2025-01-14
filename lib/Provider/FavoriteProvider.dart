import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON

class FavoriteProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  /// Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteString = prefs.getString('favorites') ?? '[]';
    try {
      _favorites = List<Map<String, dynamic>>.from(json.decode(favoriteString));
    } catch (e) {
      _favorites = [];
      print("Error loading favorites: $e");
    }
    notifyListeners();
  }

  /// Save favorites to SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteString = json.encode(_favorites);
    await prefs.setString('favorites', favoriteString);
  }

  /// Add a wallpaper to favorites
  void addFavorite(Map<String, dynamic> wallpaper) {
    if (wallpaper['id'] == null || wallpaper['image_upload'] == null) {
      throw ArgumentError('Wallpaper must have a valid id and image_upload.');
    }

    // Check if the wallpaper is already in the list
    if (!_favorites.any((fav) => fav['id'] == wallpaper['id'])) {
      _favorites.add(wallpaper);
      saveFavorites(); // Save to SharedPreferences
      notifyListeners();
    }
  }

  /// Remove a wallpaper from favorites
  void removeFavorite(String wallpaperId) {
    _favorites.removeWhere((fav) => fav['id'] == wallpaperId);
    saveFavorites(); // Save to SharedPreferences
    notifyListeners();
  }

  /// Check if a wallpaper is a favorite
  bool isFavorite(String wallpaperId) {
    return _favorites.any((fav) => fav['id'] == wallpaperId);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorites');
    notifyListeners();
  }
}
