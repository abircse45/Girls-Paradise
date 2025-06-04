// To parse this JSON data, do
//
//     final filterModel = filterModelFromJson(jsonString);

import 'dart:convert';

FilterModel filterModelFromJson(String str) => FilterModel.fromJson(json.decode(str));

String filterModelToJson(FilterModel data) => json.encode(data.toJson());

class FilterModel {
  String? status;
  Data? data;

  FilterModel({
    this.status,
    this.data,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) => FilterModel(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  List<ProductFilter>? products;
  Pagination? pagination;

  Data({
    this.products,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    products: json["products"] == null ? [] : List<ProductFilter>.from(json["products"]!.map((x) => ProductFilter.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  dynamic nextPageUrl;

  Pagination({
    this.total,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.nextPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    nextPageUrl: json["next_page_url"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "next_page_url": nextPageUrl,
  };
}

class ProductFilter {
  int? id;
  String? slug;
  String? name;
  String? image;
  String? price;

  ProductFilter({
    this.id,
    this.slug,
    this.name,
    this.image,
    this.price,
  });

  factory ProductFilter.fromJson(Map<String, dynamic> json) => ProductFilter(
    id: json["id"],
    slug: json["slug"],
    name: json["name"],
    image: json["image"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "name": name,
    "image": image,
    "price": price,
  };
}
