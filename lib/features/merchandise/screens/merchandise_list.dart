// Import uang diperlukan
import 'package:flutter/material.dart';
import '../models/merchandise_entry.dart';
import '../screens/merchandise_detail.dart';
import '../screens/merchandise_form.dart';
import '../widgets/merchandise_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Widget StatefulWidget untuk halaman daftar merchandise
class MerchandiseEntryListPage extends StatefulWidget {
  final String? currentUserId; // ID user yang sedang login (opsional)
  final String? currentUserRole; // Role user (contoh: 'seller')

  // Constructor dengan parameter opsional untuk user ID dan role
  const MerchandiseEntryListPage({
    Key? key,
    this.currentUserId,
    this.currentUserRole,
  }) : super(key: key);

  // Method untuk membuat state dari widget ini
  @override
  State<MerchandiseEntryListPage> createState() =>
      _MerchandiseEntryListPageState();
}

// State class untuk MerchandiseEntryListPage
class _MerchandiseEntryListPageState extends State<MerchandiseEntryListPage> {
  // Method async untuk mengambil data merchandise dari server
  Future<List<MerchandiseEntry>> fetchMerchandise(CookieRequest request) async {
    try {
      // URL endpoint untuk mengambil data merchandise dalam format JSON
      final url = 'http://localhost:8000/merchandise/json/';

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
          listMerchandise.add(MerchandiseEntry.fromJson(d));
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
    // Mengecek apakah user adalah seller
    final isSeller = widget.currentUserRole == 'seller';

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
        future: fetchMerchandise(request), // Memanggil method fetch data
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
                        // Trigger rebuild agar FutureBuilder memanggil ulang fetch
                        setState(() {});
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
              // Cara sederhana refresh: rebuild agar FutureBuilder memanggil fetch lagi
              setState(() {});
              // Delay kecil agar refresh indicator terlihat sebentar
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
                          ElevatedButton(
                            onPressed: () {
                              // Navigasi ke halaman form merchandise
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MerchandiseFormPage(),
                                ),
                              );
                            },
                            // Style tombol
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Sudut melengkung
                              ),
                              elevation: 2, // Bayangan tombol
                            ),
                            child: const Text('+ Create'),
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
                      return GestureDetector(
                        onTap: () async {
                          // Navigasi ke halaman detail merchandise
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(merchandise: m),
                            ),
                          );
                          setState(() {});
                        },
                        // Widget card merchandise
                        child: MerchandiseEntryCard(
                          merchandise: m,
                          onTap: () async {
                            // Callback saat card di-tap
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(merchandise: m),
                              ),
                            );
                            setState(() {});
                          },
                        ),
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
