import 'package:flutter/material.dart';
import '../models/merchandise_entry.dart';
import '../screens/merchandise_detail.dart';
import '../widgets/merchandise_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MerchandiseEntryListPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserRole; // e.g., 'seller'

  const MerchandiseEntryListPage({
    Key? key,
    this.currentUserId,
    this.currentUserRole,
  }) : super(key: key);

  @override
  State<MerchandiseEntryListPage> createState() =>
      _MerchandiseEntryListPageState();
}

class _MerchandiseEntryListPageState extends State<MerchandiseEntryListPage> {
  Future<List<MerchandiseEntry>> fetchMerchandise(CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)!
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000

    try {
      final url = 'http://localhost:8000/merchandise/json/';

      final response = await request.get(url);

      // DEBUG: cetak tipe dan isi response singkat
      debugPrint(
        'fetchMerchandise response runtimeType: ${response.runtimeType}',
      );
      debugPrint(
        'fetchMerchandise raw response (truncated): ${response.toString().substring(0, response.toString().length.clamp(0, 200))}',
      );

      List rawList = [];

      if (response == null) {
        throw Exception('Empty response from server');
      } else if (response is List) {
        rawList = response;
      } else if (response is Map) {
        // Cek beberapa struktur umum: results / data / items
        if (response.containsKey('results') && response['results'] is List) {
          rawList = response['results'];
        } else if (response.containsKey('data') && response['data'] is List) {
          rawList = response['data'];
        } else {
          // Jika server mengembalikan map per-item, coba bungkus jadi list
          // atau kalau format lain, lempar error supaya caller tahu
          throw Exception(
            'Unexpected JSON structure: Map but no results/data key',
          );
        }
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      // Convert json data to MerchandiseEntry objects
      List<MerchandiseEntry> listMerchandise = [];
      for (var d in rawList) {
        if (d != null) {
          listMerchandise.add(MerchandiseEntry.fromJson(d));
        } else {
          debugPrint('Skipping non-map item: $d');
        }
      }
      return listMerchandise;
    } catch (e, st) {
      debugPrint('fetchMerchandise error: $e\n$st');
      // Agar UI menampilkan error, lempar ulang exception
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isSeller = widget.currentUserRole == 'seller';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise List'),
        centerTitle: false,
        elevation: 0,
      ),
      body: FutureBuilder<List<MerchandiseEntry>>(
        future: fetchMerchandise(request),
        builder: (context, snapshot) {
          // 1) Loading
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

          // 2) Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load merchandises',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // trigger rebuild so FutureBuilder re-calls fetch
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

          // 3) Data ready but empty
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.sports_soccer, size: 86, color: Color(0xFFE65B4D)),
                  SizedBox(height: 12),
                  Text(
                    'No Merchandise Found',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please wait until Timnas's Merchandise is available.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // 4) Data ready and non-empty
          return RefreshIndicator(
            onRefresh: () async {
              // simple way to refresh: rebuild so FutureBuilder calls fetch again
              setState(() {});
              // small delay so refresh indicator is visible for a bit
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD4CE), Color(0xFFD998A0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'Support Your Nation,\nWear Your Passion !',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Merchandise resmi Timnas Indonesia,\ndimana setiap purchase mendukung perkembangan sepak bola tanah air.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Title row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latest Products',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Stay updated with the newest Timnas's Merchandise",
                              ),
                            ],
                          ),
                        ),
                        // create button (only visible for sellers) - small and unobtrusive
                        if (isSeller)
                          ElevatedButton(
                            onPressed: () {
                              // placeholder: you might open create modal here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text('+ Create'),
                          ),
                      ],
                    ),
                  ),
                ),
                // Grid of merchandise
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final m = data[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(merchandise: m),
                            ),
                          );
                        },
                        child: MerchandiseEntryCard(
                          merchandise: m,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(merchandise: m),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: data.length),
                  ),
                ),

                // bottom padding to allow last cards space
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon);
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan title dan content.

  final String title; // Judul kartu.
  final String content; // Isi kartu.

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Membuat kotak kartu dengan bayangan dibawahnya.
      elevation: 2.0,
      child: Container(
        // Mengatur ukuran dan jarak di dalam kartu.
        width:
            MediaQuery.of(context).size.width /
            3.5, // menyesuaikan dengan lebar device yang digunakan.
        padding: const EdgeInsets.all(16.0),
        // Menyusun title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}
