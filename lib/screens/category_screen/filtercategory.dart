import 'dart:convert';
import 'package:creation_edge/screens/shop/controller/product_controller.dart';
import 'package:creation_edge/search/priceRangeSearch.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'category_filter_product.dart';

// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  String? status;
  Data? data;

  Category({
    this.status,
    this.data,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
  List<CategoryElement>? categories;

  Data({
    this.categories,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    categories: json["categories"] == null ? [] : List<CategoryElement>.from(json["categories"]!.map((x) => CategoryElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class CategoryElement {
  int? id;
  String? name;
  int? productCount;

  CategoryElement({
    this.id,
    this.name,
    this.productCount,
  });

  factory CategoryElement.fromJson(Map<String, dynamic> json) => CategoryElement(
    id: json["id"],
    name: json["name"],
    productCount: json["product_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "product_count": productCount,
  };
}


class ApiService {
  static const String baseUrl = 'https://girlsparadisebd.com/api/v1';

  Future<List<CategoryElement>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shop_categories'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final categoriesData = jsonData['data']['categories'] as List;
          return categoriesData
              .map((categoryData) => CategoryElement.fromJson(categoryData))
              .toList();
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
  Future<List<Category>> submitPriceRange(double min,double max) async {
    try {
      final response = await http.get(Uri.parse('https://girlsparadisebd.com/search_shop?category=&min=$min&max=$max&filter='));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final categoriesData = jsonData['data']['categories'] as List;
          return categoriesData
              .map((categoryData) => Category.fromJson(categoryData))
              .toList();

        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();
  List<CategoryElement> _categories = [];
  CategoryElement? _selectedCategory;
  final ProductController productController = Get.put(ProductController());
  bool _isLoading = false;
  String? _error;

  // For price range slider
  double _minPrice = 100;
  double _maxPrice = 3000;
  RangeValues _priceRange = RangeValues(100, 1000);

  void _onCategorySelected(CategoryElement category) async {
    setState(() {
      _selectedCategory = category;
    });
  var result = await  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(categoryId: category.id!),
      ),
    );
  if(result==true){
    setState(() {
      _loadCategories();
    });
  }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _apiService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool visible = false;
  bool visiblerange = false;

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background color
      appBar: AppBar(
        title: const Text(
          'Filter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context,true);
          },
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                setState(() {
                  visible = !visible;
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: 150,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.indigo.withOpacity(0.1)),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Categories",
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),

            for (int i = 0; i < _categories.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 18, right: 28,top: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // First radio button in the row
                    Expanded(
                      child: _buildCategoryRadio(_categories[i]),
                    ),
                    // Second radio button if available
                    if (i + 1 < _categories.length)
                      Expanded(
                        child: _buildCategoryRadio(_categories[i + 1]),
                      )
                    else
                    // Empty Expanded widget to maintain layout when odd number of categories
                      Expanded(child: Container()),
                  ],
                ),
              ),
            const SizedBox(height: 30),


            Card(
              color: Colors.white,
              elevation: 2,
              surfaceTintColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          visiblerange = !visiblerange;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 140,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.indigo.withOpacity(0.1)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              "Price",
                              style: TextStyle(
                                  color: Colors.indigo, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.add_outlined,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RangeSlider(
                      min: _minPrice,
                      max: _maxPrice,
                      values: _priceRange,
                      divisions: (_maxPrice - _minPrice).toInt() ~/ 100,
                      labels: RangeLabels(
                        _priceRange.start.round().toString(),
                        _priceRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: GestureDetector(
                      onTap: () async{
                      var result = await  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Pricerangesearch(
                              minPrice: _priceRange.start,
                              maxPrice: _priceRange.end,
                            ),
                          ),
                        );
                      if(result==true){
                        setState(() {
                          print("hi");
                          _priceRange.start;
                          _priceRange.end;
                           _minPrice = 100;
                           _maxPrice = 1000;
                        });
                      }
                      },
                      child: Container(
                        height: 45,
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.check,color: Colors.indigo,),
                            SizedBox(width: 15,),
                            Text("Submit",style: TextStyle(fontSize: 16,color: Colors.indigo),),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )


          ],
        ),
      ),
    );



  }


  Widget _buildCategoryRadio(CategoryElement category) {
    return Row(
      children: [
        Radio<CategoryElement>(
          value: category,
          groupValue: _selectedCategory,
          onChanged: (CategoryElement? value) {
            if (value != null) {
              _onCategorySelected(value);
            }
          },
        ),
        Expanded(
          child: Text(
            '${category.name} (${category.productCount})',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
