// To parse this JSON data, do
//
//     final bestSellingModel = bestSellingModelFromJson(jsonString);

import 'dart:convert';

BestSellingModel bestSellingModelFromJson(String str) => BestSellingModel.fromJson(json.decode(str));

String bestSellingModelToJson(BestSellingModel data) => json.encode(data.toJson());

class BestSellingModel {
  List<DatumNewProduct>? data;
  bool? success;
  int? status;

  BestSellingModel({
    this.data,
    this.success,
    this.status,
  });

  factory BestSellingModel.fromJson(Map<String, dynamic> json) => BestSellingModel(
    data: json["data"] == null ? [] : List<DatumNewProduct>.from(json["data"]!.map((x) => DatumNewProduct.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class DatumNewProduct {
  int? id;
  String? shortName;
  String? shortNameSlug;
  dynamic? salePrice;
  String? image;

  DatumNewProduct({
    this.id,
    this.shortName,
    this.shortNameSlug,
    this.salePrice,
    this.image,
  });

  factory DatumNewProduct.fromJson(Map<String, dynamic> json) => DatumNewProduct(
    id: json["id"],
    shortName: json["short_name"],
    shortNameSlug: json["short_name_slug"],
    salePrice: json["sale_price"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "short_name": shortName,
    "short_name_slug": shortNameSlug,
    "sale_price": salePrice,
    "image": image,
  };
}
