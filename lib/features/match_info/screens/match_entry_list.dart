import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/match_info/models/match_entry.dart';
import 'package:trophythreads_mobile/features/match_info/screens/match_detail.dart';
import 'package:trophythreads_mobile/features/match_info/screens/matchlist_form.dart';
import 'package:trophythreads_mobile/features/match_info/widgets/match_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:trophythreads_mobile/features/match_info/widgets/modal_delete.dart';

class MatchEntryListPage extends StatefulWidget {
  const MatchEntryListPage({super.key});

  @override
  State<MatchEntryListPage> createState() => _MatchEntryListPageState();
}

class _MatchEntryListPageState extends State<MatchEntryListPage> {
  List<MatchEntry> _allMatches = [];
  List<MatchEntry> _filteredMatches = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMatch();
  }

  Future<void> _fetchMatch() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await request.get(
        'http://localhost:8000/informasi/json/',
      );
      List<MatchEntry> listMatch = [];
      for (var d in response) {
        if (d != null) {
          listMatch.add(MatchEntry.fromJson(d));
        }
      }
      if (mounted) {
        setState(() {
          _allMatches = listMatch;
          _filteredMatches = listMatch;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal mengambil data.";
        });
      }
    }
  }

  void _runFilter(String enteredKeyword) {
    List<MatchEntry> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allMatches;
    } else {
      results = _allMatches
          .where(
            (match) => match.title.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }
    setState(() {
      _filteredMatches = results;
    });
  }

  void _runSort(String type) {
    setState(() {
      if (type == 'date') {
        _filteredMatches.sort((a, b) => b.date.compareTo(a.date));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sortir Berdasarkan Tanggal Terbaru")),
        );
      } else if (type == 'views') {
        _filteredMatches.sort((a, b) => b.views.compareTo(a.views));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sortir Berdasarkan Views Tertinggi")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isAdmin = request.loggedIn && request.jsonData['role'] == 'admin';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => _runFilter(value),
                            decoration: InputDecoration(
                              hintText: "Cari suatu pertandingan...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 0.3,
                            ),
                          ),
                          offset: const Offset(0, 50),
                          menuPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          color: Colors.grey.shade200,
                          onSelected: (String value) => _runSort(value),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  height: 35,
                                  value: 'date',
                                  child: Text('Sort by Latest Matches'),
                                ),
                                PopupMenuDivider(
                                  color: Colors.grey.shade300,
                                  height: 0.1,
                                ),
                                const PopupMenuItem<String>(
                                  height: 35,
                                  value: 'views',
                                  child: Text('Sort by Highest Views'),
                                ),
                              ],
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Filter",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _filteredMatches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/no-matches.png',
                                width: 300,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada pertandingan yang ditemukan',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: isAdmin ? 64 : 24,
                          ),
                          itemCount: _filteredMatches.length,
                          itemBuilder: (_, index) => MatchEntryCard(
                            match: _filteredMatches[index],
                            isAdmin: isAdmin,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchDetailPage(
                                    match: _filteredMatches[index],
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                _fetchMatch();
                              }
                            },
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchFormPage(
                                    match: _filteredMatches[index],
                                  ),
                                ),
                              );
                              if (result == true) {
                                _fetchMatch();
                              }
                            },
                            onDelete: () {
                              showDeleteModal(
                                context: context,
                                request: request,
                                matchId: _filteredMatches[index].id,
                                onSuccess: () {
                                  _fetchMatch();
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),

            if (isAdmin)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(6, 0, 0, 0),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MatchFormPage(),
                          ),
                        );
                        _fetchMatch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Tambah Informasi Pertandingan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
    );
  }
}
