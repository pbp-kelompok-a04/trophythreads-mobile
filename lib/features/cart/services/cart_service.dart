import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/cart_entry.dart';

class CartService {
  // TODO: Ganti dengan URL Django Anda
  static const String baseUrl = 'http://localhost:8000'; // atau URL deploy Anda

  final CookieRequest request;

  CartService(this.request);

  // ============ FETCH CART ITEMS ============
  Future<List<CartItem>> fetchCartItems() async {
    try {
      final response = await request.get('$baseUrl/cart/json/');

      if (response is Map && response.containsKey('items')) {
        final items = response['items'] as List;
        return items.map((item) => _parseCartItem(item)).toList();
      } else if (response is List) {
        return response.map((item) => CartItem.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching cart: $e');
      return [];
    }
  }

  CartItem _parseCartItem(Map<String, dynamic> data) {
    if (data.containsKey('model')) {
      return CartItem.fromJson(data);
    }

    return CartItem(
      model: "cartApp.cart_item",
      pk: data['id'],
      fields: Fields(
        cart: data['cart'] ?? 0,
        product: data['product']?.toString() ?? '',
        productName: data['product_name'],
        productPrice: data['product_price'],
        productThumbnail: data['product_thumbnail'],
        productStock: data['product_stock'],
        quantity: data['quantity'],
        selected: data['selected'],
      ),
    );
  }

  // ============ ADD TO CART ============
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      if (productId.isEmpty) {
        return {'success': false, 'message': 'Product ID is required'};
      }

      print('Adding to cart: productId=$productId, quantity=$quantity');

      final response = await request.postJson(
        '$baseUrl/cart/add/',
        jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      print('Add to cart response: $response');

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Added to cart',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to add to cart',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error adding to cart: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ UPDATE CART ITEM ============
  Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    required String action,
    int? quantity,
  }) async {
    try {
      final body = <String, dynamic>{'action': action};
      if (action == 'set' && quantity != null) {
        body['quantity'] = quantity;
      }

      final response = await request.postJson(
        '$baseUrl/cart/update/$itemId/',
        jsonEncode(body),
      );

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Updated',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to update',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error updating cart item: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ DELETE CART ITEM ============
  Future<Map<String, dynamic>> deleteCartItem(int itemId) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/delete/$itemId/',
        jsonEncode({}),
      );

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Item deleted',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to delete',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error deleting cart item: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ TOGGLE SELECT ITEM ============
  Future<Map<String, dynamic>> toggleSelectItem(int itemId) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/toggle-select/$itemId/',
        jsonEncode({}),
      );

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Selection toggled',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to toggle',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error toggling selection: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ TOGGLE SELECT ALL ============
  Future<Map<String, dynamic>> toggleSelectAll(bool selected) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/toggle-all/',
        jsonEncode({'selected': selected}),
      );
      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'All items toggled',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to toggle all',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error toggling all: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ CHECKOUT ============
  Future<Map<String, dynamic>> checkout({
    required String address,
    String paymentMethod = 'cod',
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/cart/checkout/',
        jsonEncode({'address': address, 'payment_method': paymentMethod}),
      );

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Checkout successful',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Checkout failed',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error during checkout: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ BUY NOW ============
  Future<Map<String, dynamic>> buyNow({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      if (productId.isEmpty) {
        return {'success': false, 'message': 'Product ID is required'};
      }

      print('Buy now: productId=$productId, quantity=$quantity');

      final response = await request.postJson(
        '$baseUrl/cart/buy-now/',
        jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      print('Buy now response: $response');

      if (response is Map) {
        if (response['status'] == 'success' || response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Buy now successful',
            'data': response['data'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Buy now failed',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error during buy now: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ GET CHECKOUT ITEMS ============
  Future<Map<String, dynamic>> getCheckoutItems() async {
    try {
      final response = await request.get('$baseUrl/cart/api/checkout-items/');

      if (response is Map) {
        return {
          'success': true,
          'items': response['items'] ?? [],
          'total_before_fee': response['total_before_fee'] ?? 0,
          'shipping_fee': response['shipping_fee'] ?? 0,
          'service_fee': response['service_fee'] ?? 0,
          'grand_total': response['grand_total'] ?? 0,
          'is_buy_now': response['is_buy_now'] ?? false,
          'error': response['error'],
        };
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error getting checkout items: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ PROCESS CHECKOUT ============
  Future<Map<String, dynamic>> processCheckout({
    required String address,
    required String paymentMethod,
  }) async {
    try {
      if (address.isEmpty) {
        return {'success': false, 'message': 'Address is required'};
      }

      if (paymentMethod.isEmpty) {
        return {'success': false, 'message': 'Payment method is required'};
      }

      print('Processing checkout: address=$address, payment=$paymentMethod');

      final response = await request.postJson(
        '$baseUrl/cart/api/process-checkout/',
        jsonEncode({'address': address, 'payment_method': paymentMethod}),
      );

      print('Checkout response: $response');

      if (response is Map) {
        if (response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ?? 'Checkout successful',
            'order_token': response['order_token'],
            'total': response['total'],
            'shipping_fee': response['shipping_fee'],
            'service_fee': response['service_fee'],
            'grand_total': response['grand_total'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Checkout failed',
          };
        }
      }

      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Error processing checkout: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
