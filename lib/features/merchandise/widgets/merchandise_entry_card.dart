// Import package Flutter Material Design untuk komponen UI
import 'package:flutter/material.dart';
// Import model MerchandiseEntry untuk struktur data merchandise
import '../models/merchandise_entry.dart';

// Widget StatelessWidget untuk menampilkan card merchandise
// Card ini menampilkan informasi produk seperti gambar, nama, harga, rating, dan stok
class MerchandiseEntryCard extends StatelessWidget {
  final MerchandiseEntry merchandise; // Data merchandise yang akan ditampilkan
  final VoidCallback? onTap; // Callback saat card di-tap (opsional)
  final void Function(String id)? onEdit; // Callback untuk edit merchandise (opsional)
  final void Function(String id)? onDelete; // Callback untuk delete merchandise (opsional)
  final String? currentUserId; // ID user yang sedang login (opsional, untuk cek owner)
  final String? currentUserRole; // Role user yang sedang login (opsional, untuk cek seller)

  // Constructor dengan parameter required untuk merchandise dan opsional untuk callbacks
  const MerchandiseEntryCard({
    super.key,
    required this.merchandise,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentUserId,
    this.currentUserRole,
  });

  // Getter untuk mengecek apakah user adalah pemilik merchandise
  bool get _isOwner {
    // Cek apakah currentUserId sama dengan user ID pemilik merchandise
    try {
      // Ambil user ID pemilik dari data merchandise
      final owner = merchandise.fields.user?.toString();
      // Jika owner null, return false
      if (owner == null) return false;
      // Return true jika currentUserId sama dengan owner
      return currentUserId != null && currentUserId == owner;
    } catch (_) {
      // Jika terjadi error, return false
      return false;
    }
  }

  // Getter untuk mengecek apakah user bisa edit atau delete
  // User bisa edit/delete jika dia adalah owner atau memiliki role 'seller'
  bool get _canEditOrDelete => _isOwner || (currentUserRole == 'seller');

  // Method untuk memformat harga menjadi format Rupiah
  String _formatPrice(dynamic price) {
    // Format harga dengan pemisah ribuan (titik) dan prefix 'Rp '
    try {
      // Konversi price ke integer, handle jika tipe data num atau string
      final p = price is num ? price.toInt() : int.parse(price.toString());
      // Format dengan regex untuk menambahkan titik sebagai pemisah ribuan
      final formatted = p.toString().replaceAllMapped(
        RegExp(r"\B(?=(\d{3})+(?!\d))"),
        (m) => '.', // Ganti dengan titik
      );
      // Return dengan prefix 'Rp '
      return 'Rp $formatted';
    } catch (_) {
      // Jika terjadi error parsing, return format sederhana
      return 'Rp ${price ?? ''}';
    }
  }

  // Method untuk membangun widget bintang rating
  Widget _buildStars(double rating) {
    // Hitung jumlah bintang penuh (bulat ke bawah)
    final full = rating.floor();
    // Cek apakah ada setengah bintang (jika desimal >= 0.5)
    final half = (rating - full) >= 0.5;
    // Hitung jumlah bintang kosong (total 5 bintang)
    final empty = 5 - full - (half ? 1 : 0);
    // List untuk menampung widget bintang
    List<Widget> stars = [];
    // Tambahkan bintang penuh sebanyak 'full'
    for (var i = 0; i < full; i++)
      stars.add(const Icon(Icons.star, size: 14, color: Colors.amber));
    // Tambahkan setengah bintang jika ada
    if (half)
      stars.add(const Icon(Icons.star_half, size: 14, color: Colors.amber));
    // Tambahkan bintang kosong sebanyak 'empty'
    for (var i = 0; i < empty; i++)
      stars.add(const Icon(Icons.star_border, size: 14, color: Colors.amber));
    // Return Row berisi semua bintang
    return Row(children: stars, mainAxisSize: MainAxisSize.min);
  }

