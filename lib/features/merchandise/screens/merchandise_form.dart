import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/merchandise_entry.dart';

class MerchandiseFormPage extends StatefulWidget {
  const MerchandiseFormPage({super.key});

  @override
  State<MerchandiseFormPage> createState() => _MerchandiseFormPageState();
}

class _MerchandiseFormPageState extends State<MerchandiseFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _price = 0;
  String? _category;
  int _stock = 0;
  String _thumbnail = '';
  String _description = '';
  int _productViews = 0;
  bool _isFeatured = false;

  final List<String> _categories = [
    'jersey',
    'training jersey',
    'top',
    'jacket',
    'hoodie',
    'sweatshirt',
    'vest',
    'socks',
    'ball',
    'bag',
    'tumbler',
    'action figure',
    'accessories',
    'others',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back ke halaman sebelumnya
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

                                // input harga produk
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

                                // input stok produk
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
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Merchandise berhasil disimpan!',
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Judul: $_name'),
                                                      Text('Price: $_price'),
                                                      Text(
                                                        'Kategori: $_category',
                                                      ),
                                                      Text('Stock: $_stock'),
                                                      Text(
                                                        'Thumbnail: $_thumbnail',
                                                      ),
                                                      Text(
                                                        'Description: $_description',
                                                      ),
                                                      Text(
                                                        'is Featured: $_isFeatured',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _formKey.currentState!
                                                            .reset();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: const Text(
                                        "Save",
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
