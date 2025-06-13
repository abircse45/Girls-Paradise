//
//
// import 'package:creation_edge/screens/Trending/model.dart';
// import 'package:creation_edge/screens/Trending/repo.dart';
// import 'package:creation_edge/screens/bestsale/model.dart';
// import 'package:creation_edge/screens/bestsale/repo.dart';
// import 'package:creation_edge/screens/blog/blog_repo.dart';
// import 'package:creation_edge/screens/blog/model.dart';
// import 'package:get/get.dart';
//
// class BestSellingController extends GetxController {
//   final BestSaleRepository repository = BestSaleRepository();
//   final _products = Rx<BestSellingModel?>(null);
//   final _isLoading = false.obs;
//
//   BestSellingModel? get products => _products.value;
//   bool get isLoading => _isLoading.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchProducts();
//   }
//
//   Future<void> fetchProducts() async {
//     _isLoading.value = true;
//     try {
//       final result = await repository.getProducts();
//       _products.value = result;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
// }



import 'package:creation_edge/screens/Arraival/repo.dart';
import 'package:creation_edge/screens/Trending/model.dart';
import 'package:creation_edge/screens/Trending/repo.dart';
import 'package:creation_edge/screens/bestsale/model.dart';
import 'package:creation_edge/screens/bestsale/repo.dart';
import 'package:creation_edge/screens/blog/blog_repo.dart';
import 'package:creation_edge/screens/blog/model.dart';
import 'package:get/get.dart';

class BestSellingController extends GetxController {
  final BestSaleRepository repository = BestSaleRepository();
  final _allProducts = Rx<BestSellingModel?>(null);
  final _displayedProducts = RxList<dynamic>([]);
  final _isLoading = false.obs;
  final _itemsPerLoad = 8;

  List<dynamic> get displayedProducts => _displayedProducts;
  bool get isLoading => _isLoading.value;
  bool get hasMoreProducts =>
      (_allProducts.value?.data?.length ?? 0) > _displayedProducts.length;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading.value = true;
    try {
      final result = await repository.getProducts();
      _allProducts.value = result;
      // Initially show first 8 products
      if (result?.data != null && result!.data!.isNotEmpty) {
        _displayedProducts.value = result.data!.take(_itemsPerLoad).toList();
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void loadMoreProducts() {
    if (_isLoading.value || !hasMoreProducts) return;

    final currentLength = _displayedProducts.length;
    final nextProducts = _allProducts.value?.data
        ?.skip(currentLength)
        .take(_itemsPerLoad)
        .toList() ?? [];

    if (nextProducts.isNotEmpty) {
      _displayedProducts.addAll(nextProducts);
    }
  }
}