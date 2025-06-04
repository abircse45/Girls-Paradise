// To parse this JSON data, do
//
//     final blogModel = blogModelFromJson(jsonString);

import 'dart:convert';

BlogModel blogModelFromJson(String str) => BlogModel.fromJson(json.decode(str));

String blogModelToJson(BlogModel data) => json.encode(data.toJson());

class BlogModel {
  List<Datum>? data;
  bool? success;
  int? status;

  BlogModel({
    this.data,
    this.success,
    this.status,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
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
  Category? category;
  String? title;
  dynamic? slug;
  dynamic? description;
  dynamic? mediaType;
  dynamic? mediaLink;
  dynamic buttonLink;
  Category? entryBy;
  DateTime? createdAt;
  dynamic? status;

  Datum({
    this.id,
    this.category,
    this.title,
    this.slug,
    this.description,
    this.mediaType,
    this.mediaLink,
    this.buttonLink,
    this.entryBy,
    this.createdAt,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    mediaType: json["media_type"],
    mediaLink: json["media_link"],
    buttonLink: json["button_link"],
    entryBy: json["entry_by"] == null ? null : Category.fromJson(json["entry_by"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category?.toJson(),
    "title": title,
    "slug": slug,
    "description": description,
    "media_type": mediaType,
    "media_link": mediaLink,
    "button_link": buttonLink,
    "entry_by": entryBy?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "status": status,
  };
}

class Category {
  dynamic? id;
  String? name;

  Category({
    this.id,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
