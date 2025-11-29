import 'package:flutter/material.dart';
import '../models/match_entry.dart';

class MatchFormPage extends StatefulWidget {
  const MatchFormPage({super.key});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _time = DateTime.now();
  String _city = '';
  String _country = '';
  Team _homeTeam = Team(name: '', flag: '');
  Team _awayTeam = Team(name: '', flag: '');
  int _homeScore = 0;
  int _awayScore = 0;
  
  final TextEditingController _dateController = TextEditingController();

  // dummy sementara untuk mengecek team
  final List<Team> availableTeams = [
    Team(name: "Indonesia", flag: "https://flagcdn.com/w320/id.png"),
    Team(name: "Malaysia", flag: "https://flagcdn.com/w320/my.png"),
    Team(name: "Thailand", flag: "https://flagcdn.com/w320/th.png"),
    Team(name: "Vietnam", flag: "https://flagcdn.com/w320/vn.png"),
    Team(name: "Singapore", flag: "https://flagcdn.com/w320/sg.png"),
    Team(name: "Japan", flag: "https://flagcdn.com/w320/jp.png"),
    Team(name: "South Korea", flag: "https://flagcdn.com/w320/kr.png"),
    Team(name: "Saudi Arabia", flag: "https://flagcdn.com/w320/sa.png"),
    Team(name: "Australia", flag: "https://flagcdn.com/w320/au.png"),
    Team(name: "Qatar", flag: "https://flagcdn.com/w320/qa.png"),
  ];

  // set agar nilai awal tanggal adalah hari ini
  @override
  void initState() {
    super.initState();
    _dateController.text = "${_time.day}-${_time.month}-${_time.year}";
  }

  // fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(1800),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        // Update teks di input field
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        "Kembali ke Match",
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
                              "Tambah Informasi Pertandingan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Bagikan informasi pertandingan terbaru untuk komunitas!",
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
                                // input judul pertandingan
                                const Text("Judul Pertandingan"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Judul Pertandingan...",
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
                                      _title = value!; // yakin tidak null
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Judul pertandingan tidak boleh kosong!';
                                    }
                                    if (value.length > 255) {
                                      return 'Judul pertandingan tidak boleh lebih dari 255 karakter!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                // input tanggal pertandingan
                                const Text("Tanggal Pertandingan"),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    hintText: "DD-MM-YYYY",
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
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                ),
                                SizedBox(height: 16),
                                // input kota pertandingan
                                const Text("Kota Pertandingan"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Kota Pertandingan...",
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
                                      _city = value!;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Kota pertandingan tidak boleh kosong!';
                                    }
                                    if (value.length > 100) {
                                      return 'Kota pertandingan tidak boleh lebih dari 100 karakter!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                // input negara pertandingan
                                const Text("Negara Pertandingan"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Negara Pertandingan...",
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
                                      _country = value!;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Negara pertandingan tidak boleh kosong!';
                                    }
                                    if (value.length > 100) {
                                      return 'Negara pertandingan tidak boleh lebih dari 100 karakter!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                // input home team
                                const Text("Tim Kandang"),
                                SizedBox(height: 4),
                                // menggunakan autocomplete untuk input tim kandang
                                Autocomplete<Team>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return const Iterable<Team>.empty();
                                        }
                                        // mengembalikan list tim yang mengandung teks yang diinputkan
                                        return availableTeams.where((
                                          Team option,
                                        ) {
                                          return option.name
                                              .toLowerCase()
                                              .contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                        });
                                      },
                                  displayStringForOption: (Team option) =>
                                      option.name,
                                  onSelected: (Team selection) {
                                    setState(() {
                                      _homeTeam = selection;
                                    });
                                  },
                                  // mengembalikan widget TextFormField sebagai field input
                                  // biar bisa validasi dan mengatur desainnya
                                  fieldViewBuilder:
                                      (context, controller, focusNode, _) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            hintText: "Masukkan Tim Kandang...",
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
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Tim kandang tidak boleh kosong!';
                                            }
                                            // jika tim tidak ada di daftar availableTeams
                                            bool valid = availableTeams.any(
                                              (team) =>
                                                  team.name.toLowerCase() == value.toLowerCase(),
                                            );
                                            if (!valid) {
                                              return 'Tim kandang tidak ditemukan!';
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                ),
                                SizedBox(height: 16),
                                // input home score
                                const Text("Skor Tim Kandang"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Skor Kandang...",
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
                                      _homeScore = int.tryParse(value ?? '') ?? 0;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Skor kandang tidak boleh kosong!';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Skor kandang harus berupa angka!';
                                    }
                                    if (int.tryParse(value)! < 0) {
                                      return 'Skor kandang tidak boleh negatif!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                // input away score
                                const Text("Skor Tim Tandang"),
                                SizedBox(height: 4),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "Masukkan Skor Tim Tandang...",
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
                                      _awayScore = int.tryParse(value ?? '') ?? 0;
                                    });
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Skor tandang tidak boleh kosong!';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Skor tandang harus berupa angka!';
                                    }
                                    if (int.tryParse(value)! < 0) {
                                      return 'Skor tandang tidak boleh negatif!';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                // input away team
                                const Text("Tim Tandang"),
                                SizedBox(height: 4),
                                Autocomplete<Team>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return const Iterable<Team>.empty();
                                        }
                                        // mengembalikan list tim yang mengandung teks yang diinputkan
                                        return availableTeams.where((
                                          Team option,
                                        ) {
                                          return option.name
                                              .toLowerCase()
                                              .contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                        });
                                      },
                                  displayStringForOption: (Team option) =>
                                      option.name,
                                  onSelected: (Team selection) {
                                    setState(() {
                                      _awayTeam = selection;
                                    });
                                  },
                                  // mengembalikan widget TextFormField sebagai field input
                                  // biar bisa validasi dan mengatur desainnya
                                  fieldViewBuilder:
                                      (context, controller, focusNode, _) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            hintText: "Masukkan Tim Tandang...",
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
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Tim tandang tidak boleh kosong!';
                                            }
                                            // jika tim tidak ada di daftar availableTeams
                                            bool valid = availableTeams.any(
                                              (team) =>
                                                  team.name.toLowerCase() == value.toLowerCase(),
                                            );
                                            if (!valid) {
                                              return 'Tim tandang tidak ditemukan!';
                                            }
                                            return null;
                                          },
                                        );
                                      },
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
                                                title: const Text('Pertandingan berhasil disimpan!'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Judul: $_title'),
                                                      Text('Tanggal: ${_dateController.text}'),
                                                      Text('Kota: $_city'),
                                                      Text('Negara: $_country'),
                                                      Text('Tim Kandang: ${_homeTeam.name}'),
                                                      Text('Skor Kandang: $_homeScore'),
                                                      Text('Tim Tandang: ${_awayTeam.name}'),
                                                      Text('Skor Tandang: $_awayScore'),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _formKey.currentState!.reset();
                                                        _homeTeam = Team(name: '', flag: '');
                                                        _awayTeam = Team(name: '', flag: '');
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
