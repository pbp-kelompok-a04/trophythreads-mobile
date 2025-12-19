// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
    String id;
    String title;
    dynamic image;
    String content;
    String author;
    int authorId;
    PostType postType;
    int views;
    DateTime createdAt;
    DateTime updatedAt;
    bool isAuthor;
    int replies;
    String latestPost;

    Forum({
        required this.id,
        required this.title,
        required this.image,
        required this.content,
        required this.author,
        required this.authorId,
        required this.postType,
        required this.views,
        required this.createdAt,
        required this.updatedAt,
        required this.isAuthor,
        required this.replies,
        required this.latestPost,
    });

    factory Forum.fromJson(Map<String, dynamic> json) => Forum(
        id: json["id"] ?? "-1",
        title: json["title"] ?? "",
        image: json["image"],
        content: json["content"] ?? "",
        author: json["author"] ?? "unknown",
        authorId: json["author_id"],
        postType: postTypeValues.map[json["post_type"]]!,
        views: json["views"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        isAuthor: json["is_author"],
        replies: json["replies"] ?? 0,
        latestPost: json["latest_post"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "content": content,
        "author": author,
        "author_id": authorId,
        "post_type": postTypeValues.reverse[postType],
        "views": views,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "is_author": isAuthor,
        "replies": replies,
        "latest_post": latestPost,
    };
}

enum PostType {
    OFFICIAL,
    PERSONAL
}

final postTypeValues = EnumValues({
    "official": PostType.OFFICIAL,
    "personal": PostType.PERSONAL
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
