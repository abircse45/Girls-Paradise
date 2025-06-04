// import 'package:creation_edge/Cart/cart_controller.dart';
// import 'package:creation_edge/screens/Arraival/controller.dart';
// import 'package:creation_edge/screens/shop/controller/product_controller.dart';
// import 'package:creation_edge/utils/constance.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../Trending/controller.dart';
// import '../bestsale/controller.dart';
// import '../blog/blog_controller.dart';
// import '../shop/product_details.dart';
// import 'bottomNavbbar.dart';
// import 'facebook_newsFeed.dart';
//
// class HorizontalCard extends StatefulWidget {
//   const HorizontalCard({super.key});
//
//   @override
//   State<HorizontalCard> createState() => _HorizontalCardState();
// }
//
// class _HorizontalCardState extends State<HorizontalCard> {
//   final ProductController productController = Get.put(ProductController());
//   final CardController cardController = Get.put(CardController());
//   final BlogController blogController = Get.put(BlogController());
//   final TrendingController trendingController = Get.put(TrendingController());
//   final BestSellingController bestSellingController =
//   Get.put(BestSellingController());
//   final NewArrivalController newArrivalController =
//   Get.put(NewArrivalController());
//
//   // Map to track cart and wishlist states
//   Map<String, bool> cartItems = {};
//   Map<String, bool> wishlistItems = {};
//
//   // Add this method to refresh cart state
//   void refreshCart() {
//     loadSavedStates();
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   // Update loadSavedStates to be public
//   Future<void> loadSavedStates() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCartItems = prefs.getStringList('cart_items') ?? [];
//     final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];
//
//     if (mounted) {
//       setState(() {
//         cartItems.clear(); // Clear existing items
//         wishlistItems.clear();
//
//         for (var id in savedCartItems) {
//           cartItems[id] = true;
//         }
//         for (var id in savedWishlistItems) {
//           wishlistItems[id] = true;
//         }
//
//         // Update counts
//         cardController.updateCartItemCount(savedCartItems.length);
//         cardController.updateWishlistItemCount(savedWishlistItems.length);
//       });
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     loadSavedStates();
//   }
//
//   // Combined loading state
//   bool get isLoading =>
//       productController.isLoading ||
//           trendingController.isLoading ||
//           bestSellingController.isLoading;
//
//   Future<void> toggleCart(String productId, dynamic productData) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
//     Map<String, dynamic> cartProducts =
//     json.decode(prefs.getString('cart_products') ?? '{}');
//
//     if (cartItems[productId] == true) {
//       // Notify the user that the product is already in the cart
//       Get.snackbar(
//         'Already Added This Product',
//         'This product is already in your cart',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//     } else {
//       // Add the product to the cart
//       setState(() {
//         cartItems[productId] = true;
//         savedCartItems.add(productId);
//         cartProducts[productId] = productData.toJson();
//       });
//
//       await prefs.setStringList('cart_items', savedCartItems);
//       await prefs.setString('cart_products', json.encode(cartProducts));
//
//       // Update cart count
//       cardController.updateCartItemCount(savedCartItems.length);
//     }
//   }
//
//   Future<void> toggleWishlist(String productId, dynamic productData) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedWishlistItems =
//         prefs.getStringList('wishlist_items') ?? [];
//     Map<String, dynamic> wishlistProducts =
//     json.decode(prefs.getString('wishlist_products') ?? '{}');
//
//     // Make sure to save all required product data
//     Map<String, dynamic> productMap = {
//       'shortName': productData.shortName,
//       'defaultPrice': productData.defaultPrice,
//       'defaultImage': productData.defaultImage,
//       // Add other necessary fields
//     };
//
//     setState(() {
//       if (wishlistItems[productId] == true) {
//         wishlistItems[productId] = false;
//         savedWishlistItems.remove(productId);
//         wishlistProducts.remove(productId);
//       } else {
//         wishlistItems[productId] = true;
//         savedWishlistItems.add(productId);
//         wishlistProducts[productId] =
//             productMap; // Save the complete product data
//       }
//     });
//
//     await prefs.setStringList('wishlist_items', savedWishlistItems);
//     await prefs.setString('wishlist_products', json.encode(wishlistProducts));
//
//     // Update wishlist count
//     cardController.updateWishlistItemCount(savedWishlistItems.length);
//   }
//
//   Future<void> toggleWishlistNewproduct(
//       String productId, dynamic productData) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedWishlistItems =
//         prefs.getStringList('wishlist_items') ?? [];
//     Map<String, dynamic> wishlistProducts =
//     json.decode(prefs.getString('wishlist_products') ?? '{}');
//
//     // Make sure to save all required product data
//     Map<String, dynamic> productMap = {
//       'shortName': productData.shortName,
//       'salePrice': productData.salePrice,
//       'image': productData.image,
//       // Add other necessary fields
//     };
//
//     setState(() {
//       if (wishlistItems[productId] == true) {
//         wishlistItems[productId] = false;
//         savedWishlistItems.remove(productId);
//         wishlistProducts.remove(productId);
//       } else {
//         wishlistItems[productId] = true;
//         savedWishlistItems.add(productId);
//         wishlistProducts[productId] =
//             productMap; // Save the complete product data
//       }
//     });
//
//     await prefs.setStringList('wishlist_items', savedWishlistItems);
//     await prefs.setString('wishlist_products', json.encode(wishlistProducts));
//
//     // Update wishlist count
//     cardController.updateWishlistItemCount(savedWishlistItems.length);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//
//       if (isLoading) {
//         return Center(
//           child: LoadingAnimationWidget.staggeredDotsWave(
//             color: Colors.red,
//             size: 40,
//           ),
//         );
//       }
//
//       return ListView(
//         shrinkWrap: true,
//         primary: false,
//         children: [
//
//         ],
//       );
//     });
//   }
//
//   Widget _buildProductCard(dynamic data) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4.0, right: 4, top: 4, bottom: 4),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Stack(
//           children: [
//             CachedNetworkImage(
//               height: 240,
//               width: 170,
//               "${ImagebaseUrl}${data?.defaultImage}",
//               fit: BoxFit.fill,
//               loadingBuilder: (BuildContext context, Widget child,
//                   ImageChunkEvent? loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                         : null,
//                   ),
//                 );
//               },
//               errorBuilder: (context, exception, stackTrace) {
//                 return Image.asset(
//                   height: 240,
//                   width: 170,
//                   "assets/images/logo.jpeg",
//                   fit: BoxFit.fill,
//                 );
//               },
//             ),
//             _buildProductInfo(data),
//             _buildActionButtons(data),
//             _buildPriceTag(data?.defaultPrice),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductInfo(dynamic data) {
//     return Positioned(
//       top: 90,
//       right: 0,
//       left: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: Center(
//           child: Container(
//             margin: EdgeInsets.only(left: 2, right: 2),
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text(
//               "${data?.shortName}",
//               textAlign: TextAlign.start,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPriceTag(dynamic price) {
//     return Positioned(
//       top: 205,
//       right: 0,
//       left: 0,
//       child: Center(
//         child: Container(
//           alignment: Alignment.center,
//           width: 90,
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: Colors.black.withOpacity(0.8),
//           ),
//           child: Text(
//             '৳$price',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(dynamic data) {
//     String productId = data?.id.toString() ?? '';
//     bool isInCart = cartItems[productId] ?? false;
//     bool isInWishlist = wishlistItems[productId] ?? false;
//
//     return Positioned(
//       top: 155,
//       right: 0,
//       left: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: FittedBox(
//           // Use FittedBox to scale content if needed
//           fit: BoxFit.scaleDown,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildButton(
//                 icon: Icons.shopping_cart,
//                 onTap: () => toggleCart(productId, data),
//                 isActive: isInCart,
//               ),
//               const SizedBox(width: 4), // Reduced spacing
//               _buildButton(
//                 icon: Icons.favorite_outline,
//                 onTap: () => toggleWishlist(productId, data),
//                 isActive: isInWishlist,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtonsNew(dynamic data) {
//     String productId = data?.id.toString() ?? '';
//     bool isInCart = cartItems[productId] ?? false;
//     bool isInWishlist = wishlistItems[productId] ?? false;
//
//     return Positioned(
//       top: 155,
//       right: 0,
//       left: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: FittedBox(
//           // Use FittedBox to scale content if needed
//           fit: BoxFit.scaleDown,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildButton(
//                 icon: Icons.shopping_cart,
//                 onTap: () => toggleCart(productId, data),
//                 isActive: isInCart,
//               ),
//               const SizedBox(width: 4), // Reduced spacing
//               _buildButton(
//                 icon: Icons.favorite_outline,
//                 onTap: () => toggleWishlistNewproduct(productId, data),
//                 isActive: isInWishlist,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     bool isActive = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4.0, right: 4.0),
//       child: SizedBox(
//         width: 35,
//         height: 35,
//         child: Material(
//           color: isActive ? Colors.red : Colors.grey[800],
//           borderRadius: BorderRadius.circular(6),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(6),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNewItemCard(dynamic data) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Stack(
//           children: [
//             CachedNetworkImage(
//               height: 250,
//               width: double.infinity,
//               fit: BoxFit.fill,
//               "${ImagebaseUrl}${data?.image}",
//               loadingBuilder: (BuildContext context, Widget child,
//                   ImageChunkEvent? loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                         : null,
//                   ),
//                 );
//               },
//               errorBuilder: (context, exception, stackTrace) {
//                 return Image.asset(
//                   height: 240,
//                   width: double.infinity,
//                   "assets/images/logo.jpeg",
//                   fit: BoxFit.fill,
//                 );
//               },
//             ),
//             _buildProductInfo(data),
//             _buildActionButtonsNew(data),
//             _buildPriceTag(data?.salePrice),
//           ],
//         ),
//       ),
//     );
//   }
// }