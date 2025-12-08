// To parse this JSON data, do
//
//     final cartItem = cartItemFromJson(jsonString);

import 'dart:convert';

List<CartItem> cartItemFromJson(String str) =>
    List<CartItem>.from(json.decode(str).map((x) => CartItem.fromJson(x)));

String cartItemToJson(List<CartItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartItem {
  int id;
  Product product;
  int quantity;
  bool selected;
  int lineTotal;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selected,
    required this.lineTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"],
    product: Product.fromJson(json["product"]),
    quantity: json["quantity"],
    selected: json["selected"],
    lineTotal: json["line_total"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product": product.toJson(),
    "quantity": quantity,
    "selected": selected,
    "line_total": lineTotal,
  };

  // Getter untuk backward compatibility
  int get pk => id;
  Fields get fields => Fields(
    cart: 0, // not used in new format
    product: product.id ?? '',
    productName: product.name,
    productPrice: product.price,
    productThumbnail: product.thumbnail,
    productStock: product.stock,
    quantity: quantity,
    selected: selected,
  );
}

class Product {
  String? id;
  String name;
  int price;
  String thumbnail;
  int stock;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.thumbnail,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"] ?? 'Unknown Product',
    price: json["price"] ?? 0,
    thumbnail: json["thumbnail"] ?? '',
    stock: json["stock"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "thumbnail": thumbnail,
    "stock": stock,
  };
}

// Keep old Fields class for backward compatibility
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
