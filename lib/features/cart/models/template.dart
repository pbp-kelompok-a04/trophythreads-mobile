// To parse this JSON data, do
//
//     final cart = cartFromJson(jsonString);

import 'dart:convert';

List<Cart> cartFromJson(String str) =>
    List<Cart>.from(json.decode(str).map((x) => Cart.fromJson(x)));

String cartToJson(List<Cart> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cart {
  String model;
  int pk;
  Fields fields;

  Cart({required this.model, required this.pk, required this.fields});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    model: json["model"],
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": model,
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  int cart;
  String product;
  dynamic productName;
  dynamic productPrice;
  dynamic productThumbnail;
  dynamic productStock;
  int quantity;
  bool selected;

  Fields({
    required this.cart,
    required this.product,
    required this.productName,
    required this.productPrice,
    required this.productThumbnail,
    required this.productStock,
    required this.quantity,
    required this.selected,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    cart: json["cart"],
    product: json["product"],
    productName: json["product_name"],
    productPrice: json["product_price"],
    productThumbnail: json["product_thumbnail"],
    productStock: json["product_stock"],
    quantity: json["quantity"],
    selected: json["selected"],
  );

  Map<String, dynamic> toJson() => {
    "cart": cart,
    "product": product,
    "product_name": productName,
    "product_price": productPrice,
    "product_thumbnail": productThumbnail,
    "product_stock": productStock,
    "quantity": quantity,
    "selected": selected,
  };
}
