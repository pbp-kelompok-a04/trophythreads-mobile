import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../models/merchandise_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/features/review/screens/review_list_page.dart';
import 'package:trophythreads_mobile/features/cart/services/cart_service.dart';
import 'package:trophythreads_mobile/features/cart/screens/cart_list.dart';
import 'package:trophythreads_mobile/features/cart/screens/checkout_page.dart';
import 'package:trophythreads_mobile/features/favorites/screens/favorites_page.dart';

class ProductDetailPage extends StatefulWidget {
  final MerchandiseEntry merchandise;

  const ProductDetailPage({Key? key, required this.merchandise})
    : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isFavorite = false;
  String? _favoriteId;
  bool _isLoadingFavorite = false;
  bool _isLoadingCart = false;
  int _cartCount = 0;

  final List<Map<String, dynamic>> _reviews = [];
  String? _ratingFilter;

  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadCartCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _cartService = CartService(request);
    });
  }

  String _getImageUrl(String? thumbnail) {
    if (thumbnail == null || thumbnail.isEmpty) return '';
    if (thumbnail.startsWith('http')) return thumbnail;

    final host = kIsWeb
        ? 'http://localhost:8000'
        : (Platform.isAndroid
              ? 'http://10.0.2.2:8000'
              : 'http://localhost:8000');
    return '$host$thumbnail';
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r"\B(?=(\d{3})+(?!\d))"),
      (m) => '.',
    );
    return 'Rp $formatted';
  }

  Future<void> _checkFavoriteStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://localhost:8000/favorites/check/${widget.merchandise.pk}/',
      );
      if (response['is_favorited'] == true) {
        setState(() {
          _isFavorite = true;
          _favoriteId = response['favorite_id'];
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> _loadCartCount() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://localhost:8000/cart/json/');
      if (response is List) {
        setState(() => _cartCount = response.length);
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoadingFavorite = true);
    final request = context.read<CookieRequest>();

    try {
      if (_isFavorite && _favoriteId != null) {
        final response = await request.post(
          'http://localhost:8000/favorites/remove/',
          {'favorite_id': _favoriteId},
        );
        if (response['status'] == 'ok') {
          setState(() {
            _isFavorite = false;
            _favoriteId = null;
          });
          _showToast('Removed from Favorites', Colors.blue);
        }
      } else {
        final response = await request.post(
          'http://localhost:8000/favorites/add/',
          {'merchandise_id': widget.merchandise.pk},
        );
        if (response['status'] == 'ok') {
          setState(() {
            _isFavorite = true;
            _favoriteId = response['favorite_id'];
          });
          _showToast('Added to Favorites!', Colors.green);
        }
      }
    } catch (e) {
      _showToast('Failed to update favorite', Colors.red);
      debugPrint('Error toggling favorite: $e');
    } finally {
      setState(() => _isLoadingFavorite = false);
    }
  }

  // Add to Cart menggunakan CartService
  Future<void> _addToCart() async {
    setState(() => _isLoadingCart = true);

    try {
      final result = await _cartService.addToCart(
        productId: widget.merchandise.pk,
        quantity: _quantity,
      );

      if (result['success'] == true) {
        _showToast('Product added to cart!', Colors.green);
        await _loadCartCount();
      } else {
        _showToast(result['message'] ?? 'Failed to add to cart', Colors.red);
      }
    } catch (e) {
      _showToast('An error occurred', Colors.red);
      debugPrint('Error adding to cart: $e');
    } finally {
      setState(() => _isLoadingCart = false);
    }
  }

  // Buy Now menggunakan CartService dan navigasi ke CheckoutPage
  Future<void> _buyNow() async {
    setState(() => _isLoadingCart = true);

    try {
      final result = await _cartService.buyNow(
        productId: widget.merchandise.pk,
        quantity: _quantity,
      );

      setState(() => _isLoadingCart = false);

      if (result['success'] == true) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckoutPage()),
          );
        }
      } else {
        _showToast(result['message'] ?? 'Failed to proceed', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoadingCart = false);
      _showToast('An error occurred', Colors.red);
      debugPrint('Error buying now: $e');
    }
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle
                  : color == Colors.red
                  ? Icons.error
                  : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full)
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        if (i == full && half)
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        return const Icon(Icons.star_border, size: 16, color: Colors.grey);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.merchandise.fields;
    final imageUrl = _getImageUrl(fields.thumbnail);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.red,
            onPressed: () {
              _showToast('Navigate to My Favorites', Colors.blue);
            },
          ),

          // Icon cart navigasi ke CartPage
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            color: Colors.orange,
            onPressed: () {
              // Navigate ke CartPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              ).then((_) {
                _loadCartCount();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),

                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA580C), Color(0xFFB91C1C)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          fields.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (fields.isFeatured)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fields.productViews > 100)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[500],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fields.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  _formatPrice(fields.price),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      '${fields.stock} in stock',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('|', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    _buildStarRating(4.5),
                    const SizedBox(width: 6),
                    const Text(
                      '4.5 (0 reviews)',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (fields.stock > 0) ...[
                  const Text(
                    'Quantity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_quantity < fields.stock) {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                      icon: _isLoadingFavorite
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                      label: Text(
                        _isFavorite
                            ? 'Remove from Favorite'
                            : 'Add to Favorite',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _isFavorite
                            ? const Color(0xFFEF4444)
                            : Colors.white,
                        foregroundColor: _isFavorite
                            ? Colors.white
                            : Colors.grey[700],
                        side: BorderSide(
                          color: _isFavorite
                              ? const Color(0xFFEF4444)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isFavorite ? 4 : 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingCart ? null : _addToCart,
                      icon: _isLoadingCart
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingCart ? null : _buyNow,
                      icon: const Icon(Icons.bolt, color: Colors.orange),
                      label: const Text('Buy Now'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                        SizedBox(width: 8),
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text(
                      'Product Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fields.description.isNotEmpty
                      ? fields.description
                      : 'No description available.',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _showToast('Navigate to all reviews', Colors.blue);
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      _buildFilterChip('5', '5'),
                      _buildFilterChip('4', '4'),
                      _buildFilterChip('3', '3'),
                      _buildFilterChip('2', '2'),
                      _buildFilterChip('1', '1'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.comment,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Reviews Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Be the first to share your thoughts about this product!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showToast('Navigate to write review', Colors.blue);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Write a Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _ratingFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _ratingFilter = value);
        },
        selectedColor: const Color(0xFFB91C1C),
        backgroundColor: Colors.grey[300],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
