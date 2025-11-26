// To parse this JSON data, do
//
//     final merchandiseEntry = merchandiseEntryFromJson(jsonString);

import 'dart:convert';

List<MerchandiseEntry> merchandiseEntryFromJson(String str) => List<MerchandiseEntry>.from(json.decode(str).map((x) => MerchandiseEntry.fromJson(x)));

String merchandiseEntryToJson(List<MerchandiseEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MerchandiseEntry {
    Model model;
    String pk;
    Fields fields;

    MerchandiseEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory MerchandiseEntry.fromJson(Map<String, dynamic> json) => MerchandiseEntry(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String name;
    int price;
    String category;
    int stock;
    String thumbnail;
    String description;
    int productViews;
    bool isFeatured;

    Fields({
        required this.user,
        required this.name,
        required this.price,
        required this.category,
        required this.stock,
        required this.thumbnail,
        required this.description,
        required this.productViews,
        required this.isFeatured,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        name: json["name"],
        price: json["price"],
        category: json["category"],
        stock: json["stock"],
        thumbnail: json["thumbnail"],
        description: json["description"],
        productViews: json["product_views"],
        isFeatured: json["is_featured"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "name": name,
        "price": price,
        "category": category,
        "stock": stock,
        "thumbnail": thumbnail,
        "description": description,
        "product_views": productViews,
        "is_featured": isFeatured,
    };
}

enum Model {
    MERCHANDISE_APP_MERCHANDISE
}

final modelValues = EnumValues({
    "merchandiseApp.merchandise": Model.MERCHANDISE_APP_MERCHANDISE
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
