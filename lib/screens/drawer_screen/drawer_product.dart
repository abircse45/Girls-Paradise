import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:creation_edge/screens/shop/model/product_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Cart/cart_screen.dart';
import '../../NativeServices/native_messenger_launcher.dart';
import '../../Profile/controller/profile_controller.dart';
import '../../Social/social_link_controller.dart';
import '../../WishList/wishList_screen.dart';
import '../../footer/controller.dart';
import '../../model/filter_model.dart';
import '../../search/search_screen.dart';
import '../Arraival/controller.dart';
import '../Trending/controller.dart';
import '../bestsale/controller.dart';
import '../bestsale/model.dart';
import '../blog/blog_controller.dart';
import '../category_screen/filtercategory.dart';
import '../home/bottomNavbbar.dart';
import '../shop/controller/product_controller.dart';

class DrawerProduct extends StatefulWidget {
  const DrawerProduct({Key? key}) : super(key: key);

  @override
  State<DrawerProduct> createState() => _DrawerProductState();
}

class _DrawerProductState extends State<DrawerProduct> {
  final ProductController productController = Get.put(ProductController());
  final FooterController footerController = Get.put(FooterController());
  final SocialLinksController socialLinksController =
  Get.put(SocialLinksController());

  String? selectFilter;
  final CardController cardController = Get.put(CardController());
  Future<void> _launchMessenger() async {
    await NativeMessengerLauncher.launchMessenger();
  }

