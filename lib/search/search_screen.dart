import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:creation_edge/utils/constance.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/cart_screen.dart';
import '../NativeServices/native_messenger_launcher.dart';
import '../Profile/controller/profile_controller.dart';
import '../WishList/wishList_screen.dart';
import '../screens/Arraival/controller.dart';
import '../screens/Trending/controller.dart';
import '../screens/bestsale/controller.dart';
import '../screens/blog/blog_controller.dart';
import '../screens/shop/controller/product_controller.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final ProductController productController = Get.put(ProductController());
  final CardController cardController = Get.put(CardController());
  final TextEditingController searchController = TextEditingController();

  List<dynamic>? filteredProducts;
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};
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
  void initState() {
    super.initState();
    loadSavedStates();
  }

  void filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = null; // Reset to initial state
      } else {
        filteredProducts = productController.products?.data?.where((product) =>
            product.shortName.toString().toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  List<dynamic>? get currentProducts {
    if (searchController.text.isEmpty) {
      return null; // Return null when no search is performed
    }
    return filteredProducts;
  }

  bool get isLoading => productController.isLoading;

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
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 3,
        title: const Text("Search", style: TextStyle(fontSize: 16, color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 13.0,right: 13,top: 10,bottom: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    contentPadding: const EdgeInsets.only(top: 12),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        filterProducts('');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: filterProducts,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentProducts == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please search for a product',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : currentProducts!.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4, top: 4),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: currentProducts?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5.1,
                ),
                itemBuilder: (_, index) {
                  var data = currentProducts?[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        ProductDetails(id: data?.id),
                        transition: Transition.noTransition,
                      );
                    },
                    child: _buildProductCard(data),
                  );
                },
              ),
            ),
          ),
        ],
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

            _buildActionButtons(data),
            _buildProductInfo(data),
          //  _buildPriceTag(data?.defaultPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(dynamic data) {
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
                  '৳${data?.defaultPrice}',
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

  Widget _buildActionButtons(dynamic data) {
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
