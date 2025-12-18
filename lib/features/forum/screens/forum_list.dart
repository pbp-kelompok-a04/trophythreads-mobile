import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:trophythreads_mobile/features/forum/models/forum.dart';
import 'package:trophythreads_mobile/features/forum/widgets/forum_box.dart';
import 'package:trophythreads_mobile/features/forum/screens/forum_details.dart';
import 'package:trophythreads_mobile/features/forum/screens/create_forum.dart';

enum _SelectedFilter { all, official, community }

class ForumListPage extends StatefulWidget {
  // TODO: Set your base URL here
  static const String baseUrl =
      "http://localhost:8000/"; // 10.0.2.2 for Android emulator

  const ForumListPage({super.key});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  _SelectedFilter _currentFilter = _SelectedFilter.all;

  Key _futureBuilderKey = UniqueKey();

  void _refreshList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _futureBuilderKey = UniqueKey());
    }
  }

  // --- DATA FETCHING ---
  Future<List<Forum>> fetchForums(CookieRequest request) async {
    String filterValue;
    if (_currentFilter == _SelectedFilter.official) {
      filterValue = 'official';
    } else if (_currentFilter == _SelectedFilter.community) {
      filterValue = 'personal';
    } else {
      filterValue = 'all';
    }

    final String url = '${ForumListPage.baseUrl}forum/json/';

    final response = await request.get(url);

    List<Forum> listForums = [];
    if (response is List) {
      for (var d in response) {
        if (d != null) {
          listForums.add(Forum.fromJson(d));
        }
      }
    }

    return listForums.where((forum) {
      if (_currentFilter == _SelectedFilter.all) {
        return true;
      }
      if (_currentFilter == _SelectedFilter.official) {
        return forum.postType == PostType.OFFICIAL;
      }
      if (_currentFilter == _SelectedFilter.community) {
        return forum.postType == PostType.PERSONAL;
      }
      return true;
    }).toList();
  }

  // --- VIEW INCREMENTER ---
  Future<void> _incrementViews(CookieRequest request, String threadId) async {
    final String url =
        "${ForumListPage.baseUrl}forum/views/increment/$threadId/";

    try {
      final response = await request.post(url, {});

      if (response['status'] == 'success' || response['message'] != null) {
        debugPrint("View incremented: ${response['new_views']}");
      }
    } catch (e) {
      debugPrint("Error incrementing views: $e");
    }
  }

  // --- TAP HANDLER ---
  void _onForumTapped(BuildContext context, Forum forum) {
    final request = context.read<CookieRequest>();

    // Increment views
    _incrementViews(request, forum.id.toString());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumDetail(threadId: forum.id)),
    ).then((_) {
      // Refresh the list when returning from the detail screen
      setState(() {
        _futureBuilderKey = UniqueKey();
      });
    });
  }

  // Helper method to build filter buttons
  Widget _buildFilterButton(
    String label,
    _SelectedFilter filterValue,
    BuildContext context,
  ) {
    final bool isSelected = _currentFilter == filterValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(255, 231, 39, 9)
              : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () {
          if (_currentFilter != filterValue) {
            setState(() {
              _currentFilter = filterValue;
              _futureBuilderKey = UniqueKey();
            });
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 10, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Discussions',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Buttons and Create Thread Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filter Buttons Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterButton(
                              'All Threads',
                              _SelectedFilter.all,
                              context,
                            ),
                            _buildFilterButton(
                              'Official',
                              _SelectedFilter.official,
                              context,
                            ),
                            _buildFilterButton(
                              'Community',
                              _SelectedFilter.community,
                              context,
                            ),
                          ],
                        ),
                      ),

                      // Create Thread Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10, 
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateForumPage()),
                          );
                        },
                        child: const Text(
                          'Create Thread',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // The list of forum box
                  FutureBuilder<List<Forum>>(
                    key: _futureBuilderKey,
                    future: fetchForums(request),
                    builder: (context, AsyncSnapshot<List<Forum>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Error loading threads: ${snapshot.error}',
                            ),
                          ),
                        );
                      }
                      final data = snapshot.data;
                      if (data == null || data.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No threads match the current filter.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      // Success get threads State
                      else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            final forum = data[index];
                            final String? loggedUser = request.jsonData['username'];

                            return ForumBox(
                              forum: forum,
                              currentUser: loggedUser,
                              onTap: () => _onForumTapped(context, forum),
                              refresh: _refreshList,
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
