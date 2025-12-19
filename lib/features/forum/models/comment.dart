// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
    String id;
    String content;
    dynamic image;
    String author;
    DateTime createdAt;
    bool isAuthor;

    Comment({
        required this.id,
        required this.content,
        required this.image,
        required this.author,
        required this.createdAt,
        required this.isAuthor,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"] ?? "",
        content: json["content"] ?? "",
        image: json["image"],
        author: json["author"] ?? "unknown",
        createdAt: DateTime.parse(json["created_at"]),
        isAuthor: json["is_author"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "image": image,
        "author": author,
        "created_at": createdAt.toIso8601String(),
        "is_author": isAuthor,
    };
}
