import 'package:pbp_django_auth/pbp_django_auth.dart';

class FavoritesService {
  // Ganti dengan URL backend Anda
  static const String baseUrl = 'http://localhost:8000';
  
  // Tambah ke favorites
  static Future<Map<String, dynamic>> addFavorite(
    CookieRequest request,
    String merchandiseId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/favorites/add/',
        {
          'merchandise_id': merchandiseId,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Hapus dari favorites (by favorite_id)
  static Future<Map<String, dynamic>> removeFavoriteById(
    CookieRequest request,
    String favoriteId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/favorites/remove/',
        {
          'favorite_id': favoriteId,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Hapus dari favorites (by merchandise_id)
  static Future<Map<String, dynamic>> removeFavoriteByMerchandiseId(
    CookieRequest request,
    String merchandiseId,
  ) async {
    try {
      final response = await request.post(
        '$baseUrl/favorites/remove/',
        {
          'merchandise_id': merchandiseId,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Cek apakah merchandise sudah difavorite
  static Future<Map<String, dynamic>> checkFavorite(
    CookieRequest request,
    String merchandiseId,
  ) async {
    try {
      final response = await request.get(
        '$baseUrl/favorites/check/$merchandiseId/',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to check favorite: $e');
    }
  }

  // Fetch semua favorites
  static Future<Map<String, dynamic>> getFavorites(
    CookieRequest request,
  ) async {
    try {
      final response = await request.get('$baseUrl/favorites/json/');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // Toggle favorite (add jika belum ada, remove jika sudah ada)
  static Future<Map<String, dynamic>> toggleFavorite(
    CookieRequest request,
    String merchandiseId,
  ) async {
    try {
      // Check dulu apakah sudah difavorite
      final checkResponse = await checkFavorite(request, merchandiseId);
      
      if (checkResponse['is_favorited'] == true) {
        // Jika sudah difavorite, hapus
        return await removeFavoriteByMerchandiseId(request, merchandiseId);
      } else {
        // Jika belum difavorite, tambah
        return await addFavorite(request, merchandiseId);
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}