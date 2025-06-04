import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;
import '../bestsale/model.dart';

class TrendingRepository {
  Future<BestSellingModel?> getProducts() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}trending_products"));
      if (response.statusCode == 200) {
        return bestSellingModelFromJson(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }
}