import 'package:creation_edge/screens/popular/popular_product_details.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GridPopularProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back(result: true);
        }, icon: Icon(Icons.arrow_back)),
        surfaceTintColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 3,
        title: const Text(
          "Category",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      body: Container(
        color: Color(0xFFF5F6FA), // Light gray background
        child:  FutureBuilder<List<Category>>(
          future: fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading categories'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text('No categories found'));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5.1,crossAxisSpacing: 3,mainAxisSpacing: 10),
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final category = snapshot.data![index];
                return CategoryCard(category: category);
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://girlsparadisebd.com/api/v1/all_categories'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Category> categories = (data['all_categories'] as List)
          .map((item) => Category.fromJson(item))
          .toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.to(PopularProductDetails(id: category.id!),transition: Transition.noTransition);
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