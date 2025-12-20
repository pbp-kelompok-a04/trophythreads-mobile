import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/auth/models/profile.dart';
import 'package:trophythreads_mobile/features/merchandise/screens/merchandise_form.dart';
import 'package:trophythreads_mobile/features/merchandise/screens/merchandise_list.dart';
import 'package:trophythreads_mobile/main.dart';
import 'package:trophythreads_mobile/features/auth/screens/register.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masuk',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFED3F27)),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Helper method to check if user is guest
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_guest') ?? false;
  }

  // Helper method to set guest status
  static Future<void> setGuestStatus(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', isGuest);
  }

  // Helper method to set the user's role
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  // Helper method to get the user's role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? '';
  }

  // Helper method to check if user has "user" role
  static Future<bool> isUserRole() async {
    final role = await getUserRole();
    return role == 'user';
  }

  // Show guest restriction dialog
  static void showGuestRestriction(BuildContext context, String feature) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: const [
            Icon(Icons.account_circle_outlined, color: Color(0xFFEA580C), size: 28),
            SizedBox(width: 8),
            Text('Akun Diperlukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untuk menggunakan fitur $feature, Anda perlu memiliki akun Trophy Threads.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Nanti Saja'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Daftar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEA580C),
              side: const BorderSide(color: Color(0xFFEA580C)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Masuk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Show role restriction dialog for seller/admin
  static void showRoleRestriction(BuildContext context, String feature) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFFEA580C), size: 28),
            SizedBox(width: 8),
            Text('Fitur Eksklusif User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur $feature adalah fitur spesial yang hanya tersedia untuk pengguna dengan role "User".',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFEA580C), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Daftar sebagai User untuk menikmati semua fitur belanja!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Masuk Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Check if action is allowed (use this before any restricted action)
  static Future<bool> canPerformAction(
    BuildContext context,
    String action,
  ) async {
    bool isGuestUser = await isGuest();
    if (isGuestUser) {
      showGuestRestriction(context, action);
      return false;
    }
    return true;
  }

  // Check if user can access feature (must be role "user" and not guest)
  static Future<bool> canAccessUserFeature(
    BuildContext context,
    String feature,
  ) async {
    // Check if guest first
    bool isGuestUser = await isGuest();
    if (isGuestUser) {
      showGuestRestriction(context, feature);
      return false;
    }

    // Check if user has "user" role
    bool hasUserRole = await isUserRole();
    if (!hasUserRole) {
      showRoleRestriction(context, feature);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Selamat Datang di Trophy Threads!',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Masukkan Username Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Masukkan Password Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String password = _passwordController.text;

                      // Check credentials
                      // TODO: Change the URL and don't forget to add trailing slash (/) at the end of URL!
                      // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
                      // If you using chrome,  use URL http://localhost:8000
                      final response = await request.login(
                        "http://localhost:8000/auth/login/",
                        {'username': username, 'password': password},
                      );

                      if (request.loggedIn) {
                        final userProfile = UserProfile.fromJson(response);

                        // Set guest status to false for regular login
                        await setGuestStatus(false);
                        await setUserRole(userProfile.role);

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MerchandiseEntryListPage(),
                            ),
                          );
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${userProfile.message} Selamat datang, ${userProfile.username}.",
                                ),
                              ),
                            );
                        }
                      } else {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Gagal masuk'),
                              content: Text(response['message']),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Masuk'),
                  ),
                  const SizedBox(height: 24.0),

                  // Text dengan link untuk Daftar dan Tamu
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                      children: [
                        const TextSpan(text: 'Tidak punya akun? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Daftar sekarang',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' atau '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () async {
                              // Set guest status to true
                              await setGuestStatus(true);

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MerchandiseEntryListPage(),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Masuk sebagai Tamu. Anda dapat melihat-lihat tetapi tidak dapat melakukan transaksi, menambah favorit, atau berkomentar.",
                                      ),
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                              }
                            },
                            child: Text(
                              'Lanjutkan sebagai Tamu',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
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
      ),
    );
  }
}