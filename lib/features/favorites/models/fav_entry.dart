// To parse this JSON data, do
//
//     final favsItem = favsItemFromJson(jsonString);

import 'dart:convert';

FavsItem favsItemFromJson(String str) => FavsItem.fromJson(json.decode(str));

String favsItemToJson(FavsItem data) => json.encode(data.toJson());

class FavsItem {
    String status;
    List<Favorite> favorites;

    FavsItem({
        required this.status,
        required this.favorites,
    });

    factory FavsItem.fromJson(Map<String, dynamic> json) => FavsItem(
        status: json["status"],
        favorites: List<Favorite>.from(json["favorites"].map((x) => Favorite.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "favorites": List<dynamic>.from(favorites.map((x) => x.toJson())),
    };
}

class Favorite {
    String favoriteId;
    Merchandise merchandise;
    DateTime createdAt;

    Favorite({
        required this.favoriteId,
        required this.merchandise,
        required this.createdAt,
    });

    factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        favoriteId: json["favorite_id"],
        merchandise: Merchandise.fromJson(json["merchandise"]),
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "favorite_id": favoriteId,
        "merchandise": merchandise.toJson(),
        "created_at": createdAt.toIso8601String(),
    };
}

class Merchandise {
    String merchandiseId;
    String name;
    String slug;
    String image;
    String price;
    String description;

    Merchandise({
        required this.merchandiseId,
        required this.name,
        required this.slug,
        required this.image,
        required this.price,
        required this.description,
    });

    factory Merchandise.fromJson(Map<String, dynamic> json) => Merchandise(
        merchandiseId: json["merchandise_id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        price: json["price"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "merchandise_id": merchandiseId,
        "name": name,
        "slug": slug,
        "image": image,
        "price": price,
        "description": description,
    };
}
