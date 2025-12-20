import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/fav_entry.dart';
import '../widgets/favorites_card.dart';
import '../../merchandise/screens/merchandise_list.dart'; // Import merchandise list

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Favorite> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => isLoading = true);
    
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.get('http://localhost:8000/favorites/json/');
      
      if (response['status'] == 'ok') {
        final favsItem = FavsItem.fromJson(response);
        setState(() {
          favorites = favsItem.favorites;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(String favoriteId) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.post(
        'http://localhost:8000/favorites/remove/',
        {
          'favorite_id': favoriteId,
        },
      );
      
      if (response['status'] == 'ok') {
        setState(() {
          favorites.removeWhere((fav) => fav.favoriteId == favoriteId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil dihapus dari Favorites ❤️'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF8B4513),
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to remove favorite');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(  // Tambahkan ini
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(  // Scaffold yang sudah ada
        backgroundColor: const Color(0xFFFFF5F5),
        appBar: _buildAppBar(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFE57373),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context, true), 
      ),
      titleSpacing: 0, // Hapus spacing default antara leading dan title
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite, color: Color(0xFFE57373), size: 20),
            SizedBox(width: 8),
            Text(
              'My Favorites',
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi ke Cart')),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Color(0xFFE57373), size: 18),
            label: const Text(
              'My Cart',
              style: TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE57373), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE57373).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 70,
                color: Color(0xFFE57373),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Belum ada produk di Favorites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Silahkan tambahkan produk favorit Anda\ndengan menekan tombol ❤️ pada produk',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate ke Merchandise List Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MerchandiseEntryListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag, color: Colors.white),
              label: const Text(
                'Jelajahi Merchandise',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        // Header dengan jumlah favorites
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFFE57373),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${favorites.length} Produk Favorit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
        ),
        // Grid List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchFavorites,
            color: const Color(0xFFE57373),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return FavoriteCard(
                  favorite: favorites[index],
                  onRemove: () => _removeFavorite(favorites[index].favoriteId),
                  onTap: () {
                    // TODO: Navigate ke detail page dengan merchandise data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Buka detail: ${favorites[index].merchandise.name}'),
                        backgroundColor: const Color(0xFF8B4513),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}