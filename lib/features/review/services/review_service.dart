import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review_entry.dart';

class ReviewService {
  static const String baseUrl = 'https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id';
  final CookieRequest request;

  ReviewService(this.request);

  // ============ FETCH REVIEWS ============
  Future<ReviewEntry> fetchReviews({
    required String productId,
    String stars = 'all',
  }) async {
    try {
      String url = '$baseUrl/review/api/product/$productId/';
      if (stars != 'all') {
        url += '?stars=$stars';
      }

      final response = await request.get(url);

      if (response is Map<String, dynamic>) {
        return ReviewEntry.fromJson(response);
      }

      throw Exception('Response bukan JSON Map');
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      rethrow;
    }
  }

  // ============ ADD REVIEW ============
  Future<Map<String, dynamic>> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/review/api/product/$productId/add/',
        jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============ EDIT REVIEW ============
  Future<Map<String, dynamic>> editReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/review/api/review/$reviewId/edit/',
        jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============ DELETE REVIEW ============
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await request.postJson(
        '$baseUrl/review/api/review/$reviewId/delete/',
        jsonEncode({}),
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
