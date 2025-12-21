import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/features/forum/models/comment.dart';

class CommentBox extends StatelessWidget {
  final Comment comment;
  final String? currentUser;
  final VoidCallback refresh;

  const CommentBox({
    super.key,
    required this.comment,
    required this.currentUser,
    required this.refresh,
  });

  // Helper format date
  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  // Delete
  Future<void> _showDeleteDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Comment"),
        content: const Text("Yakin menghapus comment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batalkan")),
          TextButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final response = await request.post(
                "https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/forum/comment/delete/${comment.id}/",
                {}, 
              );

              if (context.mounted) {
                Navigator.pop(context); 
                if (response['message'] != null) {
                  refresh(); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Comment dihapus!")));
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Edit
  Future<void> _showEditDialog(BuildContext context) async {
    final TextEditingController editController = 
        TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Edit commentmu...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batalkan"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              final String newContent = editController.text.trim();
              if (newContent.isEmpty) return;

              final request = context.read<CookieRequest>();
              
              final response = await request.postJson(
                "https://samuel-marcelino-trophythreads.pbp.cs.ui.ac.id/forum/comment/edit/${comment.id}/",
                jsonEncode({'content': newContent}),
              );

              if (context.mounted) {
                if (response['message'] == 'Comment updated successfully!') {
                  Navigator.pop(context); 
                  refresh(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Comment terupdate!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['error'] ?? "Update gagal")),
                  );
                }
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthor = currentUser != null && comment.author == currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[700],
                child: const Text(
                  'U',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author and Date/Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt.toLocal()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        // Edit Delete button
                        if (isAuthor) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEditDialog(context),
                            child: const Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showDeleteDialog(context),
                            child: const Text(
                              "Delete",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Content
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 16, indent: 50, thickness: 0.1),
        ],
      ),
    );
  }
}
