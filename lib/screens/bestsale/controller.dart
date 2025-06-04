

import 'package:creation_edge/screens/Trending/model.dart';
import 'package:creation_edge/screens/Trending/repo.dart';
import 'package:creation_edge/screens/bestsale/model.dart';
import 'package:creation_edge/screens/bestsale/repo.dart';
import 'package:creation_edge/screens/blog/blog_repo.dart';
import 'package:creation_edge/screens/blog/model.dart';
import 'package:get/get.dart';

class BestSellingController extends GetxController {
  final BestSaleRepository repository = BestSaleRepository();
  final _products = Rx<BestSellingModel?>(null);
  final _isLoading = false.obs;

  BestSellingModel? get products => _products.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading.value = true;
    try {
      final result = await repository.getProducts();
      _products.value = result;
    } finally {
      _isLoading.value = false;
    }
  }
}