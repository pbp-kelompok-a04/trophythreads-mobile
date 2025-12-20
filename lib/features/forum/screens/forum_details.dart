import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

import 'package:trophythreads_mobile/features/forum/models/forum.dart';
import 'package:trophythreads_mobile/features/forum/models/comment.dart';
import 'package:trophythreads_mobile/features/forum/widgets/comment_box.dart';
import 'package:trophythreads_mobile/features/auth/screens/login.dart';
import 'package:trophythreads_mobile/bottom_navbar.dart';
import 'package:trophythreads_mobile/main.dart';


const String _BASE_URL = "http://localhost:8000/";

class ForumDetail extends StatefulWidget {
  final String threadId;
  final String? currentUser;

  const ForumDetail({
    required this.threadId,
    super.key,
    required this.currentUser,
  });

  @override
  State<ForumDetail> createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetail> {
  // Controller for the new comment text field
  final TextEditingController _commentController = TextEditingController();

  late Future<Map<String, dynamic>> _threadDataFuture;

  @override
  void initState() {
    super.initState();
    _threadDataFuture = _fetchThreadAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Helper format date
  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  // --- DATA FETCHING ---
  Future<Map<String, dynamic>> _fetchThreadAndComments() async {
    final request = context.read<CookieRequest>();

    // Fetch Thread Details
    final threadUrl = '$_BASE_URL/forum/json/${widget.threadId}/';
    final threadResponse = await request.get(threadUrl);

    final Forum thread = Forum.fromJson(threadResponse);

    // Fetch Comments List
    final commentsUrl = '$_BASE_URL/forum/${widget.threadId}/comments/';
    final commentsResponse = await request.get(commentsUrl);

    List<Comment> comments = [];

    if (commentsResponse != null) {
      comments = List<Comment>.from(
        commentsResponse.map((x) => Comment.fromJson(x)),
      );
    }

    return {'thread': thread, 'comments': comments};
  }

  // --- COMMENT SUBMISSION ---
  Future<void> _submitComment() async {
    final request = context.read<CookieRequest>();
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment tidak boleh kosong.")),
      );
      return;
    }

    final submitUrl = '$_BASE_URL/forum/${widget.threadId}/comments/create/';

    try {
      final response = await request.postJson(
        submitUrl,
        jsonEncode({'content': content}),
      );

      if (response['message'] != null) {
        // Success: Clear text and refresh the data
        _commentController.clear();
        setState(() {
          _threadDataFuture = _fetchThreadAndComments(); // Re-fetch all data
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comment berhasil dipost!")),
        );
      } else {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal post comment: ${response['error'] ?? 'Unknown error'}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // Helper to build the main thread content
  Widget _buildThreadContent(Forum thread) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread Title
          Text(
            thread.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Author & Created Info
          Text(
            'Author: ${thread.author} | Dibuat: ${_formatDate(thread.createdAt)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 15),
          // Thread Content
          Text(
            thread.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const Divider(height: 30, thickness: 0.1),
        ],
      ),
    );
  }

  // Helper to build the comment submission form
  Widget _buildCommentForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post Sebuah Comment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Text Field Area
              TextField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ketik commentmu di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 15),
              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 12, 12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    // Check if user is guest
                    if (await LoginPageState.isGuest()) {
                      await LoginPageState.canPerformAction(
                        context,
                        'buat comment',
                      );
                    } else {
                      _submitComment();
                    }
                  },
                  child: const Text(
                    'Submit Comment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScaffold(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavbar(currentIndex: 2, onTap: _onItemTapped),
      appBar: AppBar(
        title: const Text('Kembali ke diskusi'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to the list
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _threadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error memuat data: ${snapshot.error}'));
          }

          final Forum thread = snapshot.data!['thread'];
          final List<Comment> comments = snapshot.data!['comments'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title, Author, Main Text
                _buildThreadContent(thread),

                // Comment Submission Form
                _buildCommentForm(),

                const SizedBox(height: 30),

                // Comments Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Comments (${comments.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Comments List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return CommentBox(
                      comment: comments[index],
                      currentUser: widget.currentUser,
                      refresh: () {
                        // Refresh data after edit/delete
                        setState(() {
                          _threadDataFuture = _fetchThreadAndComments();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