  var filterList = [
    "Best Sale",
    "High Rated",
    "Low Rated",
    "Discount Product",
  ];

  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    loadCartCount();
    loadSavedStates();
    profileController.fetchProfileData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateDeviceToken();
      await footerController.fetchFooterSettings();
      await socialLinksController.fetchSocialLinks();
    });
  }

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
    loadSavedStates();
    if (mounted) {
      setState(() {});
    }
  }

  // Update loadSavedStates to be public
  Future<void> loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];

    if (mounted) {
      setState(() {
        cartItems.clear(); // Clear existing items
        wishlistItems.clear();

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
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  var deviceToken;

  Future<void> initialize() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission();

    // Fetch and print the device token
    deviceToken = await _firebaseMessaging.getToken();
    if (deviceToken != null) {
      log("Firebase Device Token: $deviceToken");
    } else {
      print("Failed to retrieve Firebase Device Token");
    }

    // Subscribe to the 'all_users' topic
    await _firebaseMessaging.subscribeToTopic('all_devices');
    print("Subscribed to 'all_users' topic");
  }

  Future updateDeviceToken() async {
    await initialize();
    var response = await http.post(
      Uri.parse("https://girlsparadisebd.com/api/v1/update_device_token"),
      body: {"device_token": "${deviceToken}"},
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      setState(() {
        print("Update Successfully");
      });
    }
  }

  // Combined loading state
  bool get isLoading =>
      productController.isLoading ||
          blogController.isLoading ||
          bestSellingController.isLoading ||
          newArrivalController.isLoading ||
          bestSellingController.isLoading;

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

  Future<void> toggleCartNewProduct(
      String productId, DatumNewProduct productData) async {
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

  Future<void> toggleCartFilter(
      String productId, ProductFilter productData) async {
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

// New product toggle method
  Future<void> toggleWishlistNewproduct(
      String productId, DatumNewProduct productData) async {
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

    // Standardize new product data
    final standardizedData = {
      'id': productId,
      'short_name': productData.shortName,
      'default_price': productData.salePrice,
      'default_image': productData.image,
      'product_type': 'new'
    };

    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = standardizedData;
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

  Future<void> toggleWishlistFilter(
      String productId, ProductFilter productData) async {
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

    // Standardize filter product data
    final standardizedData = {
      'id': productId,
      'short_name': productData.name,
      'default_price': productData.price,
      'default_image': productData.image,
      'product_type': 'filter'
    };

    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = standardizedData;
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey[200],
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
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                "assets/images/appbarlogo.png",
                height: 170,
                width: 150,
                fit: BoxFit.contain,
              ),
            ),
          ],
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
                    await loadSavedStates();
                    await productController.fetchProducts();
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
                    await loadSavedStates();
                    await productController.fetchProducts();
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
      // appBar: AppBar(
      //   surfaceTintColor: Colors.white,
      //   iconTheme: IconThemeData(color: Colors.black),
      //   backgroundColor: Colors.white,
      //   elevation: 3,
      //   title: const Text("Product",style: TextStyle(fontSize: 16,color: Colors.black),),
      // ),
      body:       ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                right: 12.0, top: 6, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                      () => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "${productController.filterProduct!.data!.products?.length} Item Found",
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: DropdownButtonHideUnderline(
                      child: Container(
                        // width: 120,
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.indigo.withOpacity(0.1)),

                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8),
                          child: DropdownButton(
                              hint: const Text(
                                "Select Filter",
                                style:
                                TextStyle(color: Colors.indigo),
                              ),
                              items: filterList.map((e) {
                                return DropdownMenuItem(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        color: Colors.indigo),
                                  ),
                                  value: e,
                                );
                              }).toList(),
                              value: selectFilter == ""
                                  ? null
                                  : selectFilter,
                              onChanged: (val) {
                                setState(() {
                                  selectFilter = val!;
                                });

                                if (selectFilter == "Best Sale") {
                                  productController
                                      .fetchFilterProducts("best");
                                } else if (selectFilter ==
                                    "High Rated") {
                                  productController
                                      .fetchFilterProducts("high");
                                } else if (selectFilter ==
                                    "Low Rated") {
                                  productController
                                      .fetchFilterProducts("low");
                                } else if (selectFilter ==
                                    "Discount Product") {
                                  productController
                                      .fetchFilterProducts(
                                      "discount");
                                }
                              }),
                        ),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(const CategoryScreen(),
                        transition: Transition.noTransition);
                  },
                  child: Container(
                    height: 45,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_alt,
                          color: Colors.indigo,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Filter",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.indigo),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Obx(() => isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: (productController.filterProduct!
                .data?.products?.length ??
                0) ~/
                2 +
                ((productController.filterProduct!.data
                    ?.products?.length ??
                    0) %
                    2 ==
                    0
                    ? 0
                    : 1),
            itemBuilder: (context, index) {
              // Calculate the indices for the two items in this row
              final int firstItemIndex = index * 2;
              final int secondItemIndex =
                  firstItemIndex + 1;

              // Get the data for both items
              final firstItem = productController
                  .filterProduct!
                  .data
                  ?.products?[firstItemIndex];
              final secondItem = secondItemIndex <
                  (productController.filterProduct!
                      .data?.products?.length ??
                      0)
                  ? productController.filterProduct!.data!
                  .products![secondItemIndex]
                  : null;

              return Padding(
                padding: const EdgeInsets.only(
                  left: 4.0,
                  right: 4,
                ),
                child: Row(
                  children: [
                    // First item
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            ProductDetails(
                                id: firstItem?.id),
                            transition:
                            Transition.noTransition,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 4.0,
                              right: 4,
                              top: 6,
                              bottom: 6),
                          child: _filterbuildProductCard(
                              firstItem!),
                        ),
                      ),
                    ),
                    // Second item (if exists)
                    if (secondItem != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              ProductDetails(
                                  id: secondItem.id),
                              transition:
                              Transition.noTransition,
                            );
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                left: 4.0,
                                right: 4,
                                top: 6,
                                bottom: 6),
                            child:
                            _filterbuildProductCard(
                                secondItem),
                          ),
                        ),
                      )
                    else
                    // Empty Expanded widget to maintain layout when there's no second item
                      Expanded(child: Container()),
                  ],
                ),
              );
            },
          )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              trendingController.fetchProducts();
            },
            child: Center(
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 180,
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "Load More",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          BottomNavBar(),
        ],
      ),

    );


  }

  Widget _filterbuildProductCard(ProductFilter data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          CachedNetworkImage(
            height: 240,
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

          _filterbuildActionButtons(data),
       _filterbuildProductInfo(data),
        ],
      ),
    );
  }
  Widget _filterbuildProductInfo(ProductFilter data) {
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
                margin: EdgeInsets.only(left: 2, right: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "${data?.name}",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
  Widget _filterbuildActionButtons(ProductFilter data) {
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
                onTap: () => toggleCartFilter(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(height: 8), // Reduced spacing
              _buildButton(
                icon: Icons.favorite_outline,
                onTap: () => toggleWishlistFilter(productId, data),
                isActive: isInWishlist,
              ),
            ],
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
  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: SizedBox(
        width: 35,
        height: 35,
        child: Material(
          color: isActive ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
