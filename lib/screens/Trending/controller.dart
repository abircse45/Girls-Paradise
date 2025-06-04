

import 'package:creation_edge/screens/Arraival/model.dart';
import 'package:creation_edge/screens/Trending/model.dart';
import 'package:creation_edge/screens/Trending/repo.dart';
import 'package:creation_edge/screens/blog/blog_repo.dart';
import 'package:creation_edge/screens/blog/model.dart';
import 'package:get/get.dart';

import '../bestsale/model.dart';


class TrendingController extends GetxController {
  final TrendingRepository repository = TrendingRepository();

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
    if (_isLoading.value) return;

    if (_allProducts.value == null) {
      // Initial fetch
      _isLoading.value = true;
      try {
        final result = await repository.getProducts();
        _allProducts.value = result;
        if (result?.data != null && result!.data!.isNotEmpty) {
          _displayedProducts.value = result.data!.take(_itemsPerLoad).toList();
        }
      } finally {
        _isLoading.value = false;
      }
    } else {
      // Load more
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
}