import 'package:creation_edge/model/filter_model.dart';
import 'package:get/get.dart';
import '../model/product_model.dart';
import '../repository/product_repository.dart';

// class ProductController extends GetxController {
//   final ProductRepository repository = ProductRepository();
//   final _products = Rx<ProductModel?>(null);
//   final _filterproducts = Rx<FilterModel?>(null);
//   final _isLoading = false.obs;
//
//   ProductModel? get products => _products.value;
//   FilterModel? get filterProduct => _filterproducts.value;
//   bool get isLoading => _isLoading.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchProducts();
//     fetchFilterProducts("");
//
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
//
//   Future<void> fetchFilterProducts(String filter) async {
//     _isLoading.value = true;
//     try {
//       final result = await repository.filterProduct(filter);
//       _filterproducts.value = result;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
// }
class ProductController extends GetxController {
  final ProductRepository repository = ProductRepository();
  final _products = Rx<ProductModel?>(null);
  final _filterproducts = Rx<FilterModel?>(null);
  final _displayedProducts = RxList<ProductFilter>([]);
  final _isLoading = false.obs;
  final _itemsPerLoad = 8;

  ProductModel? get products => _products.value;
  FilterModel? get filterProduct => _filterproducts.value;
  List<ProductFilter> get displayedProducts => _displayedProducts;
  bool get isLoading => _isLoading.value;
  bool get hasMoreProducts =>
      (_filterproducts.value?.data?.products?.length ?? 0) > _displayedProducts.length;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchFilterProducts("");
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

  Future<void> fetchFilterProducts(String filter) async {
    _isLoading.value = true;
    _displayedProducts.clear();
    try {
      final result = await repository.filterProduct(filter);
      _filterproducts.value = result;

      if (result?.data?.products != null && result!.data!.products!.isNotEmpty) {
        final initialProducts = result.data!.products!
            .take(_itemsPerLoad)
            .toList();
        _displayedProducts.addAll(initialProducts);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void loadMoreProducts() {
    if (_isLoading.value || !hasMoreProducts) return;

    final currentLength = _displayedProducts.length;
    final nextProducts = _filterproducts.value?.data?.products
        ?.skip(currentLength)
        .take(_itemsPerLoad)
        .toList() ?? [];

    if (nextProducts.isNotEmpty) {
      _displayedProducts.addAll(nextProducts);
    }
  }
}