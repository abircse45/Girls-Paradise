// To parse this JSON data, do
//
//     final productCategory = productCategoryFromJson(jsonString);

import 'dart:convert';

ProductCategory productCategoryFromJson(String str) => ProductCategory.fromJson(json.decode(str));

String productCategoryToJson(ProductCategory data) => json.encode(data.toJson());

class ProductCategory {
  String? status;
  List<Product>? products;

  ProductCategory({
    this.status,
    this.products,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    status: json["status"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}

class Product {
  int? id;
  String? name;
  String? slug;
  String? image;
  String? price;
  String? urlLink;

  Product({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.price,
    this.urlLink,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    image: json["image"],
    price: json["price"],
    urlLink: json["url_link"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image": image,
    "price": price,
    "url_link": urlLink,
  };
}
