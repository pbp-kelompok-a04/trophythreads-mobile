// Imoirt yang diperlukan
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trophythreads_mobile/features/review/models/review_entry.dart';
import 'package:trophythreads_mobile/features/review/services/review_service.dart';
import 'dart:io' show Platform;
import '../models/merchandise_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/main.dart';
import 'package:trophythreads_mobile/features/review/screens/review_list_page.dart';
import 'package:trophythreads_mobile/features/review/screens/add_review_page.dart';
import 'package:trophythreads_mobile/features/cart/services/cart_service.dart';
import 'package:trophythreads_mobile/features/cart/screens/cart_list.dart';
import 'package:trophythreads_mobile/features/cart/screens/checkout_page.dart';
import 'package:trophythreads_mobile/features/favorites/screens/favorites_page.dart';
import 'package:trophythreads_mobile/features/auth/screens/login.dart';

// Widget StatefulWidget untuk halaman detail produk merchandise
// Halaman ini menampilkan informasi lengkap produk termasuk gambar, harga, deskripsi, dan review
class ProductDetailPage extends StatefulWidget {
  final MerchandiseEntry merchandise; // Data merchandise yang akan ditampilkan

  // Constructor dengan required parameter merchandise
  const ProductDetailPage({Key? key, required this.merchandise})
    : super(key: key);

  // Method untuk membuat state dari widget ini
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

// State class untuk ProductDetailPage
class _ProductDetailPageState extends State<ProductDetailPage> {
  // State variables untuk quantity dan favorite
  int _quantity = 1; // Jumlah produk yang akan dibeli
  bool _isFavorite = false; // Status apakah produk sudah di-favorite
  String? _favoriteId; // ID favorite dari server
  bool _isLoadingFavorite = false; // Loading state untuk operasi favorite
  bool _isLoadingCart = false; // Loading state untuk operasi cart
  int _cartCount = 0; // Jumlah item di cart

  // List untuk menyimpan reviews (placeholder)
  final List<Map<String, dynamic>> _reviews = [];
  String? _ratingFilter; // Filter rating yang dipilih user
  bool _isGuest = false; // Status apakah user adalah guest (belum login)

  // Service untuk operasi cart
  late CartService _cartService;
  late ReviewService _reviewService;
  ReviewEntry? _reviewData;
  bool _isLoadingReviews = true;


