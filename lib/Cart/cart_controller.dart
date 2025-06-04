import 'package:get/get.dart';

class CardController extends GetxController {
  var cartItemCount = 0.obs;
  var wishlistItemCount = 0.obs;

  void updateCartItemCount(int count) {
    cartItemCount.value = count;
  }
  void updateWishlistItemCount(int count) {
    wishlistItemCount.value = count;
  }
}
