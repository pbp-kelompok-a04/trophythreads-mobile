import 'package:flutter/material.dart';
import '../models/fav_entry.dart';
import '../widgets/favorites_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Favorite> favorites = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Data dummy untuk testing UI
    favorites = [
      Favorite(
        favoriteId: '1',
        merchandise: Merchandise(
          merchandiseId: '1',
          name: 'Erigo Timnas 2025 Jersey (Boys/ Short Home LS Men Red)',
          slug: 'erigo-jersey-home-red',
          image: 'https://picsum.photos/400/400?random=1',
          price: '1,299,000',
          description: 'Jersey resmi Timnas Indonesia 2025 untuk anak-anak',
        ),
        createdAt: DateTime.now(),
      ),
      Favorite(
        favoriteId: '2',
        merchandise: Merchandise(
          merchandiseId: '2',
          name: 'Erigo Timnas 2025 Jersey Away Edition',
          slug: 'erigo-jersey-away',
          image: 'https://picsum.photos/400/400?random=2',
          price: '1,199,000',
          description: 'Jersey away Timnas Indonesia 2025',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Favorite(
        favoriteId: '3',
        merchandise: Merchandise(
          merchandiseId: '3',
          name: 'Official Scarf Timnas Indonesia',
          slug: 'timnas-scarf',
          image: 'https://picsum.photos/400/400?random=3',
          price: '250,000',
          description: 'Syal resmi supporter Timnas Indonesia',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Favorite(
        favoriteId: '4',
        merchandise: Merchandise(
          merchandiseId: '4',
          name: 'Timnas Training Kit 2025',
          slug: 'training-kit',
          image: 'https://picsum.photos/400/400?random=4',
          price: '899,000',
          description: 'Pakaian latihan resmi Timnas',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _removeFavorite(String favoriteId) {
    setState(() {
      favorites.removeWhere((fav) => fav.favoriteId == favoriteId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil dihapus dari Favorites'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF8B4513),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE57373),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Favorites',
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Navigate to cart
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigasi ke Cart')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF0F0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
      floatingActionButton: favorites.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _clearAllFavorites,
              backgroundColor: const Color(0xFFE57373),
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Hapus Semua',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF8B4513), width: 2),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 60,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada produk di Favorites',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Silahkan tambahkan produk terlebih\ndahulu...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to merchandise
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke Merchandise')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jelajahi Merchandise',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
            // Navigate to detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Buka detail: ${favorites[index].merchandise.name}'),
              ),
            );
          },
        );
      },
    );
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Favorites?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua produk dari favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                favorites.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua favorites telah dihapus'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}