import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/forum/models/comment.dart';

class CommentBox extends StatelessWidget {
  final Comment comment;

  const CommentBox({super.key, required this.comment});

  // Helper to format date
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (Placeholder 'U' in a circle)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[700],
                child: const Text('U', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt.toLocal()),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Comment Content
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Divider for separation between comments
          const Divider(height: 16, indent: 50, thickness: 0.1),
        ],
      ),
    );
  }
}