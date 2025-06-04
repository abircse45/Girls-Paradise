import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/screens/popular/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Cart/cart_controller.dart';
import '../../Cart/cart_screen.dart';
import '../../NativeServices/native_messenger_launcher.dart';
import '../../Profile/controller/profile_controller.dart';
import '../../WishList/wishList_screen.dart';
import '../../search/search_screen.dart';
import '../../utils/constance.dart';
import '../Arraival/controller.dart';
import '../Trending/controller.dart';
import '../bestsale/controller.dart';
import '../blog/blog_controller.dart';
import '../shop/product_details.dart';

// lib/screens/product_screen.dart
class PopularProductDetails extends StatefulWidget {
  final int ? id;


  const PopularProductDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<PopularProductDetails> createState() => _PopularProductDetailsState();
}

class _PopularProductDetailsState extends State<PopularProductDetails> {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  final CardController cardController = Get.put(CardController());

  // Map to track cart and wishlist states
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    loadSavedStates();
  }

  Future<void> toggleCart(String productId, Product productData) async {
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
    List<String> savedWishlistItems =
        prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> wishlistProducts =
    json.decode(prefs.getString('wishlist_products') ?? '{}');

    if (wishlistItems[productId] == true) {
      Get.snackbar(
        'Already Added',
        'This product is already in your wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Add the product to the wishlist
    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = productData.toJson();
    });

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString('wishlist_products', json.encode(wishlistProducts));

    // Update wishlist count
    cardController.updateWishlistItemCount(savedWishlistItems.length);

    Get.snackbar(
      'Added to Wishlist',
      'Item has been added to your wishlist',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
          Uri.parse('https://girlsparadisebd.com/api/v1/category/${widget.id}')
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final productsData = jsonData['products'] as List;
          setState(() {
            _products = productsData
                .map((productData) => Product.fromJson(productData))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  String? selectFilter;

  Future<void> _launchMessenger() async {
    await NativeMessengerLauncher.launchMessenger();
  }


  var filterList = [
    "Best Sale",
    "High Rated",
    "Low Rated",
  ];

  final ProfileController profileController = Get.put(ProfileController());

  Future<void> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    cardController.updateCartItemCount(savedCartItems.length);
  }

  final BlogController blogController = Get.put(BlogController());
  final TrendingController trendingController = Get.put(TrendingController());
  final BestSellingController bestSellingController =
  Get.put(BestSellingController());
  final NewArrivalController newArrivalController =
  Get.put(NewArrivalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Get.to(const SearchScreen(),
                    transition: Transition.noTransition);
              },
              icon: const Icon(
                Icons.search_outlined,
                size: 30,
                color: Colors.black,
              )),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(
                    const CartScreen(),
                    transition: Transition.noTransition,
                  );

                  // Refresh cart when returning from CartScreen
                  if (result == true) {
                    await loadCartCount();

                    await newArrivalController.fetchProducts();
                    await trendingController.fetchProducts();
                    await bestSellingController.fetchProducts();
                    await blogController.fetchProducts();
                    // If HorizontalCard is stateful, we need to trigger a rebuild
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 25,
                  color: Colors.black,
                ),
              ),
              Positioned(
                right: -1,
                bottom: 10,
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cardController.cartItemCount.value > 0
                          ? '${cardController.cartItemCount.value}'
                          : '0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(
            width: 6,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(const WishlistScreen(),
                      transition: Transition.noTransition);

                  // Refresh cart when returning from CartScreen
                  if (result == true) {
                    await loadCartCount();

                    await newArrivalController.fetchProducts();
                    await trendingController.fetchProducts();
                    await bestSellingController.fetchProducts();
                    await blogController.fetchProducts();

                    // If HorizontalCard is stateful, we need to trigger a rebuild
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                child: const Icon(
                  Icons.favorite_outline,
                  size: 25,
                  color: Colors.black,
                ),
              ),
              Positioned(
                right: -1,
                bottom: 10,
                child: Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cardController.wishlistItemCount.value > 0
                          ? '${cardController.wishlistItemCount.value}'
                          : '0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(
            width: 6,
          ),
          SizedBox(
            width: 6,
          ),
          GestureDetector(
              onTap: _launchMessenger,
              child: Image.asset(
                "assets/images/messenger.png",
                fit: BoxFit.contain,
                height: 20,
                width: 20,
              )),
          SizedBox(
            width: 10,
          ),
        ],
        leading: IconButton(onPressed: (){
          Get.back(result: true);
        }, icon: Icon(Icons.arrow_back)),
        surfaceTintColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 3,
        title: const Text(
          "Category Product",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4, top: 4),
        child: GridView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 4 / 5.4),
          itemBuilder: (_, index) {
            var data = _products[index];
            return GestureDetector(
              onTap: () {
                Get.to(ProductDetails(id: data?.id),
                    transition: Transition.noTransition);
              },
              child: _buildProductCard(data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product data) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            CachedNetworkImage(

              width: MediaQuery.of(context).size.width / 2,
              imageUrl: "${ImagebaseUrl}${data?.image}",
              fit: BoxFit.cover,
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

            _buildActionButtons(data),
            _buildProductInfo(data),
           // _buildPriceTag(data!.price!),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product data) {
    return Positioned(
      bottom: 5,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "${data?.name}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withOpacity(0.8),
                ),
                child: Text(
                  '৳${data?.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildActionButtons(Product data) {
    String productId = data?.id.toString() ?? '';
    bool isInCart = cartItems[productId] ?? false;
    bool isInWishlist = wishlistItems[productId] ?? false;

    return Positioned(
      top: 10,
      left: -5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FittedBox(
          // Use FittedBox to scale content if needed
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: Icons.shopping_cart,
                onTap: () => toggleCart(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(height: 8), // Reduced spacing
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
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
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
