import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trophythreads_mobile/features/auth/screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading...";
  String role = "Loading...";
  bool isGuest = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final request = context.read<CookieRequest>();
    
    setState(() {
      isGuest = prefs.getBool('is_guest') ?? false;
      
      if (isGuest) {
        username = "Tamu";
        role = "guest";
      } else if (request.loggedIn) {
        username = request.jsonData['username'] ?? 'User';
        role = prefs.getString('user_role') ?? 'user';
      }
      
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final request = context.read<CookieRequest>();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Jika guest, langsung clear data dan redirect
      if (isGuest) {
        await prefs.clear();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil keluar dari mode Tamu'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Jika user biasa, logout dari server
      final response = await request.logout(
        "https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/auth/logout/",
      );

      // Clear SharedPreferences
      await prefs.clear();

      if (context.mounted) {
        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Logout berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Navigate to login dan hapus semua route sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Tetap clear local data meski server error
      await prefs.clear();
      
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout lokal berhasil: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Color _getRoleColor() {
    if (isGuest) return Colors.grey;
    if (role == 'admin') return Colors.red.shade100;
    if (role == 'seller') return Colors.blue.shade100;
    return Colors.green.shade100;
  }

  Color _getRoleTextColor() {
    if (isGuest) return Colors.grey.shade700;
    if (role == 'admin') return Colors.red.shade700;
    if (role == 'seller') return Colors.blue.shade700;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isGuest 
                      ? Colors.grey.shade200
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGuest ? Icons.person_outline : Icons.person,
                  size: 60,
                  color: isGuest 
                      ? Colors.grey.shade600
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Guest Warning (jika guest)
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Anda masuk sebagai Tamu. Daftar untuk fitur lengkap!',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Username Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: isGuest 
                            ? Colors.grey.shade600
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Role Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.badge,
                        color: isGuest 
                            ? Colors.grey.shade600
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Role',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getRoleTextColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    isGuest ? 'Keluar dari Mode Tamu' : 'Logout',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Register Button (jika guest)
              if (isGuest) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Daftar Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}