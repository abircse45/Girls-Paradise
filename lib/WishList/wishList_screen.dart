import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/cart_screen.dart';
import '../NativeServices/native_messenger_launcher.dart';
import '../Profile/controller/profile_controller.dart';
import '../model/filter_model.dart';
import '../screens/Arraival/controller.dart';
import '../screens/Trending/controller.dart';
import '../screens/bestsale/controller.dart';
import '../screens/bestsale/model.dart';
import '../screens/blog/blog_controller.dart';
import '../screens/shop/model/product_model.dart';
import '../search/search_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final CardController cardController = Get.find();
  List<Map<String, dynamic>> wishlistProducts = [];
  Map<String, bool> ThiscartItems = {};
  @override
  void initState() {
    super.initState();
    loadWishlistProducts();
    loadSavedCartState(); // Add this line
  }


  Future<void> loadSavedCartState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];

    setState(() {
      for (var id in savedCartItems) {
        cartItems[id] = true;  // Using cartItems instead of ThiscartItems
      }
      cardController.updateCartItemCount(savedCartItems.length);
    });
  }

  Future<void> loadWishlistProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];
      final wishlistProductsData = json.decode(prefs.getString('wishlist_products') ?? '{}');

      setState(() {
        wishlistProducts.clear();

        for (String id in savedWishlistItems) {
          if (wishlistProductsData.containsKey(id)) {
            try {
              final productData = wishlistProductsData[id];
              if (productData != null) {
                // Handle different product types
                Map<String, dynamic> standardizedProduct;

                switch(productData['product_type']) {
                  case 'new':
                    standardizedProduct = {
                      'id': id,
                      'shortName': productData['short_name'],
                      'defaultPrice': productData['default_price'],
                      'defaultImage': productData['default_image'],
                      'product_type': 'new'
                    };
                    break;

                  case 'filter':
                    standardizedProduct = {
                      'id': id,
                      'shortName': productData['short_name'],
                      'defaultPrice': productData['default_price'],
                      'defaultImage': productData['default_image'],
                      'product_type': 'filter'
                    };
                    break;

                  default:
                    standardizedProduct = {
                      'id': id,
                      'shortName': productData['short_name'] ?? productData['name'] ?? 'Unknown Product',
                      'defaultPrice': productData['default_price'] ?? productData['price'] ?? '0',
                      'defaultImage': productData['default_image'] ?? productData['image'] ?? '',
                      'product_type': 'regular'
                    };
                }

                wishlistProducts.add(standardizedProduct);
              }
            } catch (e) {
              print('Error processing wishlist product $id: $e');
            }
          }
        }
      });
    } catch (e) {
      print('Error loading wishlist items: $e');
      Get.snackbar(
        'Error',
        'Failed to load wishlist items',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  // Map to track cart and wishlist states
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};

  // Add this method to refresh cart state
  void refreshCart() {

    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background color

      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 25,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
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
      ),

      body: ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          wishlistProducts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your wishlist is empty',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistProducts.length,
                  itemBuilder: (context, index) {

                    final product = wishlistProducts[index];
                    print("pppp${product["product_type"]}");
                    return _buildWishlistItem(product);
                  },
                ),
          BottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: InkWell(
          onTap: () {
            Get.to(
              ProductDetails(id: int.parse(product["id"])),
              transition: Transition.noTransition,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                  imageUrl:   "${ImagebaseUrl}${product['defaultImage']}",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      print('Image error: $error');
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['shortName'] ?? 'Product Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '৳${product['defaultPrice'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Button

                Column(
                  children: [
                    _buildActionButtons(product),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: () =>
                          removeFromWishlist(product['id'].toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic data) {
    String productId = data['id'].toString();
    bool isInCart = cartItems[productId] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(
              icon: Icons.shopping_cart,
              onTap: () {
                toggleCart(productId, data);

              },
              isActive: isInCart,
            ),
          ],
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





  Future<void> toggleCart(String productId, Map<String, dynamic> productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts = json.decode(prefs.getString('cart_products') ?? '{}');

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
        cartProducts[productId] = {
          'short_name': productData['shortName'],
          'default_price': productData['defaultPrice'],
          'default_image': productData['defaultImage'],
          'id': productData['id'],
          'product_type': productData['product_type'] ?? 'regular'
        };
      });

      await prefs.setStringList('cart_items', savedCartItems);
      await prefs.setString('cart_products', json.encode(cartProducts));

      // Show success message
      Get.snackbar(
        'Added to Cart',
        'Item has been added to your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Update cart count
      cardController.updateCartItemCount(savedCartItems.length);
    }
  }


  Future<void> removeFromWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedWishlistItems =
        prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> savedWishlistProducts =
        json.decode(prefs.getString('wishlist_products') ?? '{}');

    // Debug print before removal
    print('Before removal - Products: $savedWishlistProducts');

    setState(() {
      wishlistProducts.removeWhere((product) => product['id'] == productId);
      savedWishlistItems.remove(productId);
      savedWishlistProducts.remove(productId);
    });

    // Debug print after removal
    print('After removal - Products: $savedWishlistProducts');

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString(
        'wishlist_products', json.encode(savedWishlistProducts));

    cardController.updateWishlistItemCount(savedWishlistItems.length);

    // Get.snackbar(
    //   'Removed from Wishlist',
    //   'Item has been removed from your wishlist',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.red,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    // );
  }
}
