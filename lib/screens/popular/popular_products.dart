import 'package:creation_edge/screens/popular/popular_product_details.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'grid_popular_product.dart';

class PopularCategories extends StatefulWidget {
  @override
  State<PopularCategories> createState() => _PopularCategoriesState();
}

class _PopularCategoriesState extends State<PopularCategories> {
  List<Category> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/all_categories'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Category> fetchedCategories = (data['all_categories'] as List)
            .map((item) => Category.fromJson(item))
            .toList();

        setState(() {
          categories = fetchedCategories;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load categories';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5F6FA),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 16,top: 6,bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(GridPopularProduct(), transition: Transition.noTransition);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: isLoading
                ? Center(child: Container(height: 150,))
                : error != null
                ? Center(child: Text(error!))
                : categories.isEmpty
                ? Center(child: Text('No categories found'))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(category: categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(PopularProductDetails(id: category.id),
            transition: Transition.noTransition);
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: category.image == 'blank-image.jpg'
                      ? AssetImage('assets/images/blank-image.jpg') as ImageProvider
                      : NetworkImage('${ImagebaseUrl}${category.image}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${category.totalProducts} Products',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final dynamic id;
  final String name;
  final String image;
  final dynamic totalProducts;
  final String urlLink;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.totalProducts,
    required this.urlLink,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      totalProducts: json['total_products'],
      urlLink: json['url_link'],
    );
  }
}