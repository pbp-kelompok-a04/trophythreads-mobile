// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

ReviewEntry reviewEntryFromJson(String str) => ReviewEntry.fromJson(json.decode(str));

String reviewEntryToJson(ReviewEntry data) => json.encode(data.toJson());

class ReviewEntry {
    Product product;
    List<Review> reviews;
    String starsFilter;
    Map<String, int> counts;
    int total;
    bool canReview;

    ReviewEntry({
        required this.product,
        required this.reviews,
        required this.starsFilter,
        required this.counts,
        required this.total,
        required this.canReview,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        product: Product.fromJson(json["product"]),
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
        starsFilter: json["stars_filter"],
        counts: Map.from(json["counts"]).map((k, v) => MapEntry<String, int>(k, v)),
        total: json["total"],
        canReview: json["can_review"],
    );

    Map<String, dynamic> toJson() => {
        "product": product.toJson(),
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
        "stars_filter": starsFilter,
        "counts": Map.from(counts).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "total": total,
        "can_review": canReview,
    };
}

class Product {
    String id;
    String name;

    Product({
        required this.id,
        required this.name,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class Review {
    String id;
    String user;
    int rating;
    String body;
    DateTime createdAt;
    DateTime updatedAt;

    Review({
        required this.id,
        required this.user,
        required this.rating,
        required this.body,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        user: json["user"],
        rating: json["rating"],
        body: json["body"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "rating": rating,
        "body": body,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}