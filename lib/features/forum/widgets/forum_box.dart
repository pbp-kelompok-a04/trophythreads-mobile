import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/features/forum/models/forum.dart';
import 'package:trophythreads_mobile/features/forum/screens/edit_forum.dart';

class ForumBox extends StatelessWidget {
  final Forum forum;
  final VoidCallback onTap;
  final VoidCallback refresh;
  final String? currentUser;

  const ForumBox({super.key, required this.forum, required this.onTap, required this.refresh, this.currentUser});

  // Helper format date
  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {

    final request = context.watch<CookieRequest>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0), // Margin between cards
      elevation: 1, // Subtle shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap, // Handle tap for the whole card
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, User, Stats, Date, Type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar (using a placeholder icon for now)
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                    // You could use NetworkImage(forum.authorProfilePictureUrl) if available
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Thread by: user78"
                        Text(
                          'Thread oleh: ${forum.author}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Views, Replies, Date
                        Row(
                          children: [
                            Text(
                              'views: ${forum.views}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'balasan: ${forum.replies}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(forum.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // "personal" Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      forum.postType == PostType.OFFICIAL
                          ? 'official'
                          : 'personal',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thread Title
              Text(
                forum.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Thread Content/Description
              Text(
                forum.content,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                maxLines: 3, // Display up to 3 lines
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Latest Post (if available)
              if (forum
                  .latestPost
                  .isNotEmpty) // Only show if latestPost has data
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post Terkini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      forum
                          .latestPost, // This assumes 'latestPost' contains the actual post text
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  if (currentUser != null && forum.author == currentUser)
                    Row(
                      children: [

                        // Edit button
                        OutlinedButton(
                          onPressed: () async {
                            final refreshNeeded = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditForumPage(forum: forum),
                              ),
                            );
                            if (refreshNeeded == true) {
                              refreshNeeded(); 
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Edit', style: TextStyle(color: Colors.black87, fontSize: 13)),
                        ),

                        const SizedBox(width: 8), 

                        // Delete button
                        OutlinedButton(
                          onPressed: () {
                            _showDeleteDialog(context, request);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(), 

                  // Read More
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: onTap,
                    child: const Text(
                      'Baca',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Thread"),
        content: const Text("Yakin menghapus thread? Penghapusan bersifat permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final response = await request.postJson(
                "http://localhost:8000/forum/delete/${forum.id}/",
                jsonEncode({}),
              );

              if (context.mounted) {
                if (response['message'] == 'Thread deleted successfully!') {
                  Navigator.pop(context); 
                  refresh(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thread dihapus!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? "Error deleting thread")),
                  );
                  Navigator.pop(context); 
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
}
