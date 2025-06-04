import 'package:creation_edge/screens/Trending/model.dart';
import 'package:creation_edge/screens/bestsale/model.dart';
import 'package:creation_edge/screens/blog/model.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;

class NewArrivalRepository {
  Future<BestSellingModel?> getProducts() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}recent_arrival_products"));
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
