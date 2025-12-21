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
  final MerchandiseEntry? initial; // data awal saat edit
  final bool isEdit; // true jika mode edit

  const MerchandiseFormPage({
    super.key,
    this.initial,
    this.isEdit = false,
  });

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
  bool _submitting = false; // State untuk loading saat submit
  @override
  void initState() {
    super.initState();
    // Prefill bila mode edit
    final initial = widget.initial;
    if (initial != null) {
      _name = initial.fields.name;
      _price = initial.fields.price;
      _category = initial.fields.category;
      _stock = initial.fields.stock;
      _thumbnail = initial.fields.thumbnail;
      // Server menyimpan <br>; convert jadi \n agar nyaman di form
      _description = initial.fields.description
          .replaceAll('<br>', '\n')
          .replaceAll('br>', '\n')
          .replaceAll('<br', '\n');
      _productViews = initial.fields.productViews;
      _isFeatured = initial.fields.isFeatured;
    }
  }

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
                                  initialValue: _name,
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
                                  initialValue: _price == 0 ? '' : _price.toString(),
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
                                  initialValue: _stock == 0 ? '' : _stock.toString(),
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
                                      onPressed: _submitting
                                          ? null
                                          : () async {
                                        // Validasi form sebelum submit
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _submitting = true);
                                          try {
                                            // Tentukan URL berdasarkan mode (create/edit)
                                            final url = widget.isEdit && widget.initial != null
                                                ? "https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/merchandise/edit/${widget.initial!.pk}/"
                                                : "https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/merchandise/create/";

                                            // Kirim sebagai form-encoded agar sesuai dengan request.POST di Django
                                            final response = await request.post(
                                              url,
                                              {
                                                "name": _name,
                                                "price": _price.toString(),
                                                "category": _category ?? '',
                                                "stock": _stock.toString(),
                                                "thumbnail": _thumbnail,
                                                // Django view membaca string 'true'/'false'
                                                "is_featured": _isFeatured.toString(),
                                                // Simpan line break sebagai <br> agar konsisten dengan server-side replace
                                                "description": _description.replaceAll('\n', '<br>'),
                                              },
                                            );

                                            if (!mounted) return;
                                            final success = (response is Map &&
                                                    (response['status'] == 'success' ||
                                                        response['message'] != null)) ||
                                                response != null;

                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(widget.isEdit
                                                      ? "Merchandise berhasil diperbarui!"
                                                      : "Merchandise berhasil disimpan!"),
                                                ),
                                              );
                                              // Kembali ke list dengan flag sukses agar list refresh
                                              Navigator.pop(context, true);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Terjadi kesalahan, silakan coba lagi.",
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Gagal menyimpan: $e"),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) setState(() => _submitting = false);
                                          }
                                        }
                                      },
                                      child: _submitting
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                              ),
                                            )
                                          : const Text(
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
