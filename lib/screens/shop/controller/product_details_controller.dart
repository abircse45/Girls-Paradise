import 'package:creation_edge/screens/shop/model/product_details_model.dart';
import 'package:get/get.dart';
import '../repository/product_repository.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository repository = ProductRepository();
  final _products = Rx<ProductDetailsModel?>(null);
  final _isLoading = false.obs;

  ProductDetailsModel? get products => _products.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchProducts(int? id) async {
    _isLoading.value = true;
    try {
      final result = await repository.getProductDetails(id);
      _products.value = result;
    } finally {
      _isLoading.value = false;
    }
  }
}