  // Method untuk membangun widget badge (label kecil dengan background)
  Widget _badge(String text, Color bg, Color fg, {IconData? icon}) {
    return Container(
      // Padding dalam badge
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      // Dekorasi badge dengan background color dan border radius
      decoration: BoxDecoration(
        color: bg, // Background color
        borderRadius: BorderRadius.circular(20), // Sudut melengkung
      ),
      // Konten badge: icon (opsional) dan text
      child: Row(
        mainAxisSize: MainAxisSize.min, // Row hanya sebesar kontennya
        children: [
          // Tampilkan icon jika disediakan
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg), // Icon dengan warna foreground
            const SizedBox(width: 6), // Spacing antara icon dan text
          ],
          // Text badge
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg, // Warna foreground untuk text
            ),
          ),
        ],
      ),
    );
  }

  // Method build untuk membangun UI widget card
  @override
  Widget build(BuildContext context) {
    // Ambil fields dari merchandise untuk akses lebih mudah
    final f = merchandise.fields;
    // Extract dan assign fields dengan null safety
    final thumbnail = f.thumbnail?.isNotEmpty == true ? f.thumbnail : null; // URL gambar thumbnail
    final name = f.name ?? 'Unknown Product'; // Nama produk (default jika null)
    final category = (f.category ?? 'Others').toString(); // Kategori produk
    final priceText = _formatPrice(f.price ?? 0); // Harga terformat dalam Rupiah
    final rating = 0.0; // Rating produk (placeholder karena belum ada di model)
    final stock = f.stock ?? 0; // Jumlah stok
    final productViews = f.productViews ?? 0; // Jumlah views produk
    final isFeatured = f.isFeatured ?? false; // Flag apakah produk featured

    // Ambil theme dan color scheme dari context
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Build card dengan struktur utama
    return Card(
      color: Colors.white, // Background putih
      elevation: 2, // Bayangan card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Sudut melengkung
      clipBehavior: Clip.antiAlias, // Agar child widget terpotong sesuai border card
      // InkWell untuk membuat card clickable dengan ripple effect
      child: InkWell(
        onTap: onTap, // Callback saat card di-tap
        // Column untuk menyusun konten card secara vertikal
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align ke kiri
          children: [
            // Area gambar produk dengan badges overlay
            SizedBox(
              height: 150, // Tinggi area gambar tetap
              child: Stack(
                children: [
                  // Positioned.fill: gambar memenuhi seluruh area
                  Positioned.fill(
                    child: thumbnail != null && thumbnail.isNotEmpty
                        // Jika ada thumbnail, tampilkan gambar dari network
                        ? Image.network(thumbnail, fit: BoxFit.cover)
                        // Jika tidak ada thumbnail, tampilkan placeholder
                        : Container(
                            color: cs.secondary.withOpacity(0.1),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: cs.primary,
                            ),
                          ),
                  ),
                  // Badge kategori di pojok kiri atas
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _badge(
                      category[0].toUpperCase() + category.substring(1), // Capitalize huruf pertama
                      cs.secondary, // Background color
                      cs.onSecondary, // Foreground color
                    ),
                  ),
                  // Badge featured dan hot di pojok kanan atas
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Badge 'Featured' jika produk featured
                        if (isFeatured)
                          _badge(
                            'Featured',
                            cs.primary.withOpacity(0.15), // Background transparan
                            cs.primary, // Foreground color primary
                            icon: Icons.star, // Icon bintang
                          ),
                        // Badge 'Hot' jika produk punya banyak views
                        if (productViews > 30) ...[
                          const SizedBox(height: 6), // Spacing
                          _badge(
                            'Hot',
                            cs.error.withOpacity(0.15), // Background transparan merah
                            cs.error, // Foreground color merah
                            icon: Icons.whatshot, // Icon api
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Area konten produk (di bawah gambar)
            Padding(
              padding: const EdgeInsets.all(12.0), // Padding sekeliling konten
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align ke kiri
                children: [
                  // Nama produk
                  Text(
                    name,
                    maxLines: 2, // Maksimal 2 baris
                    overflow: TextOverflow.ellipsis, // Tambahkan '...' jika terlalu panjang
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Bold
                    ),
                  ),

                  const SizedBox(height: 8), // Spacing

                  // Harga produk
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB91C1C), // Warna merah untuk harga
                    ),
                  ),

                  const SizedBox(height: 8), // Spacing

                  // Baris rating dan stok produk
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center, // Center vertikal
                    spacing: 8, // Jarak horizontal antar child
                    runSpacing: 2, // Jarak vertikal jika wrap ke baris baru
                    children: [
                      // Widget bintang rating
                      _buildStars(rating),
                      const SizedBox(width: 8), // Spacing
                      // Angka rating
                      Text(
                        (rating).toStringAsFixed(1), // Format 1 desimal
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8), // Spacing
                      // Bullet separator
                      const Text('•'),
                      const SizedBox(width: 8), // Spacing
                      // Text jumlah stok
                      Text(
                        '$stock in stock',
                        style: const TextStyle(
                          color: Colors.grey, // Warna abu-abu
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12), // Spacing

                  // Action buttons (Edit dan Delete) - hanya tampil jika user punya permission
                  if (_canEditOrDelete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Align ke kanan
                      children: [
                        // Tombol Edit
                        TextButton(
                          onPressed: () =>
                              onEdit?.call(currentUserId.toString()), // Panggil callback onEdit
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.blueAccent), // Warna biru
                          ),
                        ),
                        const SizedBox(width: 8), // Spacing antar tombol
                        // Tombol Delete
                        TextButton(
                          onPressed: () =>
                              onDelete?.call(currentUserId.toString()), // Panggil callback onDelete
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent), // Warna merah
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
