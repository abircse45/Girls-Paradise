// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  List<Datum>? data;
  bool? success;
  int? status;

  ProductModel({
    this.data,
    this.success,
    this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class Datum {
  int? id;
  String? shortName;
  String? shortNameSlug;
  String? longName;
  String? sku;
  dynamic? stockQuantity;
  dynamic? defaultPrice;
  String? defaultImage;
  String? shortDescription;
  String? longDescription;
  String? shortVideoUrl;
  Brand? category;
  Brand? brand;
  Brand? unit;
  List<Variant>? variants;
  int? status;

  Datum({
    this.id,
    this.shortName,
    this.shortNameSlug,
    this.longName,
    this.sku,
    this.stockQuantity,
    this.defaultPrice,
    this.defaultImage,
    this.shortDescription,
    this.longDescription,
    this.shortVideoUrl,
    this.category,
    this.brand,
    this.unit,
    this.variants,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    shortName: json["short_name"],
    shortNameSlug: json["short_name_slug"],
    longName: json["long_name"],
    sku: json["sku"],
    stockQuantity: json["stock_quantity"],
    defaultPrice: json["default_price"],
    defaultImage: json["default_image"],
    shortDescription: json["short_description"],
    longDescription: json["long_description"],
    shortVideoUrl: json["short_video_url"],
    category: json["category"] == null ? null : Brand.fromJson(json["category"]),
    brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
    unit: json["unit"] == null ? null : Brand.fromJson(json["unit"]),
    variants: json["variants"] == null ? [] : List<Variant>.from(json["variants"]!.map((x) => Variant.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "short_name": shortName,
    "short_name_slug": shortNameSlug,
    "long_name": longName,
    "sku": sku,
    "stock_quantity": stockQuantity,
    "default_price": defaultPrice,
    "default_image": defaultImage,
    "short_description": shortDescription,
    "long_description": longDescription,
    "short_video_url": shortVideoUrl,
    "category": category?.toJson(),
    "brand": brand?.toJson(),
    "unit": unit?.toJson(),
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
    "status": status,
  };
}

class Brand {
  int? id;
  String? name;

  Brand({
    this.id,
    this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Variant {
  int? id;
  String? color;
  String? image;
  String? size;
  dynamic? quantity;
  dynamic? oldPrice;
  dynamic? discount;
  dynamic? salePrice;
  dynamic? orderLimit;
  dynamic? status;

  Variant({
    this.id,
    this.color,
    this.image,
    this.size,
    this.quantity,
    this.oldPrice,
    this.discount,
    this.salePrice,
    this.orderLimit,
    this.status,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json["id"],
    color: json["color"],
    image: json["image"],
    size: json["size"],
    quantity: json["quantity"],
    oldPrice: json["old_price"],
    discount: json["discount"],
    salePrice: json["sale_price"],
    orderLimit: json["order_limit"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "color": color,
    "image": image,
    "quantity": quantity,
    "old_price": oldPrice,
    "discount": discount,
    "sale_price": salePrice,
    "order_limit": orderLimit,
    "status": status,
  };
}