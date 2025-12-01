import 'package:flutter/material.dart';
import '../models/fav_entry.dart';

class FavoriteCard extends StatefulWidget {
  final Favorite favorite;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const FavoriteCard({
    Key? key,
    required this.favorite,
    required this.onRemove,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  bool _isRemoving = false;

  void _handleRemove() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dari Favorites?'),
        content: Text(
          'Hapus "${widget.favorite.merchandise.name}" dari daftar favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isRemoving = true);
              Future.delayed(const Duration(milliseconds: 300), () {
                widget.onRemove();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isRemoving ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductName(),
                      const Spacer(),
                      _buildPrice(),
                      const SizedBox(height: 4),
                      _buildRating(),
                      const SizedBox(height: 4),
                      _buildStock(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              widget.favorite.merchandise.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
              onPressed: _handleRemove,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              tooltip: 'Hapus dari Favorites',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductName() {
    return Text(
      widget.favorite.merchandise.name,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice() {
    return Text(
      'Rp ${widget.favorite.merchandise.price}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B4513),
      ),
    );
  }

  Widget _buildRating() {
    // Rating dummy untuk desain
    const rating = 4;
    const totalReviews = 120;
    
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            Icons.star,
            size: 12,
            color: index < rating ? Colors.orange : Colors.grey[300],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($totalReviews)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStock() {
    // Stock status dummy untuk desain
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Tersedia (50+)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}