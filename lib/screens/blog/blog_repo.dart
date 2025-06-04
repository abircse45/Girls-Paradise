import 'dart:developer';

import 'package:creation_edge/screens/blog/model.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;

class BlogRepository {
  Future<BlogModel?> getProducts() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}blogs"));
      if (response.statusCode == 200) {
        log(response.body);
        return blogModelFromJson(response.body);
      }

      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }
}