import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class CartService {
  static const String baseUrl = 'http://localhost:8000';

  // Add product to cart
  static Future<Map<String, dynamic>> addToCart(
    CookieRequest request,
    String productId,
    int quantity,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/add/',
        jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      // Check if response is valid
      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Buy now - direct purchase without adding to cart
  static Future<Map<String, dynamic>> buyNow(
    CookieRequest request,
    String productId,
    int quantity,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/buy-now/',
        jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update cart item quantity
  // action: 'inc', 'dec', or 'set'
  static Future<Map<String, dynamic>> updateQuantity(
    CookieRequest request,
    int itemId,
    String action, {
    int? quantity,
  }) async {
    try {
      Map<String, dynamic> data = {'action': action};
      if (quantity != null) {
        data['quantity'] = quantity;
      }

      final response = await request.postJson(
        '$baseUrl/cart/update/$itemId/',
        jsonEncode(data),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Toggle item selection
  static Future<Map<String, dynamic>> toggleSelection(
    CookieRequest request,
    int itemId,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/toggle/$itemId/',
        jsonEncode({}),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Toggle select all items
  static Future<Map<String, dynamic>> toggleSelectAll(
    CookieRequest request,
    bool selected,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/toggle-all/',
        jsonEncode({'selected': selected}),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Delete cart item
  static Future<Map<String, dynamic>> deleteItem(
    CookieRequest request,
    int itemId,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/delete/$itemId/',
        jsonEncode({}),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get cart items as JSON (Old format - for backward compatibility)
  static Future<List<dynamic>> getCartItems(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/cart/json/');
      return response as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  // Get cart page data with proper format (RECOMMENDED)
  static Future<Map<String, dynamic>> getCartPage(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/cart/?format=json');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {
        'items': [],
        'cart_subtotal': 0,
        'total_items': 0,
        'selected_count': 0,
        'total_price': 0,
      };
    } catch (e) {
      return {
        'items': [],
        'cart_subtotal': 0,
        'total_items': 0,
        'selected_count': 0,
        'total_price': 0,
      };
    }
  }

  // Checkout selected items
  static Future<Map<String, dynamic>> checkout(
    CookieRequest request,
    String address,
    String paymentMethod,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/checkout/',
        jsonEncode({'address': address, 'payment_method': paymentMethod}),
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<dynamic>> getCheckoutItems(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/cart/checkout/json/');
      return response as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getAfterCheckoutInfo(
    CookieRequest request,
  ) async {
    try {
      final response = await request.get('$baseUrl/cart/after/?format=json');
      return response as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
