import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:trophythreads_mobile/features/forum/models/forum.dart';
import 'package:trophythreads_mobile/features/forum/screens/forum_list.dart';

class EditForumPage extends StatefulWidget {
  final Forum forum;

  const EditForumPage({super.key, required this.forum});

  @override
  State<EditForumPage> createState() => _EditForumPageState();
}

class _EditForumPageState extends State<EditForumPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.forum.title);
    _contentController = TextEditingController(text: widget.forum.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Thread', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Perbarui judul dan konten thread Anda.", 
                style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              
              const Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: "Enter title",
                ),
                validator: (value) => value!.isEmpty ? "Title cannot be empty" : null,
              ),
              const SizedBox(height: 20),
              
              const Text("Content", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: "Enter content",
                ),
                validator: (value) => value!.isEmpty ? "Content cannot be empty" : null,
              ),
              const Spacer(),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await request.postJson(
                            "${ForumListPage.baseUrl}forum/edit/${widget.forum.id}/",
                            jsonEncode({
                              'title': _titleController.text,
                              'content': _contentController.text,
                            }),
                          );

                          if (context.mounted) {
                            if (response['message'] == 'Thread updated successfully!') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Changes saved!")),
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => ForumListPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['error'] ?? "Failed to save")),
                              );
                            }
                          }
                        }
                      },
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
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
}