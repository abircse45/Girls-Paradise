import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:creation_edge/screens/shop/controller/product_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/auth_screen.dart';
import '../NativeServices/native_messenger_launcher.dart';
import '../Profile/controller/profile_controller.dart';
import '../WishList/wishList_screen.dart';
import '../checkout/checkout_screens.dart';
import '../screens/Arraival/controller.dart';
import '../screens/Trending/controller.dart';
import '../screens/bestsale/controller.dart';
import '../screens/blog/blog_controller.dart';
import '../search/search_screen.dart';
import '../utils/constance.dart';
import 'cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CardController cardController = Get.put(CardController());
  final TextEditingController couponController = TextEditingController();
  List<Map<String, dynamic>> ThiscartItems = [];
  double totalPrice = 0;
  double couponDiscount = 0;
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }


  Map<String, dynamic> _standardizeProductData(String id, Map<String, dynamic> data) {
    // Determine product type based on available fields
    String productType = _determineProductType(data);

    // Create standardized product structure based on type
    switch (productType) {
      case 'regular':
        return {
          'id': id,
          'short_name': data['short_name'] ?? data['name'] ?? 'Unknown Product',
          'default_price': data['default_price']?.toString() ?? '0',
          'default_image': data['default_image'] ?? '',
          'quantity': data['quantity'] ?? 1,
          'color': data['color'] ?? '',
          'size': data['size'] ?? '',
          'discount': data['discount'] ?? '',
          'product_type': 'regular',
        };

      case 'new':
        return {
          'id': id,
          'short_name': data['short_name'] ?? 'Unknown Product',
          'default_price': data['sale_price']?.toString() ?? '0',
          'default_image': data['image'] ?? '',
          'quantity': data['quantity'] ?? 1,
          'color': data['color'] ?? '',
          'size': data['size'] ?? '',
          'product_type': 'new',
        };

      case 'filter':
        return {
          'id': id,
          'short_name': data['name'] ?? 'Unknown Product',
          'default_price': data['price']?.toString() ?? '0',
          'default_image': data['image'] ?? '',
          'quantity': data['quantity'] ?? 1,
          'color': data['color'] ?? '',
          'size': data['size'] ?? '',
          'product_type': 'filter',
        };

      default:
        return {
          'id': id,
          'short_name': 'Unknown Product',
          'default_price': '0',
          'default_image': '',
          'quantity': 1,
          'color': '',
          'size': '',
          'product_type': 'unknown',
        };
    }
  }

  // Helper method to determine product type based on data structure
  String _determineProductType(Map<String, dynamic> data) {
    if (data.containsKey('default_price') && data.containsKey('default_image')) {
      return 'regular';
    } else if (data.containsKey('sale_price') && data.containsKey('short_name')) {
      return 'new';
    } else if (data.containsKey('price') && data.containsKey('name')) {
      return 'filter';
    }
    return 'unknown';
  }
  Future<void> loadCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCartItems = prefs.getStringList('cart_items') ?? [];
      final cartProducts = json.decode(prefs.getString('cart_products') ?? '{}');

      setState(() {
        ThiscartItems.clear();

        for (String id in savedCartItems) {
          if (cartProducts.containsKey(id)) {
            try {
              final productData = cartProducts[id];
              if (productData != null) {
                final standardizedProduct = _standardizeProductData(id, productData);
                ThiscartItems.add(standardizedProduct);
                print('Loaded product: $standardizedProduct'); // Print each loaded product
              }
            } catch (e) {
              print('Error processing product $id: $e');
            }
          }
        }
        print('Final Cart Items: $ThiscartItems'); // Print final cart items list
        calculateTotal();
      });
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }



  Future<void> updateQuantity(int index, bool increment) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> cartProducts =
    json.decode(prefs.getString('cart_products') ?? '{}');

    setState(() {
      if (increment && ThiscartItems[index]['quantity'] < 99) {
        ThiscartItems[index]['quantity'] = (ThiscartItems[index]['quantity'] ?? 1) + 1;
      } else if (!increment && ThiscartItems[index]['quantity'] > 1) {
        ThiscartItems[index]['quantity'] = (ThiscartItems[index]['quantity'] ?? 1) - 1;
      }

      // Update quantity while preserving original product data
      String productId = ThiscartItems[index]['id'];
      Map<String, dynamic> originalProduct = cartProducts[productId] ?? {};
      originalProduct['quantity'] = ThiscartItems[index]['quantity'];
      cartProducts[productId] = originalProduct;

      prefs.setString('cart_products', json.encode(cartProducts));
      calculateTotal();
    });
  }

  var totalDiscount;

  Future<void> removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts =
    json.decode(prefs.getString('cart_products') ?? '{}');

    String productId = ThiscartItems[index]['id'];

    // Remove from SharedPreferences
    savedCartItems.remove(productId);
    cartProducts.remove(productId);

    await prefs.setStringList('cart_items', savedCartItems);
    await prefs.setString('cart_products', json.encode(cartProducts));

    // Update cart count
    cardController.updateCartItemCount(savedCartItems.length);

    setState(() {
      ThiscartItems.removeAt(index);
      calculateTotal();
    });

    Get.snackbar(
      'Success',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  void calculateTotal() {
    double total = 0;
    double totalDiscount = 0; // Initialize total discount to 0

    for (var item in ThiscartItems) {
      int quantity = item['quantity'] ?? 1;
      double price = double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
      double discount = double.tryParse(item['discount']?.toString() ?? '0') ?? 0;

      total += price * quantity;
      totalDiscount += discount * quantity; // Accumulate discounts for all items
    }

    setState(() {
      this.totalDiscount = totalDiscount; // Update the total discount
      totalPrice = total;
    });
  }

  // void calculateTotal() {
  //   double total = 0;
  //   for (var item in ThiscartItems) {
  //     int quantity = item['quantity'] ?? 1;
  //     double price = double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
  //     totalDiscount = double.tryParse(item['discount']?.toString() ?? '0') ?? 0;
  //     total += price * quantity;
  //   }
  //   setState(() {
  //     totalPrice = total - couponDiscount;
  //
  //   });
  // }


  Future<void> applyCoupon() async {
    final couponCode = couponController.text.trim();

    if (couponCode.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a coupon code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final url =
    Uri.parse('https://girlsparadisebd.com/api/v1/apply_product_coupon');
    final body = json.encode({
      "coupon_code": couponCode,
      "total_order_amount": totalPrice.toString(),
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            couponDiscount = double.parse(data['coupon_discount'].toString());
          });
          calculateTotal();

          Get.snackbar(
            'Success',
            'Coupon applied successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          couponController.clear();
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to apply coupon',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('Failed to apply coupon');
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'An error occurred while applying the coupon',
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

  // Combined loading state
  bool get isLoading =>
      productController.isLoading ||
          trendingController.isLoading ||
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              Navigator.pop(context,true);
            },
          ),
        ),
        title: const Text(
        'Cart Screen',
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

      body: ListView(
        shrinkWrap: true,
        primary: false,
        children: [



          ThiscartItems.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 100, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(16),
            itemCount: ThiscartItems.length,
            itemBuilder: (context, index) {
              final item = ThiscartItems[index];
              final price = double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
              final quantity = item['quantity'] ?? 1;
              final itemTotal = price * quantity;

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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Product Image
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: "${ImagebaseUrl}${item['default_image']}",
                              width: 60,
                              height: 70,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) =>
                                  Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${item['short_name']}" ?? 'Product Name',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      children: [
                                        Text(
                                          '৳${itemTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        item["discount"] == 0 || item["discount"] == "" ||  item["discount"] ==null ? Container() :      SizedBox(width: 10,),
                                        item["discount"] ==0 ||   item["discount"] == ""   ||  item["discount"] ==null ? Container() :     Text(
                                          '৳ ${double.parse(item["default_price"]) + item["discount"]}',
                                          style:  const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.lineThrough
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  GestureDetector(
                                    onTap: () => showDeleteConfirmationDialog(index),
                                    child: const Icon(Icons.delete_outline,  color: Colors.red,),

                                  ),

                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                children: [

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Color: ${item["color"]??""}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Size: ${item["size"] ?? ""}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey)
                                        ),
                                        child: GestureDetector(
                                          onTap: () => updateQuantity(index, false),
                                          child: const Icon(Icons.remove),

                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          quantity.toString(),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey)
                                        ),
                                        child: GestureDetector(
                                          onTap: () => updateQuantity(index, true),
                                          child: const Icon(Icons.add),
                                          // style: IconButton.styleFrom(
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(8),
                                          //     side: const BorderSide(color: Colors.indigo),
                                          //   ),
                                          // ),
                                        ),
                                      ),



                                    ],
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Coupon Code Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    decoration: InputDecoration(
                      labelText: 'Enter Coupon Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: applyCoupon,
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFFdc1212),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 26),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Cart Total and Checkout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Item Subtotal:',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '৳${(totalPrice - couponDiscount).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Discount:',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '৳${totalDiscount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coupon Discount:',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '৳${couponDiscount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if(ThiscartItems.isEmpty){
                        Get.snackbar(
                          'Error',
                          'Please add your item cart',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }else{
                        if (accessToken.isEmpty) {
                          Get.to(const AuthScreen(),
                              transition: Transition.noTransition);
                        } else {
                          Get.to( CheckoutScreens(couponDiscount: couponDiscount??0.0,),
                              transition: Transition.noTransition);
                        }
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFdc1212),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          BottomNavBar()
        ],
      ),
    );
  }
  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this cart item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                removeItem(index); // Perform the delete action
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

