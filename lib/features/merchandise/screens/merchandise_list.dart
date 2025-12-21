// Import uang diperlukan
import 'package:flutter/material.dart';
import '../models/merchandise_entry.dart';
import '../screens/merchandise_detail.dart';
import '../screens/merchandise_form.dart';
import '../widgets/merchandise_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:trophythreads_mobile/features/review/services/review_service.dart';

// Widget StatefulWidget untuk halaman daftar merchandise
class MerchandiseEntryListPage extends StatefulWidget {
  // Constructor dengan parameter opsional untuk user ID dan role
  const MerchandiseEntryListPage({
    Key? key,
  }) : super(key: key);

  // Method untuk membuat state dari widget ini
  @override
  State<MerchandiseEntryListPage> createState() =>
      _MerchandiseEntryListPageState();
}

// State class untuk MerchandiseEntryListPage
class _MerchandiseEntryListPageState extends State<MerchandiseEntryListPage> {
  late Future<List<MerchandiseEntry>> _futureMerchandise;
  Key _futureBuilderKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  void _initFuture() {
    final request = context.read<CookieRequest>();
    _futureMerchandise = fetchMerchandise(request);
    // Force rebuild FutureBuilder dengan UniqueKey
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  // Method untuk increment views saat user masuk ke detail page
  Future<void> _incrementViews(CookieRequest request, String productId) async {
    final String url = 'https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/merchandise/views/increment/$productId/';

    try {
      debugPrint('Attempting to increment views at: $url');
      final response = await request.post(url, {});
      debugPrint('Increment views response type: ${response.runtimeType}');
      debugPrint('Increment views response: $response');
      
      if (response is Map && response.containsKey('status')) {
        debugPrint('Success: ${response['status']}');
      }
    } catch (e, st) {
      debugPrint('Error incrementing views: $e');
      debugPrint('Stack trace: $st');
    }
  }

  // Ambil average rating untuk sebuah produk dari ReviewService
  Future<double> _fetchAverageRating(
      CookieRequest request, String productId) async {
    try {
      final service = ReviewService(request);
      final reviewEntry = await service.fetchReviews(
        productId: productId,
        stars: 'all',
      );

      if (reviewEntry.total == 0) return 0.0;
      int sum = 0;
      reviewEntry.counts.forEach((star, count) {
        sum += int.parse(star) * count;
      });
      return sum / reviewEntry.total;
    } catch (e) {
      debugPrint('fetchAverageRating error: $e');
      return 0.0;
    }
  }

  // Method async untuk mengambil data merchandise dari server
  Future<List<MerchandiseEntry>> fetchMerchandise(CookieRequest request) async {
    try {
      // URL endpoint untuk mengambil data merchandise dalam format JSON
      final url = 'https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/merchandise/json/';

      // Melakukan HTTP GET request ke server
      final response = await request.get(url);

      // DEBUG: Mencetak tipe data response untuk debugging
      debugPrint(
        'fetchMerchandise response runtimeType: ${response.runtimeType}',
      );
      // DEBUG: Mencetak isi response yang dipotong untuk debugging
      debugPrint(
        'fetchMerchandise raw response (truncated): ${response.toString().substring(0, response.toString().length.clamp(0, 200))}',
      );

      // List untuk menampung data mentah dari response
      List rawList = [];

      // Mengecek dan memproses berbagai format response
      if (response == null) {
        // Jika response kosong, lempar exception
        throw Exception('Empty response from server');
      } else if (response is List) {
        // Jika response langsung berupa List, gunakan langsung
        rawList = response;
      } else if (response is Map) {
        // Cek beberapa struktur umum: results / data / items
        if (response.containsKey('results') && response['results'] is List) {
          // Jika response berisi key 'results', ambil data dari sana
          rawList = response['results'];
        } else if (response.containsKey('data') && response['data'] is List) {
          // Jika response berisi key 'data', ambil data dari sana
          rawList = response['data'];
        } else {
          // Jika server mengembalikan map per-item atau format lain,
          // lempar error supaya caller tahu struktur tidak didukung
          throw Exception(
            'Unexpected JSON structure: Map but no results/data key',
          );
        }
      } else {
        // Jika tipe response tidak dikenali, lempar exception
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      // Konversi data JSON menjadi objek MerchandiseEntry
      List<MerchandiseEntry> listMerchandise = [];
      // Loop melalui setiap item di rawList
      for (var d in rawList) {
        if (d != null) {
          // Jika item tidak null, konversi ke MerchandiseEntry dan tambahkan ke list
          try {
            // Bentuk 1: JSON default Django serializer -> memiliki key 'fields'
            if (d is Map && d.containsKey('fields')) {
              listMerchandise.add(MerchandiseEntry.fromJson(Map<String, dynamic>.from(d)));
            } else if (d is Map && (d.containsKey('id') || d.containsKey('pk'))) {
              // Bentuk 2: JSON custom flat -> ubah ke bentuk serializer
              final map = Map<String, dynamic>.from(d);
              final pk = (map['pk'] ?? map['id']).toString();
              final converted = {
                'model': 'merchandiseApp.merchandise',
                'pk': pk,
                'fields': {
                  'user': map['user'],
                  'name': map['name'] ?? '',
                  'price': map['price'] ?? 0,
                  'category': map['category'] ?? 'others',
                  'stock': map['stock'] ?? 0,
                  'thumbnail': map['thumbnail'] ?? '',
                  'description': map['description'] ?? '',
                  'product_views': map['product_views'] ?? 0,
                  'is_featured': map['is_featured'] ?? false,
                },
              };
              listMerchandise.add(MerchandiseEntry.fromJson(Map<String, dynamic>.from(converted)));
            } else {
              debugPrint('Skipping unknown item shape: $d');
            }
          } catch (e) {
            debugPrint('Error parsing item: $e');
          }
        } else {
          // Jika item null, skip dan cetak peringatan
          debugPrint('Skipping non-map item: $d');
        }
      }
      // Kembalikan list merchandise yang sudah dikonversi
      return listMerchandise;
    } catch (e, st) {
      // Tangkap error dan cetak stack trace untuk debugging
      debugPrint('fetchMerchandise error: $e\n$st');
      // Agar UI menampilkan error, lempar ulang exception
      rethrow;
    }
  }

  // Method build untuk membangun UI widget
  @override
  Widget build(BuildContext context) {
    // Mengambil CookieRequest dari Provider untuk autentikasi
    final request = context.watch<CookieRequest>();
    // Ambil user info dari jsonData (sama seperti forum)
    final userRole = request.jsonData['role']?.toString();
    final userId = request.jsonData['id']?.toString();
    // Mengecek apakah user adalah seller
    final isSeller = userRole == 'seller';

    // Mengembalikan widget Scaffold sebagai struktur utama halaman
    return Scaffold(
      // AppBar di bagian atas halaman
      appBar: AppBar(
        title: const Text('Merchandise List'),
        centerTitle: false, // Judul tidak di tengah
        elevation: 0, // Tidak ada bayangan AppBar
      ),
      // Body menggunakan FutureBuilder untuk menangani async data
      body: FutureBuilder<List<MerchandiseEntry>>(
        key: _futureBuilderKey,
        future: _futureMerchandise, // Menggunakan future yang sudah disimpan
        builder: (context, snapshot) {
          // 1) State Loading: tampilkan loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(strokeWidth: 5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Merchandises',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "We're gathering the latest Timnas's Merchandise for you...",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // 2) State Error: tampilkan pesan error
          if (snapshot.hasError) {
            // Widget Center untuk menempatkan error message di tengah
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon error
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12), // Spacing
                    // Teks judul error
                    Text(
                      'Failed to load merchandises',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8), // Spacing
                    // Teks detail error dari snapshot
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12), // Spacing
                    // Tombol untuk mencoba ulang
                    ElevatedButton.icon(
                      onPressed: () {
                        // Reload data dari server
                        setState(() {
                          _initFuture();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(elevation: 2),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3) State Data ready tapi kosong
          final data =
              snapshot.data ?? []; // Ambil data atau list kosong jika null
          if (data.isEmpty) {
            // Jika data kosong, tampilkan empty state
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // Icon bola untuk empty state
                  Icon(Icons.sports_soccer, size: 86, color: Color(0xFFE65B4D)),
                  SizedBox(height: 12), // Spacing
                  // Teks judul empty state
                  Text(
                    'No Merchandise Found',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8), // Spacing
                  // Teks deskripsi empty state
                  Text(
                    "Please wait until Timnas's Merchandise is available.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // 4) State Data ready dan tidak kosong: tampilkan list merchandise
          return RefreshIndicator(
            // Callback saat user melakukan pull-to-refresh
            onRefresh: () async {
              // Reload data dari server
              _initFuture();
              await Future.delayed(const Duration(milliseconds: 300));
            },
            // CustomScrollView untuk scrolling yang lebih fleksibel dengan slivers
            child: CustomScrollView(
              slivers: [
                // Sliver 1: Header banner dengan informasi promo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      width: double.infinity, // Lebar penuh
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      // Dekorasi container dengan gradient background
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 186, 177),
                            Color.fromARGB(255, 211, 90, 104),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Sudut melengkung
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8, // Bayangan halus
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          // Teks judul banner
                          Text(
                            'Support Your Nation,\nWear Your Passion !',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10), // Spacing
                          // Teks deskripsi banner
                          Text(
                            "Merchandise resmi Timnas Indonesia,\ndimana setiap purchase mendukung perkembangan sepak bola tanah air.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sliver 2: Title row dengan judul dan tombol create
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Kolom kiri berisi judul dan deskripsi
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Teks judul section
                              Text(
                                'Latest Products',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4), // Spacing
                              // Teks deskripsi section
                              Text(
                                "Stay updated with the newest Timnas's Merchandise",
                              ),
                            ],
                          ),
                        ),
                        // Tombol create (hanya tampil untuk seller)
                        if (isSeller)
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 121, 100),
                                  Color.fromARGB(255, 173, 26, 0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 231, 39, 9)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  // Navigasi ke halaman form merchandise
                                  final created = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MerchandiseFormPage(),
                                    ),
                                  );
                                  // Refresh list jika form sukses menyimpan
                                  if (created == true) {
                                    _initFuture();
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Create Merchandise',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Sliver 3: Grid layout untuk menampilkan daftar merchandise
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  sliver: SliverGrid(
                    // Delegate untuk mengatur layout grid
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 kolom
                          mainAxisSpacing: 12, // Jarak vertikal antar item
                          crossAxisSpacing: 12, // Jarak horizontal antar item
                          childAspectRatio:
                              0.6, // Rasio tinggi/lebar item (card vertikal)
                        ),
                    // Delegate untuk membangun child widgets
                    delegate: SliverChildBuilderDelegate((context, index) {
                      // Ambil data merchandise di index ini
                      final m = data[index];
                      // Wrap card dengan GestureDetector untuk handle tap
                      return FutureBuilder<double>(
                        future: _fetchAverageRating(request, m.pk),
                        builder: (context, ratingSnap) {
                          final avg = ratingSnap.data ?? 0.0;
                          return GestureDetector(
                            onTap: () async {
                              // Increment views saat user masuk ke detail page
                              _incrementViews(request, m.pk);
                              
                              // Navigasi ke halaman detail merchandise
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(merchandise: m),
                                ),
                              );
                              // Reload data setelah kembali dari detail page
                              _initFuture();
                            },
                            // Widget card merchandise
                            child: MerchandiseEntryCard(
                              merchandise: m,
                              currentUserId: userId,
                              currentUserRole: userRole,
                              averageRating: avg,
                              onEdit: (id) async {
                                // Buka form dalam mode edit dengan data awal
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MerchandiseFormPage(
                                      initial: m,
                                      isEdit: true,
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  _initFuture();
                                }
                              },
                              onDelete: (id) async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Merchandise'),
                                    content: const Text(
                                        'Are you sure you want to delete this merchandise?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    final url = 'https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/merchandise/delete/$id/';
                                    // CookieRequest tidak memiliki method DELETE di sebagian versi,
                                    // sehingga kita coba via POST (server @csrf_exempt dapat menyesuaikan)
                                    final resp = await request.post(url, {});
                                    if (resp is Map && (resp['message'] != null || resp['status'] == 'success')) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Deleted successfully.')),
                                      );
                                      _initFuture();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Delete failed. Please try again.')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Delete error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      );
                    }, childCount: data.length), // Jumlah item sesuai data
                  ),
                ),

                // Sliver 4: Padding bawah agar card terakhir punya ruang
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Class model untuk item homepage (mungkin digunakan di tempat lain)
class ItemHomepage {
  final String name; // Nama item
  final IconData icon; // Icon item

  // Constructor
  ItemHomepage(this.name, this.icon);
}

// Widget StatelessWidget untuk menampilkan kartu informasi
class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan title dan content.

  final String title; // Judul kartu
  final String content; // Isi/konten kartu

  // Constructor dengan required parameters
  const InfoCard({super.key, required this.title, required this.content});

  // Method build untuk membangun UI widget
  @override
  Widget build(BuildContext context) {
    return Card(
      // Membuat kotak kartu dengan bayangan di bawahnya
      elevation: 2.0,
      child: Container(
        // Mengatur ukuran dan jarak di dalam kartu
        width:
            MediaQuery.of(context).size.width /
            3.5, // Menyesuaikan dengan lebar device yang digunakan
        padding: const EdgeInsets.all(16.0),
        // Menyusun title dan content secara vertikal dengan Column
        child: Column(
          children: [
            // Teks judul dengan bold
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0), // Spacing
            // Teks konten
            Text(content),
          ],
        ),
      ),
    );
  }
}
