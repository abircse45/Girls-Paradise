import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:creation_edge/screens/shop/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/product_controller.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String selectedFilter = "Best Rated";
  List<String> filterList = ["Best Rated", "High Rated", "Low Rated"];

  final ProductController productController = Get.put(ProductController());
  final CardController cardController = Get.put(CardController());


  // Map to track cart and wishlist states
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};

  @override
  void initState() {
    super.initState();
    loadSavedStates();
  }


  // Combined loading state
  bool get isLoading =>
      productController.isLoading;

  Future<void> toggleCart(String productId, dynamic productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts =
    json.decode(prefs.getString('cart_products') ?? '{}');

    if (cartItems[productId] == true) {
      // Notify the user that the product is already in the cart
      Get.snackbar(
        'Already Added This Product',
        'This product is already in your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      // Add the product to the cart
      setState(() {
        cartItems[productId] = true;
        savedCartItems.add(productId);
        cartProducts[productId] = productData.toJson();
      });

      await prefs.setStringList('cart_items', savedCartItems);
      await prefs.setString('cart_products', json.encode(cartProducts));

      // Update cart count
      cardController.updateCartItemCount(savedCartItems.length);
    }
  }

  Future<void> toggleWishlist(String productId, dynamic productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> wishlistProducts =
    json.decode(prefs.getString('wishlist_products') ?? '{}');

    // Make sure to save all required product data
    Map<String, dynamic> productMap = {
      'shortName': productData.shortName,
      'defaultPrice': productData.defaultPrice,
      'defaultImage': productData.defaultImage,
      // Add other necessary fields
    };

    setState(() {
      if (wishlistItems[productId] == true) {
        wishlistItems[productId] = false;
        savedWishlistItems.remove(productId);
        wishlistProducts.remove(productId);
      } else {
        wishlistItems[productId] = true;
        savedWishlistItems.add(productId);
        wishlistProducts[productId] = productMap;  // Save the complete product data
      }
    });

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString('wishlist_products', json.encode(wishlistProducts));

    // Update wishlist count
    cardController.updateWishlistItemCount(savedWishlistItems.length);
  }
  Future<void> loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];

    setState(() {
      for (var id in savedCartItems) {
        cartItems[id] = true;
      }
      for (var id in savedWishlistItems) {
        wishlistItems[id] = true;
      }
      // Update counts
      cardController.updateCartItemCount(savedCartItems.length);
      cardController.updateWishlistItemCount(savedWishlistItems.length);
    });
  }



  @override
  Widget build(BuildContext context) {

    return isLoading
        ?  Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.only(left: 4.0,right: 4,top: 4),
          child: GridView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: productController.products?.data?.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 4 / 5.1),
                itemBuilder: (_, index) {
          var data = productController.products?.data?[index];
          return GestureDetector(
            onTap: () {
              Get.to(ProductDetails(id: data?.id),
                  transition: Transition.noTransition);
            },
            child: _buildProductCard(data),
          );
                },
              ),
        );
  }

  Widget _buildProductCard(dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [

            CachedNetworkImage(
              height: 250,
              width: MediaQuery.of(context).size.width/2,
              imageUrl: "${ImagebaseUrl}${data?.defaultImage}",
              fit: BoxFit.fill,
              // loadingBuilder: (BuildContext context, Widget child,
              //     ImageChunkEvent? loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Center(
              //     child: CircularProgressIndicator(
              //       value: loadingProgress.expectedTotalBytes != null
              //           ? loadingProgress.cumulativeBytesLoaded /
              //           loadingProgress.expectedTotalBytes!
              //           : null,
              //     ),
              //   );
              // },
              errorWidget: (context, exception, stackTrace) {
                return Image.asset(
                  height: 240,
                  width: 170,
                  "assets/images/logo.jpeg",
                  fit: BoxFit.fill,
                );
              },
            ),
            _buildProductInfo(data),
            _buildActionButtons(data),
            _buildPriceTag(data?.defaultPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(dynamic data) {
    return Positioned(
      top: 90,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              "${data?.shortName}",
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag(dynamic price) {
    return Positioned(
      top: 205,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: 90,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withOpacity(0.8),
          ),
          child: Text(
            '৳$price',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic data) {
    String productId = data?.id.toString() ?? '';
    bool isInCart = cartItems[productId] ?? false;
    bool isInWishlist = wishlistItems[productId] ?? false;

    return Positioned(
      top: 155,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FittedBox(
          // Use FittedBox to scale content if needed
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: Icons.shopping_cart,
                onTap: () => toggleCart(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(width: 4), // Reduced spacing
              _buildButton(
                icon: Icons.favorite_outline,
                onTap: () => toggleWishlist(productId, data),
                isActive: isInWishlist,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Material(
          color: isActive ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

}
