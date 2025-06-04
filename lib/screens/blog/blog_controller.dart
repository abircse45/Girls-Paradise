

import 'package:creation_edge/screens/blog/blog_repo.dart';
import 'package:creation_edge/screens/blog/model.dart';
import 'package:get/get.dart';

class BlogController extends GetxController {
  final BlogRepository repository = BlogRepository();
  final _products = Rx<BlogModel?>(null);
  final _isLoading = false.obs;

  BlogModel? get products => _products.value;
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