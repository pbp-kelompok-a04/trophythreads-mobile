import 'package:flutter/material.dart';
import '../models/merchandise_entry.dart';

/// MerchandiseEntryCard
/// Meniru tampilan kartu merchandise di web: thumbnail (cover), category badge,
/// status badges (Featured/Hot), nama produk, harga, rating, stock,
/// dan tombol Edit/Delete jika user adalah owner atau seller.
class MerchandiseEntryCard extends StatelessWidget {
  final MerchandiseEntry merchandise;
  final VoidCallback? onTap;
  final void Function(String id)? onEdit;
  final void Function(String id)? onDelete;
  final String? currentUserId; // optional, untuk cek owner
  final String? currentUserRole; // optional, untuk cek seller

  const MerchandiseEntryCard({
    super.key,
    required this.merchandise,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentUserId,
    this.currentUserRole,
  });

  bool get _isOwner {
    try {
      final owner = merchandise.fields.user?.toString();
      if (owner == null) return false;
      return currentUserId != null && currentUserId == owner;
    } catch (_) {
      return false;
    }
  }

  bool get _canEditOrDelete => _isOwner || (currentUserRole == 'seller');

  String _formatPrice(dynamic price) {
    try {
      final p = price is num ? price.toInt() : int.parse(price.toString());
      // Simple id format (thousands separator)
      final formatted = p.toString().replaceAllMapped(
        RegExp(r"\B(?=(\d{3})+(?!\d))"),
        (m) => '.',
      );
      return 'Rp $formatted';
    } catch (_) {
      return 'Rp ${price ?? ''}';
    }
  }

  Widget _buildStars(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    final empty = 5 - full - (half ? 1 : 0);
    List<Widget> stars = [];
    for (var i = 0; i < full; i++)
      stars.add(const Icon(Icons.star, size: 14, color: Colors.amber));
    if (half)
      stars.add(const Icon(Icons.star_half, size: 14, color: Colors.amber));
    for (var i = 0; i < empty; i++)
      stars.add(const Icon(Icons.star_border, size: 14, color: Colors.amber));
    return Row(children: stars, mainAxisSize: MainAxisSize.min);
  }

  @override
  Widget build(BuildContext context) {
    final f = merchandise.fields;
    final thumbnail = (f.thumbnail != null && f.thumbnail.isNotEmpty)
        ? 'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(f.thumbnail)}'
        : null;
    final name = f.name ?? 'Unknown Product';
    final category = (f.category ?? 'Others').toString();
    final priceText = _formatPrice(f.price ?? 0);
    final rating = 0.0; // Placeholder, as rating is not in the model
    final stock = f.stock ?? 0;
    final productViews = f.productViews ?? 0;
    final isFeatured = f.isFeatured ?? false;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with badges positioned
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: thumbnail != null
                        ? Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),

                  // Category badge (top-left)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Status badges (top-right)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (productViews > 30)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.whatshot,
                                  size: 12,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Hot',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
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
            // Content area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB91C1C),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating and stock row
                  Row(
                    children: [
                      _buildStars(rating),
                      const SizedBox(width: 8),
                      Text(
                        (rating).toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•'),
                      const SizedBox(width: 8),
                      Text(
                        '$stock in stock',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons (Edit/Delete) if allowed
                  if (_canEditOrDelete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              onEdit?.call(currentUserId.toString()),
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () =>
                              onDelete?.call(currentUserId.toString()),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
