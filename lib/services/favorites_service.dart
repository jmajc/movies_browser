import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString(_favoritesKey);
    if (favoritesString != null) {
      return List<int>.from(jsonDecode(favoritesString));
    }
    return [];
  }

  Future<void> addFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(id)) {
      favorites.add(id);
      prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
  }

  Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(id);
    prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }
}
