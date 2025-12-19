import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/features/merchandise/screens/merchandise_list.dart';
import '../models/merchandise_entry.dart';

// Widget StatefulWidget untuk halaman form merchandise
// Form ini digunakan untuk menambahkan produk merchandise baru
class MerchandiseFormPage extends StatefulWidget {
  const MerchandiseFormPage({super.key});

  // Method untuk membuat state dari widget ini
  @override
  State<MerchandiseFormPage> createState() => _MerchandiseFormPageState();
}

// State class untuk MerchandiseFormPage
class _MerchandiseFormPageState extends State<MerchandiseFormPage> {
  // Global key untuk form validation
  final _formKey = GlobalKey<FormState>();

  // State variables untuk menyimpan input user
  String _name = ''; // Nama produk
  int _price = 0; // Harga produk
  String? _category; // Kategori produk (nullable)
  int _stock = 0; // Jumlah stok
  String _thumbnail = ''; // URL thumbnail produk
  String _description = ''; // Deskripsi produk
  int _productViews = 0; // Jumlah views produk
  bool _isFeatured = false; // Flag apakah produk featured

  // List kategori produk yang tersedia untuk dropdown
  final List<String> _categories = [
    'jersey', // Jersey tim
    'training jersey', // Jersey latihan
    'top', // Atasan
    'jacket', // Jaket
    'hoodie', // Hoodie/jaket bertudung
    'sweatshirt', // Baju hangat
    'vest', // Rompi
    'socks', // Kaus kaki
    'ball', // Bola
    'bag', // Tas
    'tumbler', // Botol minum
    'action figure', // Mainan figur
    'accessories', // Aksesoris
    'others', // Lainnya
  ];

  // Method build untuk membangun UI form
  @override
  Widget build(BuildContext context) {
    // Mengambil CookieRequest dari Provider untuk autentikasi
    final request = context.watch<CookieRequest>();
    // Mengembalikan widget Scaffold sebagai struktur utama halaman
    return Scaffold(
      // SafeArea untuk menghindari area sistem (notch, status bar, dll)
      body: SafeArea(
        // SingleChildScrollView agar form bisa di-scroll
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol kembali ke halaman sebelumnya
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        "Kembali ke Halaman Merchandise",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // card utama untuk form input
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // header untuk judul
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        // hanya atas yang circular bawah tidak
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Membuat Merchandise Baru",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Isi form di bawah untuk menambahkan produk merchandise baru",
                              style: TextStyle(
                                color: Colors.white, // Putih agak transparan
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // form input di container putih bawah deskripsi
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // input Nama produk
                                const Text("Nama Merchandise"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan nama produk...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _name = value!; // yakin tidak null
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama merchandise tidak boleh kosong!';
                                    }
                                    if (value.length > 255) {
                                      return 'Nama merchandise tidak boleh lebih dari 255 karakter!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // Input field untuk harga produk
                                const Text("Harga"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Harga Produk...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  // Callback saat nilai berubah
                                  onChanged: (String? value) {
                                    setState(() {
                                      _price = int.tryParse(value ?? '0') ?? 0;
                                    });
                                  },
                                  // Validator untuk validasi input
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Harga produk tidak boleh kosong!';
                                    }

                                    final parsed = int.tryParse(value);
                                    if (parsed == null) {
                                      return 'Harga harus berupa angka!';
                                    }

                                    if (parsed <= 0) {
                                      return 'Harga harus lebih dari 0!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // input category produk
                                const Text("Kategori"),
                                SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  decoration: InputDecoration(
                                    hintText: "Pilih Kategori Produk...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),

                                  items: _categories.map((String item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),

                                  onChanged: (String? value) {
                                    setState(() {
                                      _category = value;
                                    });
                                  },

                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Kategori produk tidak boleh kosong!';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 16),

                                // Input field untuk stok produk
                                const Text("Stok"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Stok Produk...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  // Callback saat nilai berubah
                                  onChanged: (String? value) {
                                    setState(() {
                                      _stock = int.tryParse(value ?? '0') ?? 0;
                                    });
                                  },
                                  // Validator untuk validasi input
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Stok produk tidak boleh kosong!';
                                    }

                                    final parsed = int.tryParse(value);
                                    if (parsed == null) {
                                      return 'Stok harus berupa angka!';
                                    }

                                    if (parsed <= 0) {
                                      return 'Stok harus lebih dari 0!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // THUMBNAIL
                                const Text("Thumbnail URL"),
                                SizedBox(height: 4),
                                TextFormField(
                                  initialValue: _thumbnail,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan URL thumbnail...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _thumbnail = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 16),

                                // DESCRIPTION
                                const Text("Description"),
                                SizedBox(height: 4),
                                TextFormField(
                                  initialValue: _description,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan deskripsi produk...",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFBDBDBD),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xE6E6E6E6),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _description = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Deskripsi tidak boleh kosong!";
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // IS FEATURED (SWITCH)
                                Row(
                                  children: [
                                    Expanded(child: Text("Featured Product")),
                                    Switch(
                                      value: _isFeatured,
                                      onChanged: (value) {
                                        setState(() {
                                          _isFeatured = value;
                                        });
                                      },
                                      activeColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 15),
                                Divider(thickness: 1, color: Colors.grey[300]),
                                SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                      ),
                                      onPressed: () async {
                                        // Validasi form sebelum submit
                                        if (_formKey.currentState!.validate()) {
                                          // Kirim data ke backend dengan POST request
                                          final response = await request.postJson(
                                            "http://localhost:8000/create-flutter/",
                                            jsonEncode({
                                              "name": _name,
                                              "price": _price,
                                              "category": _category,
                                              "stock": _stock,
                                              "thumbnail": _thumbnail,
                                              "is_featured": _isFeatured,
                                              "description": _description,
                                            }),
                                          );

                                          if (context.mounted) {
                                            if (response['status'] ==
                                                'success') {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Merchandise berhasil disimpan!",
                                                  ),
                                                ),
                                              );
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MerchandiseEntryListPage(),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Terjadi kesalahan, silakan coba lagi.",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: const Text(
                                        "Simpan",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