  // Method initState dipanggil saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    // Cek apakah user adalah guest
    _checkGuestStatus();
    // Cek status favorite produk dari server
    _checkFavoriteStatus();
    // Load jumlah item di cart
    _loadCartCount();
    // Inisialisasi CartService setelah frame pertama di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _cartService = CartService(request);
      _reviewService = ReviewService(request);
      _loadReviewData();
    });
  }

  Future<void> _loadReviewData() async {
    setState(() => _isLoadingReviews = true);
    try {
      final data = await _reviewService.fetchReviews(
        productId: widget.merchandise.pk.toString(),
        stars: 'all',
      );
      if (mounted) {
        setState(() {
          _reviewData = data;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  // Method async untuk mengecek apakah user adalah guest (belum login)
  Future<void> _checkGuestStatus() async {
    final isGuest = await LoginPageState.isGuest();
    setState(() {
      _isGuest = isGuest;
    });
  }

  // Method untuk mendapatkan URL lengkap gambar produk
  String _getImageUrl(String? thumbnail) {
    // Jika thumbnail null atau kosong, return string kosong
    if (thumbnail == null || thumbnail.isEmpty) return '';
    // Jika thumbnail sudah URL lengkap (dimulai dengan http), return langsung
    if (thumbnail.startsWith('http')) return thumbnail;

    // Tentukan host berdasarkan platform
    final host = kIsWeb
        ? 'http://localhost:8000' // Web menggunakan localhost
        : (Platform.isAndroid
              ? 'http://10.0.2.2:8000' // Android emulator menggunakan 10.0.2.2
              : 'http://localhost:8000'); // iOS menggunakan localhost
    // Gabungkan host dengan thumbnail path
    return '$host$thumbnail';
  }

  // Method untuk memformat harga menjadi format Rupiah dengan pemisah ribuan
  String _formatPrice(int price) {
    // Format harga dengan regex untuk menambahkan titik sebagai pemisah ribuan
    final formatted = price.toString().replaceAllMapped(
      RegExp(r"\B(?=(\d{3})+(?!\d))"),
      (m) => '.', // Ganti dengan titik
    );
    // Return dengan prefix 'Rp '
    return 'Rp $formatted';
  }

  // Method untuk memformat deskripsi dari HTML ke plain text
  // Mengubah tag <br> menjadi line break (\n)
  String _formatDescription(String description) {
    return description
        .replaceAll('<br><br>', '\n\n') // Double br menjadi double newline
        .replaceAll('<br>', '\n') // Single br menjadi single newline
        .replaceAll('<BR><BR>', '\n\n') // Double BR uppercase
        .replaceAll('<BR>', '\n'); // Single BR uppercase
  }

  // Method async untuk mengecek apakah produk sudah di-favorite oleh user
  Future<void> _checkFavoriteStatus() async {
    final request = context.read<CookieRequest>();
    try {
      // Kirim GET request ke endpoint check favorite
      final response = await request.get(
        'http://localhost:8000/favorites/check/${widget.merchandise.pk}/',
      );
      if (mounted) {
        setState(() {
          _isFavorite = response['is_favorited'] == true;
          _favoriteId = response['favorite_id'];
        });
      }
    } catch (e) {
      // Log error jika terjadi masalah
      debugPrint('Error checking favorite: $e');
    }
  }

  // Method async untuk memuat jumlah item di cart
  Future<void> _loadCartCount() async {
    final request = context.read<CookieRequest>();
    try {
      // Kirim GET request ke endpoint cart
      final response = await request.get('http://localhost:8000/cart/json/');
      if (response is List && mounted) {
        setState(() => _cartCount = response.length);
      }
    } catch (e) {
      // Log error jika terjadi masalah
      debugPrint('Error loading cart count: $e');
    }
  }

  // Method async untuk toggle status favorite (add/remove)
  Future<void> _toggleFavorite() async {
    // Check if user can access this feature (must be "user" role)
    bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Favorites');
    if (!canAccess) {
      return;
    }

    setState(() => _isLoadingFavorite = true);
    final request = context.read<CookieRequest>();

    try {
      // Jika sudah favorite, lakukan remove
      if (_isFavorite && _favoriteId != null) {
        final response = await request.post(
          'http://localhost:8000/favorites/remove/',
          {'favorite_id': _favoriteId},
        );
        if (response['status'] == 'ok') {
          // Update state jika berhasil remove
          setState(() {
            _isFavorite = false;
            _favoriteId = null;
          });
          _showToast('Removed from Favorites', Colors.blue);
        }
      } else {
        // Jika belum favorite, lakukan add
        final response = await request.post(
          'http://localhost:8000/favorites/add/',
          {'merchandise_id': widget.merchandise.pk},
        );
        if (response['status'] == 'ok') {
          // Update state jika berhasil add
          setState(() {
            _isFavorite = true;
            _favoriteId = response['favorite_id'];
          });
          _showToast('Added to Favorites!', Colors.green);
        }
      }
    } catch (e) {
      // Tampilkan error jika gagal
      _showToast('Failed to update favorite', Colors.red);
      debugPrint('Error toggling favorite: $e');
    } finally {
      // Reset loading state
      setState(() => _isLoadingFavorite = false);
    }
  }

  // Add to Cart menggunakan CartService
  Future<void> _addToCart() async {
    // Check if user can access this feature (must be "user" role)
    bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Cart');
    if (!canAccess) {
      return;
    }

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
      // Tampilkan error jika terjadi exception
      _showToast('An error occurred', Colors.red);
      debugPrint('Error adding to cart: $e');
    } finally {
      // Reset loading state
      setState(() => _isLoadingCart = false);
    }
  }

  // Buy Now menggunakan CartService dan navigasi ke CheckoutPage
  Future<void> _buyNow() async {
    // Check if user can access this feature (must be "user" role)
    bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Pembelian');
    if (!canAccess) {
      return;
    }

    setState(() => _isLoadingCart = true);

    try {
      // Panggil method buyNow dari CartService
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

  // Method untuk menampilkan toast message (SnackBar) di bottom screen
  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Content berisi icon dan message
        content: Row(
          children: [
            // Icon berdasarkan warna (success/error/info)
            Icon(
              color == Colors.green
                  ? Icons.check_circle // Icon success
                  : color == Colors.red
                  ? Icons.error // Icon error
                  : Icons.info, // Icon info
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color, // Background color sesuai parameter
        behavior: SnackBarBehavior.floating, // Floating snackbar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3), // Durasi tampil 3 detik
      ),
    );
  }

  // Method untuk membangun widget star rating (bintang 1-5)
  Widget _buildStarRating(double rating) {
    int full = rating.floor(); // Jumlah bintang penuh
    bool half = (rating - full) >= 0.5; // Apakah ada setengah bintang
    return Row(
      mainAxisSize: MainAxisSize.min,
      // Generate 5 bintang
      children: List.generate(5, (i) {
        if (i < full)
          return const Icon(Icons.star, size: 16, color: Colors.amber); // Bintang penuh
        if (i == full && half)
          return const Icon(Icons.star_half, size: 16, color: Colors.amber); // Setengah bintang
        return const Icon(Icons.star_border, size: 16, color: Colors.grey); // Bintang kosong
      }),
    );
  }

  double get _averageRating {
    if (_reviewData == null || _reviewData!.total == 0) return 0.0;
    int sum = 0;
    _reviewData!.counts.forEach((star, count) {
      sum += int.parse(star) * count;
    });
    return sum / _reviewData!.total;
  }

  // Method build untuk membangun UI halaman detail produk
  @override
  Widget build(BuildContext context) {
    // Ambil fields dari merchandise untuk akses lebih mudah
    final fields = widget.merchandise.fields;
    // Dapatkan URL gambar produk
    final imageUrl = _getImageUrl(fields.thumbnail);

    // Return Scaffold sebagai struktur utama halaman
    return Scaffold(
      backgroundColor: Color(0xFFFFF1F1), // Background pink muda
      // AppBar di bagian atas halaman
      appBar: AppBar(
        elevation: 0, // Tidak ada bayangan
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Product Detail',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        // Tombol back di kiri
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context), // Kembali ke halaman sebelumnya
        ),
        // Actions di kanan AppBar
        actions: [
          // Icon favorite ke favoritePage
          IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.red,
            onPressed: () async {
              // Check if user can access this feature (must be "user" role)
              bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Favorites');
              if (!canAccess) {
                return;
              }

              // Navigate ke FavoritesPage dan tunggu result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
              
              // Refresh favorite status setelah kembali dari favorites page
              if (result == true && mounted) {
                await _checkFavoriteStatus();
              }
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
            onPressed: () async {
              // Check if user can access this feature (must be "user" role)
              bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Cart');
              if (!canAccess) {
                return;
              }

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

      // Body Content
      body: ListView(
        children: [
          // Image Section
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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

          // Details Section
          Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                          ],
                        ),
                        const Text('|', style: TextStyle(color: Colors.redAccent)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoadingReviews
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : _buildStarRating(_averageRating),
                            const SizedBox(width: 6),
                            _isLoadingReviews
                                ? const Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.black54),
                                  )
                                : Text(
                                    '${_averageRating.toStringAsFixed(1)} (${_reviewData?.total ?? 0} reviews)',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.deepOrange),
                          const SizedBox(width: 6),
                          Text(
                            '${fields.productViews} views',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Jika user adalah guest, tampilkan pesan login prompt
                if (_isGuest) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(text: 'Ingin melakukan transaksi? '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigasi ke halaman login
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (fields.stock > 0) ...[                 
                  const SizedBox(height: 8),
                  // Quantity selector - hanya tampil untuk user yang sudah login
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 167, 16, 16),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 115, 16, 16).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoadingFavorite ? null : _toggleFavorite,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoadingFavorite
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
                                        color: Colors.white,
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  _isFavorite
                                      ? 'Remove from Favorite'
                                      : 'Add to Favorite',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEA580C), Color(0xFFB91C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoadingCart ? null : _addToCart,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoadingCart
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
                                    : const Icon(Icons.shopping_cart, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoadingCart ? null : _buyNow,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoadingCart
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.bolt, color: Colors.orange),
                                const SizedBox(width: 8),
                                const Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
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

          const SizedBox(height: 15),

          // Description Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text(
                      'Product Description── .✦:',
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
                      ? _formatDescription(fields.description)
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

          const SizedBox(height: 15),

          // Reviews Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewListPage(
                              productId: widget.merchandise.pk.toString(),
                              productName: widget.merchandise.fields.name,
                            ),
                          ),
                        );

                        if (mounted) {
                          await _loadReviewData();
                        }
                      },
                      child: const Text(
                        'See All Reviews →',
                        style: TextStyle(
                          color: Color(0xFFE93C49),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )

                  ],
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
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
                        onPressed: () async {
                          // Check if user can access this feature (must be "user" role)
                          bool canAccess = await LoginPageState.canAccessUserFeature(context, 'Review');
                          if (!canAccess) {
                            return;
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReviewPage(
                                productId: widget.merchandise.pk.toString(),
                                productName: widget.merchandise.fields.name,
                              ),
                            ),
                          );

                          // optional: refresh page setelah submit review
                          if (mounted) {
                            await _loadReviewData();
                          }
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Method untuk membangun widget filter chip untuk rating
  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _ratingFilter == value; // Cek apakah chip ini sedang dipilih
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected, // Set selected state
        onSelected: (selected) {
          // Update rating filter saat chip di-tap
          setState(() => _ratingFilter = value);
        },
        selectedColor: const Color(0xFFB91C1C), // Warna merah saat dipilih
        backgroundColor: Colors.grey[300], // Warna abu-abu saat tidak dipilih
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87, // Warna text
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold jika dipilih
        ),
      ),
    );
  }
}