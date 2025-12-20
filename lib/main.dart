import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/bottom_navbar.dart';
import 'package:trophythreads_mobile/features/auth/screens/login.dart';
import 'package:trophythreads_mobile/features/auth/screens/profile_page.dart';
import 'package:trophythreads_mobile/features/match_info/screens/match_entry_list.dart';
import 'package:trophythreads_mobile/features/merchandise/screens/merchandise_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Trophy Threads',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF990B29),
            onPrimary: Colors.white,
            secondary: Color(0xFFED3F27),
            onSecondary: Colors.white,
            surface: Color(0xFFFFF1F1),
            onSurface: Colors.black,
            error: Colors.red,
            onError: Colors.white,
          ),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;
  final List<Widget> _pages = [
    const MatchEntryListPage(),
    const MerchandiseEntryListPage(),
    const Center(child: Text("Halaman Discussion")),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
