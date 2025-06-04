import 'package:creation_edge/model/filter_model.dart';
import 'package:creation_edge/screens/shop/model/product_details_model.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ProductRepository {
  Future<ProductModel?> getProducts() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}products"));
      if (response.statusCode == 200) {
        return productModelFromJson(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }

  Future<FilterModel?> filterProduct(String filter) async {
    try {
      final response = await http.get(Uri.parse("https://girlsparadisebd.com/api/v1/search_shop?category=&min=&max=&filter=$filter&per_page=200"));
      if (response.statusCode == 200) {
        return filterModelFromJson(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }

  Future<ProductDetailsModel?> getProductDetails(int? id) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}products/$id'));
      if (response.statusCode == 200) {
        return productDetailsModelFromJson(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }
}
