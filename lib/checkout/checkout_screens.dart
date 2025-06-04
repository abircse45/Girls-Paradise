// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:creation_edge/Cart/cart_controller.dart';
// import 'package:creation_edge/screens/home/bottomNavbbar.dart';
// import 'package:creation_edge/screens/shop/controller/product_controller.dart';
// import 'package:creation_edge/utils/local_store.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../Cart/cart_screen.dart';
// import '../Order/success_order_screen.dart';
// import '../Profile/controller/profile_controller.dart';
// import '../WishList/wishList_screen.dart';
// import '../screens/Arraival/controller.dart';
// import '../screens/Trending/controller.dart';
// import '../screens/bestsale/controller.dart';
// import '../screens/blog/blog_controller.dart';
// import '../search/search_screen.dart';
// import '../utils/constance.dart';
// import '../utils/location.dart';
//
// class CheckoutScreens extends StatefulWidget {
//   final double? couponDiscount;
//   const CheckoutScreens({super.key, this.couponDiscount});
//
//   @override
//   State<CheckoutScreens> createState() => _CheckoutScreensState();
// }
//
// class _CheckoutScreensState extends State<CheckoutScreens> {
//
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//
//   List<Map<String, dynamic>> deliveryAreas = [];
//   List<Map<String, dynamic>> couriers = [];
//   List<PaymentMethod> paymentMethods = [];
//
//   Future<List<PaymentMethod>> fetchPaymentMethods() async {
//     final response = await http.get(
//       Uri.parse('https://girlsparadisebd.com/api/v1/payment_methods'),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body)['data'];
//       return (data as List)
//           .map((item) => PaymentMethod.fromJson(item))
//           .toList();
//     } else {
//       throw Exception('Failed to load payment methods');
//     }
//   }
//
//   Future<void> loadPaymentMethods() async {
//     try {
//       final methods = await fetchPaymentMethods();
//       setState(() {
//         paymentMethods = methods;
//         selectedPaymentMethod = methods.isNotEmpty ? methods.first.slug : '';
//       });
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   String? selectedArea;
//   String? selectedCourier;
//   String? selectedCity;
//   String? selectedZone;
//   String? selectedZoneArea;
//   String selectedPaymentMethod = 'Cash On Delivery';
//
//   List<Map<String, dynamic>> ThiscartItems = [];
//   double subtotal = 0;
//   double deliveryCharge = 0;
//
//   Map<String, dynamic>? userData;
//
//   bool isLoading = true;
//
//   Future<void> fetchProfileData() async {
//     const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";
//
//     try {
//       final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
//         'Authorization': 'Bearer ${accessToken}',
//       });
//       if (profileResponse.statusCode == 200) {
//         final Map<String, dynamic> profileJson =
//             json.decode(profileResponse.body);
//
//         setState(() {
//           userData = profileJson['user']['data'];
//           nameController.text = profileJson["user"]["data"]["name"];
//           phoneController.text = profileJson["user"]["data"]["phone_number"];
//           addressController.text = profileJson["user"]["data"]["address"];
//
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (error) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching data: $error")),
//       );
//     }
//   }
//
//   List<dynamic> cityList = [];
//   Future<List<dynamic>> getCity() async {
//     var url = Uri.parse('https://girlsparadisebd.com/api/v1/pathao_city_list');
//     var response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       try {
//         var dataList =
//             json.decode(response.body); // Parse the actual response body
//         cityList = dataList["data"] ?? []; // Handle null safety
//         setState(() {});
//         return cityList;
//       } catch (e) {
//         print("Error decoding JSON: $e");
//         return [];
//       }
//     } else {
//       print("HTTP Error: ${response.statusCode}, ${response.body}");
//       return [];
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadPaymentMethods();
//     loadCartItems();
//     loadDeliveryAreas();
//     loadCouriers();
//     fetchProfileData();
//     getCity();
//   }
//
//   // Update loadDeliveryAreas to store the data
//   Future<void> loadDeliveryAreas() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://girlsparadisebd.com/api/v1/delivery_areas'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           setState(() {
//             deliveryAreas = List<Map<String, dynamic>>.from(data['data']);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading delivery areas: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to load delivery areas',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Add loadCouriers method
//   Future<void> loadCouriers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://girlsparadisebd.com/api/v1/couriers'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           setState(() {
//             couriers = List<Map<String, dynamic>>.from(data['data']);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading couriers: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to load couriers',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Update getDeliveryAreaId method
//   int getDeliveryAreaId(String? area) {
//     final selectedDeliveryArea = deliveryAreas.firstWhere(
//       (element) => element['location'] == area,
//       orElse: () => {'id': '0'},
//     );
//     return int.parse(selectedDeliveryArea['id'].toString());
//   }
//
//   // Update getCourierId method
//   int getCourierId(String? courier) {
//     final selectedCourier = couriers.firstWhere(
//       (element) => element['name'] == courier,
//       orElse: () => {'id': '0'},
//     );
//     return int.parse(selectedCourier['id'].toString());
//   }
//
//   // Add method to update delivery charge
//   void updateDeliveryCharge(String? area) {
//     if (area != null) {
//       final selectedDeliveryArea = deliveryAreas.firstWhere(
//         (element) => element['location'] == area,
//         orElse: () => {'charge': '0'},
//       );
//       setState(() {
//         deliveryCharge =
//             double.parse(selectedDeliveryArea['charge'].toString());
//         calculateTotal(); // Recalculate total with new delivery charge
//       });
//     }
//   }
//
//   double? totalDiscount;
//   // Update calculateTotal method to include delivery charge
//   void calculateTotal() {
//     double total = 0;
//     double totalDiscount = 0; // Initialize total discount to 0
//     for (var item in ThiscartItems) {
//       int quantity = item['quantity'] ?? 1;
//       double price =
//           double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
//       double discount =
//           double.tryParse(item['discount']?.toString() ?? '0') ?? 0;
//       total += price * quantity;
//       totalDiscount +=
//           discount * quantity; // Accumulate discounts for all items
//     }
//     setState(() {
//       this.totalDiscount = totalDiscount; // Update the total discount
//       subtotal = total;
//     });
//   }
//
//   // Update the DropdownButtonFormField widgets in the build method
//   Widget buildDeliveryAreaDropdown() {
//     return DropdownButtonFormField(
//       value: selectedArea,
//       decoration: const InputDecoration(
//         labelText: 'Delivery Area *',
//         border: OutlineInputBorder(),
//       ),
//       items: deliveryAreas
//           .map((area) => DropdownMenuItem(
//                 value: area['location'],
//                 child: Text(area['location']),
//               ))
//           .toList(),
//       onChanged: (value) {
//         setState(() {
//           selectedArea = value as String?;
//           updateDeliveryCharge(value);
//         });
//       },
//     );
//   }
//
//   Widget buildCourierDropdown() {
//     return DropdownButtonFormField(
//       value: selectedCourier,
//       decoration: const InputDecoration(
//         labelText: 'Courier *',
//         border: OutlineInputBorder(),
//       ),
//       items: [
//         const DropdownMenuItem(
//           value: 'Select Courier',
//           child: Text('Select Courier'),
//         ),
//         ...couriers
//             .map((courier) => DropdownMenuItem(
//                   value: courier['name'],
//                   child: Text(courier['name']),
//                 ))
//             .toList(),
//       ],
//       onChanged: (value) {
//         setState(() {
//           selectedCourier = value as String?;
//           print("jj${selectedCourier}");
//         });
//       },
//     );
//   }
//
//   Map<String, dynamic> _standardizeProductData(
//       String id, Map<String, dynamic> data) {
//     // Determine product type based on available fields
//     String productType = _determineProductType(data);
//
//     // Create standardized product structure based on type
//     switch (productType) {
//       case 'regular':
//         return {
//           'id': id,
//           'short_name': data['short_name'] ?? data['name'] ?? 'Unknown Product',
//           'default_price': data['default_price']?.toString() ?? '0',
//           'default_image': data['default_image'] ?? '',
//           'quantity': data['quantity'] ?? 1,
//           'color': data['color'] ?? '',
//           'size': data['size'] ?? '',
//           'discount': data['discount'] ?? '',
//           "item_variant_id": data["variantId"],
//           'product_type': 'regular',
//         };
//
//       case 'new':
//         return {
//           'id': id,
//           'short_name': data['short_name'] ?? 'Unknown Product',
//           'default_price': data['sale_price']?.toString() ?? '0',
//           'default_image': data['image'] ?? '',
//           'quantity': data['quantity'] ?? 1,
//           'color': data['color'] ?? '',
//           'size': data['size'] ?? '',
//           'discount': data['discount'] ?? '',
//           "item_variant_id": data["variantId"],
//           'product_type': 'new',
//         };
//
//       case 'filter':
//         return {
//           'id': id,
//           'short_name': data['name'] ?? 'Unknown Product',
//           'default_price': data['price']?.toString() ?? '0',
//           'default_image': data['image'] ?? '',
//           'quantity': data['quantity'] ?? 1,
//           'discount': data['discount'] ?? '',
//           'color': data['color'] ?? '',
//           'size': data['size'] ?? '',
//           "item_variant_id": data["variantId"],
//           'product_type': 'filter',
//         };
//
//       default:
//         return {
//           'id': id,
//           'short_name': 'Unknown Product',
//           'default_price': '0',
//           'default_image': '',
//           'quantity': 1,
//           'color': '',
//           'discount': data['discount'] ?? '',
//           'size': '',
//           "item_variant_id": data["variantId"],
//           'product_type': 'unknown',
//         };
//     }
//   }
//
//   // Helper method to determine product type based on data structure
//   String _determineProductType(Map<String, dynamic> data) {
//     if (data.containsKey('default_price') &&
//         data.containsKey('default_image')) {
//       return 'regular';
//     } else if (data.containsKey('sale_price') &&
//         data.containsKey('short_name')) {
//       return 'new';
//     } else if (data.containsKey('price') && data.containsKey('name')) {
//       return 'filter';
//     }
//     return 'unknown';
//   }
//
//   Future<void> loadCartItems() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedCartItems = prefs.getStringList('cart_items') ?? [];
//       final cartProducts =
//           json.decode(prefs.getString('cart_products') ?? '{}');
//
//       // Log the raw data from SharedPreferences
//       print('Saved Cart Items IDs: ${json.encode(savedCartItems)}');
//       print('Raw Cart Products Data: ${json.encode(cartProducts)}');
//
//       setState(() {
//         ThiscartItems.clear();
//
//         for (String id in savedCartItems) {
//           if (cartProducts.containsKey(id)) {
//             try {
//               final productData = cartProducts[id];
//               if (productData != null) {
//                 // Log raw product data before standardization
//                 print(
//                     'Raw Product Data for ID $id: ${json.encode(productData)}');
//
//                 final standardizedProduct =
//                     _standardizeProductData(id, productData);
//
//                 // Log standardized product data
//                 print(
//                     'Standardized Product Data for ID $id: ${json.encode(standardizedProduct)}');
//
//                 ThiscartItems.add(standardizedProduct);
//               }
//             } catch (e) {
//               print('Error processing product $id: $e');
//             }
//           }
//         }
//
//         // Log final cart items array
//         print('Final Cart Items Array: ${json.encode(ThiscartItems)}');
//
//         calculateTotal();
//       });
//     } catch (e) {
//       print('Error loading cart items: $e');
//     }
//   }
//
//   Future<void> placeOrder() async {
//     // Input validation checks remain the same
//     if (nameController.text.isEmpty) {
//       Get.snackbar("Error", "Please enter your name",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (phoneController.text.isEmpty) {
//       Get.snackbar("Error", "Please enter your phone number",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//     if (addressController.text.isEmpty) {
//       Get.snackbar("Error", "Please enter your address",
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
//
//     try {
//       // Format order items according to API structure and product type
//       final formattedItems = ThiscartItems.map((item) {
//         // Determine if the item has a selected color
//         final bool hasSelectedColor =
//             item["color"] != null && item["color"].toString().isNotEmpty;
//
//         // Create the item structure based on whether color is selected
//         final Map<String, dynamic> baseItem = {
//           'item_id': int.parse(item['id'].toString()),
//           'item_name': item['short_name'],
//           'item_qty': item['quantity'] ?? 1,
//           'item_variant_id': item['item_variant_id'] ?? 0,
//           'item_color': hasSelectedColor ? (item['color'] ?? '') : '',
//           'item_size': hasSelectedColor ? (item['size'] ?? '') : '',
//           'item_discount': (item['discount'] ?? 0),
//         };
//
//         // Add type-specific fields based on product type
//         switch (item['product_type']) {
//           case 'regular':
//           case 'new':
//           case 'filter':
//             return {
//               ...baseItem,
//               'item_image': item['default_image'],
//               'item_default_price': item["discount"] == 0  || item["discount"] == ""
//                   ? double.parse(item['default_price'])
//                   : double.parse(item['default_price']) +
//                       item["discount"],
//               'item_price': double.parse(item['default_price'].toString()),
//             };
//
//           default:
//             return {
//               ...baseItem,
//               'item_image': '',
//               'item_default_price': 0.0,
//               'item_price': 0.0,
//             };
//         }
//       }).toList();
//
//       // Rest of the code remains the same
//       final orderData = {
//         'customer_name': nameController.text,
//         'phone_number': phoneController.text,
//         'address': addressController.text,
//         'delivery_id': getDeliveryAreaId(selectedArea),
//         'courier_id': getCourierId(selectedCourier),
//         'city_id': selectedCity ?? "",
//         'zone_id': selectedZone ?? "",
//         'area_id': selectedZoneArea ?? "",
//         'coupon_code': '',
//         'coupon_discount': widget.couponDiscount ?? 0.0,
//         'product_discount': totalDiscount ?? 0.0,
//         'delivery_charge': deliveryCharge,
//         'payment_type': selectedPaymentMethod,
//         'bank_receipt': '${ImagebaseUrl}${bankReceipte?.path}',
//         'delivery_status': 'Pending',
//         'order_from': 'app',
//         'items': formattedItems
//       };
//
//       // Show loading indicator
//       Get.dialog(
//         const Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false,
//       );
//
//       log("Order data ${orderData}");
//
//       // API call and response handling remain the same
//       final response = await http.post(
//           Uri.parse('https://girlsparadisebd.com/api/v1/checkout_order'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $accessToken'
//           },
//           body: json.encode(orderData));
//
//       Get.back(); // Dismiss loading indicator
//
//       if (response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//
//         // Clear cart after successful order
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setStringList('cart_items', []);
//         await prefs.setString('cart_products', '{}');
//         await prefs.setStringList('wishlist_items', []);
//         await prefs.setString('wishlist_products', '{}');
//
//         Get.offAll(() => const SuccessOrderScreen(),
//             transition: Transition.noTransition);
//       } else {
//         throw Exception('Failed to place order: ${response.body}');
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to place order: ${e.toString()}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> _pickImage(BuildContext context) async {
//     final picker = ImagePicker();
//
//     // Show bottom sheet with options
//     await showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Choose from Gallery'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final XFile? image = await picker.pickImage(
//                     source: ImageSource.gallery,
//                     imageQuality: 80,
//                   );
//                   if (image != null) {
//                     _handleImageSelection(File(image.path));
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take a Photo'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final XFile? image = await picker.pickImage(
//                     source: ImageSource.camera,
//                     imageQuality: 80,
//                   );
//                   if (image != null) {
//                     _handleImageSelection(File(image.path));
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _handleImageSelection(File image) {
//     setState(() {
//       bankReceipte = image;
//     });
//   }
//
//   var filterList = [
//     "Best Sale",
//     "High Rated",
//     "Low Rated",
//   ];
//
//   final CardController cardController = Get.put(CardController());
//   final ProfileController profileController = Get.put(ProfileController());
//
//   Future<void> loadCartCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCartItems = prefs.getStringList('cart_items') ?? [];
//     cardController.updateCartItemCount(savedCartItems.length);
//   }
//
//   final ProductController productController = Get.put(ProductController());
//   final BlogController blogController = Get.put(BlogController());
//   final TrendingController trendingController = Get.put(TrendingController());
//   final BestSellingController bestSellingController =
//       Get.put(BestSellingController());
//   final NewArrivalController newArrivalController =
//       Get.put(NewArrivalController());
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
//   Future<void> toggleCart(String productId, dynamic productData) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
//     Map<String, dynamic> cartProducts =
//         json.decode(prefs.getString('cart_products') ?? '{}');
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
//   File? bankReceipte;
//   Future<void> _launchMessenger() async {
//     const String messengerUrl = 'https://m.me/creationedges';
//
//     try {
//       await launchUrl(
//         Uri.parse(messengerUrl),
//         mode: LaunchMode.inAppBrowserView, // Open in-app web view or fallback
//       );
//     } catch (e) {
//       print('Could not launch Messenger: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         surfaceTintColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: Colors.white,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//               size: 25,
//               color: Colors.black,
//             ),
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//           ),
//         ),
//         title: const Text(
//           'Checkout',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Get.to(const SearchScreen(),
//                     transition: Transition.noTransition);
//               },
//               icon: const Icon(
//                 Icons.search_outlined,
//                 size: 30,
//                 color: Colors.black,
//               )),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   final result = await Get.to(
//                     const CartScreen(),
//                     transition: Transition.noTransition,
//                   );
//
//                   // Refresh cart when returning from CartScreen
//                   if (result == true) {
//                     await loadCartCount();
//                     await loadSavedStates();
//                     await newArrivalController.fetchProducts();
//                     await trendingController.fetchProducts();
//                     await bestSellingController.fetchProducts();
//                     await blogController.fetchProducts();
//                     // If HorizontalCard is stateful, we need to trigger a rebuild
//                     if (mounted) {
//                       setState(() {});
//                     }
//                   }
//                 },
//                 child: const Icon(
//                   Icons.shopping_cart_outlined,
//                   size: 25,
//                   color: Colors.black,
//                 ),
//               ),
//               Positioned(
//                 right: -1,
//                 bottom: 10,
//                 child: Obx(() {
//                   return Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       cardController.cartItemCount.value > 0
//                           ? '${cardController.cartItemCount.value}'
//                           : '0',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//           const SizedBox(
//             width: 6,
//           ),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   final result = await Get.to(const WishlistScreen(),
//                       transition: Transition.noTransition);
//
//                   // Refresh cart when returning from CartScreen
//                   if (result == true) {
//                     await loadCartCount();
//                     await loadSavedStates();
//                     await newArrivalController.fetchProducts();
//                     await trendingController.fetchProducts();
//                     await bestSellingController.fetchProducts();
//                     await blogController.fetchProducts();
//
//                     // If HorizontalCard is stateful, we need to trigger a rebuild
//                     if (mounted) {
//                       setState(() {});
//                     }
//                   }
//                 },
//                 child: const Icon(
//                   Icons.favorite_outline,
//                   size: 25,
//                   color: Colors.black,
//                 ),
//               ),
//               Positioned(
//                 right: -1,
//                 bottom: 10,
//                 child: Obx(() {
//                   return Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       cardController.wishlistItemCount.value > 0
//                           ? '${cardController.wishlistItemCount.value}'
//                           : '0',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//           SizedBox(
//             width: 6,
//           ),
//           SizedBox(
//             width: 6,
//           ),
//           GestureDetector(
//               onTap: _launchMessenger,
//               child: Image.asset(
//                 "assets/images/messenger.png",
//                 fit: BoxFit.contain,
//                 height: 20,
//                 width: 20,
//               )),
//           SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Order Summary
//               Padding(
//                 padding: const EdgeInsets.only(left: 2.0, right: 2),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Order Summary',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Divider(),
//                     const SizedBox(height: 6),
//                     ...ThiscartItems.map((item) => Card(
//                           elevation: 4,
//                           color: Colors.white,
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 16, left: 12, right: 12, bottom: 12),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 CachedNetworkImage(
//                                   imageUrl: "${ImagebaseUrl}${item['default_image']}",
//                                   width: 60,
//                                   height: 90,
//                                   fit: BoxFit.cover,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         item['short_name'] ?? 'Product Name',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 3),
//                                       Text(
//                                         'Quantity: ${item['quantity'] ?? 1}',
//                                         style:
//                                             const TextStyle(color: Colors.grey),
//                                       ),
//                                       const SizedBox(height: 3),
//                                       Text(
//                                         "Color: ${item["color"] ?? ""}",
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         "Size: ${item["size"] ?? ""}",
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 2),
//                                     ],
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       '৳${(double.parse(item['default_price'].toString()) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     item["discount"] == 0 || item["discount"] == ""
//                                         ? Container()
//                                         : const SizedBox(
//                                             width: 10,
//                                           ),
//                                     item["discount"] == 0 || item["discount"] == ""
//                                         ? Container()
//                                         : Text(
//                                             '৳ ${double.parse(item["default_price"]) + item["discount"]}',
//                                             style: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 decoration:
//                                                     TextDecoration.lineThrough),
//                                           ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Customer Information
//               Card(
//                 elevation: 4,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Delivery Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Name *',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: phoneController,
//                         decoration: const InputDecoration(
//                           labelText: 'Phone number *',
//                           border: OutlineInputBorder(),
//                         ),
//                         keyboardType: TextInputType.phone,
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: addressController,
//                         decoration: const InputDecoration(
//                           labelText: 'Address *',
//                           border: OutlineInputBorder(),
//                         ),
//                         maxLines: 2,
//                       ),
//                       const SizedBox(height: 16),
//                       buildDeliveryAreaDropdown(),
//                       const SizedBox(height: 16),
//                       buildCourierDropdown(),
//                       const SizedBox(height: 16),
//                       selectedCourier == "Pathao"
//                           ? LocationDropdown(
//                               selectedCity: selectedCity,
//                               selectedZone: selectedZone,
//                               selectedArea: selectedZoneArea,
//                             )
//                           : Container()
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Payment Method
//
//               Card(
//                 elevation: 4,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Payment Method',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       if (paymentMethods.isNotEmpty)
//                         ...paymentMethods.map((method) {
//                           if (method.slug == 'bank' &&
//                               selectedPaymentMethod == 'bank' &&
//                               method.details != null) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 RadioListTile(
//                                   title: Row(
//                                     children: [
//                                       if (method.image != null)
//                                         CachedNetworkImage(
//                                          imageUrl:  method.image!,
//                                           height: 30,
//                                           width: 30,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       const SizedBox(width: 10),
//                                       const Text('Bank Transfer'),
//                                     ],
//                                   ),
//                                   value: method.slug,
//                                   groupValue: selectedPaymentMethod,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedPaymentMethod = value.toString();
//                                     });
//                                   },
//                                 ),
//                                 if (method.details != null &&
//                                     selectedPaymentMethod == method.slug)
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 88.0, right: 8, bottom: 10),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Bank Name: ${method.details!['bank_name'] ?? ''}',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                         Text(
//                                           'Account Name: ${method.details!['account_name'] ?? ''}',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                         Text(
//                                           'Account Number: ${method.details!['account_number'] ?? ''}',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                         Text(
//                                           'Branch: ${method.details!['branch_name'] ?? ''}',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                         Text(
//                                           'Routing Number: ${method.details!['routing_number'] ?? ''}',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           height: 4,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                               ],
//                             );
//                           } else {
//                             return RadioListTile(
//                               title: Row(
//                                 children: [
//                                   if (method.image != null)
//                                     CachedNetworkImage(
//                                      imageUrl:  method.image!,
//                                       height: 30,
//                                       width: 60,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   const SizedBox(width: 10),
//                                   Text(method.name),
//                                 ],
//                               ),
//                               value: method.slug,
//                               groupValue: selectedPaymentMethod,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedPaymentMethod = value.toString();
//                                 });
//                               },
//                             );
//                           }
//                         }).toList(),
//
//                       // ...paymentMethods.map((method) {
//                       //   return RadioListTile(
//                       //     title: Row(
//                       //       children: [
//                       //         if (method.image != null)
//                       //           CachedNetworkImage(
//                       //             method.image!,
//                       //             height: 30,
//                       //             width: 60,
//                       //             fit: BoxFit.cover,
//                       //           ),
//                       //         const SizedBox(width: 10),
//                       //         Text(method.name),
//                       //       ],
//                       //     ),
//                       //     value: method.slug,
//                       //     groupValue: selectedPaymentMethod,
//                       //     onChanged: (value) {
//                       //       setState(() {
//                       //         selectedPaymentMethod = value.toString();
//                       //       });
//                       //     },
//                       //   );
//                       // }).toList(),
//                       if (selectedPaymentMethod == 'bank') ...[
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 10.0),
//                           child: Text(
//                             "Upload Bank Receipt Photo",
//                             style: TextStyle(fontSize: 16, color: Colors.black),
//                           ),
//                         ),
//                         bankReceipte == null
//                             ? GestureDetector(
//                                 onTap: () {
//                                   _pickImage(context);
//                                 },
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   height: 40,
//                                   width: 160,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.upload,
//                                           size: 30, color: Colors.white),
//                                       Text(
//                                         "Choose Photo",
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             : Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: Image.file(
//                                       bankReceipte!,
//                                       height: 150,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   Positioned(
//                                     right: 0,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           bankReceipte = null;
//                                         });
//                                       },
//                                       child: const Icon(Icons.close,
//                                           color: Colors.red),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Order Total
//               Card(
//                 elevation: 4,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('ItemCount'),
//                           Text('${ThiscartItems.length}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Item Subtotal'),
//                           Text('৳${subtotal}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Product Discount'),
//                           Text('৳${totalDiscount}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Coupon Discount'),
//                           Text('৳${widget.couponDiscount ?? 0.00}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Gross Total',
//                             style: TextStyle(fontWeight: FontWeight.normal),
//                           ),
//                           Text(
//                             '৳${(subtotal - widget.couponDiscount!).toStringAsFixed(2)}',
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.normal),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Delivery Charge'),
//                           Text('৳${deliveryCharge.toStringAsFixed(2)}'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       const Divider(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Net Total',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '৳${(subtotal + deliveryCharge - widget.couponDiscount!).toStringAsFixed(2)}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Place Order Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (selectedArea == null) {
//                       Get.snackbar("Error", "Please select your delivery area",
//                           backgroundColor: Colors.red, colorText: Colors.white);
//                     } else if (selectedCourier == null) {
//                       Get.snackbar("Error", "Please select your courier",
//                           backgroundColor: Colors.red, colorText: Colors.white);
//                     } else if (selectedPaymentMethod.isEmpty) {
//                       Get.snackbar("Error", "Please select your payment method",
//                           backgroundColor: Colors.red, colorText: Colors.white);
//                     } else {
//                       placeOrder();
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFFdc1212),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Place Order & Pay',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               BottomNavBar(),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class PaymentMethod {
//   final String name;
//   final String slug;
//   final String? image;
//   final Map<String, String>? details;
//
//   PaymentMethod({
//     required this.name,
//     required this.slug,
//     this.image,
//     this.details,
//   });
//
//   factory PaymentMethod.fromJson(Map<String, dynamic> json) {
//     return PaymentMethod(
//       name: json['name'],
//       slug: json['slug'],
//       image: json['image'],
//       details: json['details'] != null
//           ? Map<String, String>.from(json['details'])
//           : null,
//     );
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:creation_edge/screens/shop/controller/product_controller.dart';
import 'package:creation_edge/utils/local_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/cart_screen.dart';
import '../NativeServices/native_messenger_launcher.dart';
import '../Order/success_order_screen.dart';
import '../Profile/controller/profile_controller.dart';
import '../WishList/wishList_screen.dart';
import '../screens/Arraival/controller.dart';
import '../screens/Trending/controller.dart';
import '../screens/bestsale/controller.dart';
import '../screens/blog/blog_controller.dart';
import '../search/search_screen.dart';
import '../utils/constance.dart';
import '../utils/location.dart';

class CheckoutScreens extends StatefulWidget {
  final double? couponDiscount;
  const CheckoutScreens({super.key, this.couponDiscount});

  @override
  State<CheckoutScreens> createState() => _CheckoutScreensState();
}

class _CheckoutScreensState extends State<CheckoutScreens> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  List<Map<String, dynamic>> deliveryAreas = [];
  List<Map<String, dynamic>> couriers = [];
  List<PaymentMethod> paymentMethods = [];

  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    final response = await http.get(
      Uri.parse('https://girlsparadisebd.com/api/v1/payment_methods'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return (data as List)
          .map((item) => PaymentMethod.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  Future<void> loadPaymentMethods() async {
    try {
      final methods = await fetchPaymentMethods();
      setState(() {
        paymentMethods = methods;
        selectedPaymentMethod = methods.isNotEmpty ? methods.first.slug : '';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  String? selectedArea;
  String? selectedCourier;
  String? selectedCity;
  String? selectedZone;
  String? selectedZoneArea;
  String selectedPaymentMethod = 'Cash On Delivery';

  List<Map<String, dynamic>> ThiscartItems = [];
  double subtotal = 0;
  double deliveryCharge = 0;

  Map<String, dynamic>? userData;

  bool isLoading = true;

  Future<void> fetchProfileData() async {
    const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";

    try {
      final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer ${accessToken}',
      });
      if (profileResponse.statusCode == 200) {
        final Map<String, dynamic> profileJson =
        json.decode(profileResponse.body);

        setState(() {
          userData = profileJson['user']['data'];
          nameController.text = profileJson["user"]["data"]["name"];
          phoneController.text = profileJson["user"]["data"]["phone_number"];
          addressController.text = profileJson["user"]["data"]["address"];

          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $error")),
      );
    }
  }

  List<dynamic> cityList = [];
  Future<List<dynamic>> getCity() async {
    var url = Uri.parse('https://girlsparadisebd.com/api/v1/pathao_city_list');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        var dataList =
        json.decode(response.body); // Parse the actual response body
        cityList = dataList["data"] ?? []; // Handle null safety
        setState(() {});
        return cityList;
      } catch (e) {
        print("Error decoding JSON: $e");
        return [];
      }
    } else {
      print("HTTP Error: ${response.statusCode}, ${response.body}");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    loadPaymentMethods();
    loadCartItems();
    loadDeliveryAreas();
    loadCouriers();
    fetchProfileData();
    getCity();
  }

  // Update loadDeliveryAreas to store the data
  Future<void> loadDeliveryAreas() async {
    try {
      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/delivery_areas'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            deliveryAreas = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading delivery areas: $e');
      Get.snackbar(
        'Error',
        'Failed to load delivery areas',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add loadCouriers method
  Future<void> loadCouriers() async {
    try {
      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/couriers'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            couriers = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading couriers: $e');
      Get.snackbar(
        'Error',
        'Failed to load couriers',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Update getDeliveryAreaId method
  int getDeliveryAreaId(String? area) {
    final selectedDeliveryArea = deliveryAreas.firstWhere(
          (element) => element['location'] == area,
      orElse: () => {'id': '0'},
    );
    return int.parse(selectedDeliveryArea['id'].toString());
  }

  // Update getCourierId method
  int getCourierId(String? courier) {
    final selectedCourier = couriers.firstWhere(
          (element) => element['name'] == courier,
      orElse: () => {'id': '0'},
    );
    return int.parse(selectedCourier['id'].toString());
  }

  // Add method to update delivery charge
  void updateDeliveryCharge(String? area) {
    if (area != null) {
      final selectedDeliveryArea = deliveryAreas.firstWhere(
            (element) => element['location'] == area,
        orElse: () => {'charge': '0'},
      );
      setState(() {
        deliveryCharge =
            double.parse(selectedDeliveryArea['charge'].toString());
        calculateTotal(); // Recalculate total with new delivery charge
      });
    }
  }

  double? totalDiscount;
  // Update calculateTotal method to include delivery charge
  void calculateTotal() {
    double total = 0;
    double totalDiscount = 0; // Initialize total discount to 0
    for (var item in ThiscartItems) {
      int quantity = item['quantity'] ?? 1;
      double price =
          double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
      double discount =
          double.tryParse(item['discount']?.toString() ?? '0') ?? 0;
      total += price * quantity;
      totalDiscount +=
          discount * quantity; // Accumulate discounts for all items
    }
    setState(() {
      this.totalDiscount = totalDiscount; // Update the total discount
      subtotal = total;
    });
  }

  // Update the DropdownButtonFormField widgets in the build method
  Widget buildDeliveryAreaDropdown() {
    return DropdownButtonFormField(
      value: selectedArea,
      decoration: const InputDecoration(
        labelText: 'Delivery Area *',
        border: OutlineInputBorder(),
      ),
      items: deliveryAreas
          .map((area) => DropdownMenuItem(
        value: area['location'],
        child: Text(area['location']),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedArea = value as String?;
          updateDeliveryCharge(value);
        });
      },
    );
  }

  Widget buildCourierDropdown() {
    return DropdownButtonFormField(
      value: selectedCourier,
      decoration: const InputDecoration(
        labelText: 'Courier *',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: 'Select Courier',
          child: Text('Select Courier'),
        ),
        ...couriers
            .map((courier) => DropdownMenuItem(
          value: courier['name'],
          child: Text(courier['name']),
        ))
            .toList(),
      ],
      onChanged: (value) {
        setState(() {
          selectedCourier = value as String?;
          print("jj${selectedCourier}");
        });
      },
    );
  }

  Map<String, dynamic> _standardizeProductData(
      String id, Map<String, dynamic> data) {
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
          "item_variant_id": data["variantId"],
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
          'discount': data['discount'] ?? '',
          "item_variant_id": data["variantId"],
          'product_type': 'new',
        };

      case 'filter':
        return {
          'id': id,
          'short_name': data['name'] ?? 'Unknown Product',
          'default_price': data['price']?.toString() ?? '0',
          'default_image': data['image'] ?? '',
          'quantity': data['quantity'] ?? 1,
          'discount': data['discount'] ?? '',
          'color': data['color'] ?? '',
          'size': data['size'] ?? '',
          "item_variant_id": data["variantId"],
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
          'discount': data['discount'] ?? '',
          'size': '',
          "item_variant_id": data["variantId"],
          'product_type': 'unknown',
        };
    }
  }

  // Helper method to determine product type based on data structure
  String _determineProductType(Map<String, dynamic> data) {
    if (data.containsKey('default_price') &&
        data.containsKey('default_image')) {
      return 'regular';
    } else if (data.containsKey('sale_price') &&
        data.containsKey('short_name')) {
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
      final cartProducts =
      json.decode(prefs.getString('cart_products') ?? '{}');

      // Log the raw data from SharedPreferences
      print('Saved Cart Items IDs: ${json.encode(savedCartItems)}');
      print('Raw Cart Products Data: ${json.encode(cartProducts)}');

      setState(() {
        ThiscartItems.clear();

        for (String id in savedCartItems) {
          if (cartProducts.containsKey(id)) {
            try {
              final productData = cartProducts[id];
              if (productData != null) {
                // Log raw product data before standardization
                print(
                    'Raw Product Data for ID $id: ${json.encode(productData)}');

                final standardizedProduct =
                _standardizeProductData(id, productData);

                // Log standardized product data
                print(
                    'Standardized Product Data for ID $id: ${json.encode(standardizedProduct)}');

                ThiscartItems.add(standardizedProduct);
              }
            } catch (e) {
              print('Error processing product $id: $e');
            }
          }
        }

        // Log final cart items array
        print('Final Cart Items Array: ${json.encode(ThiscartItems)}');

        calculateTotal();
      });
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> placeOrder() async {
    // Input validation checks remain the same
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your name",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (phoneController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your phone number",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (addressController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your address",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      // Format order items according to API structure and product type
      final formattedItems = ThiscartItems.map((item) {
        // Determine if the item has a selected color
        final bool hasSelectedColor =
            item["color"] != null && item["color"].toString().isNotEmpty;

        // Create the item structure based on whether color is selected
        final Map<String, dynamic> baseItem = {
          'item_id': int.parse(item['id'].toString()),
          'item_name': item['short_name'],
          'item_qty': item['quantity'] ?? 1,
          'item_variant_id': item['item_variant_id'] ?? 0,
          'item_color': hasSelectedColor ? (item['color'] ?? '') : '',
          'item_size': hasSelectedColor ? (item['size'] ?? '') : '',
          'item_discount': (item['discount'] ?? 0),
        };

        // Add type-specific fields based on product type
        switch (item['product_type']) {
          case 'regular':
          case 'new':
          case 'filter':
            return {
              ...baseItem,
              'item_image': item['default_image'],
              'item_default_price': item["discount"] == 0  || item["discount"] == ""
                  ? double.parse(item['default_price'])
                  : double.parse(item['default_price']) +
                  item["discount"],
              'item_price': double.parse(item['default_price'].toString()),
            };

          default:
            return {
              ...baseItem,
              'item_image': '',
              'item_default_price': 0.0,
              'item_price': 0.0,
            };
        }
      }).toList();

      // Rest of the code remains the same
      final orderData = {
        'customer_name': nameController.text,
        'phone_number': phoneController.text,
        'address': addressController.text,
        'delivery_id': getDeliveryAreaId(selectedArea),
        'courier_id': getCourierId(selectedCourier),
        'city_id': selectedCity ?? "",
        'zone_id': selectedZone ?? "",
        'area_id': selectedZoneArea ?? "",
        'coupon_code': '',
        'coupon_discount': widget.couponDiscount ?? 0.0,
        'product_discount': totalDiscount ?? 0.0,
        'delivery_charge': deliveryCharge,
        'payment_type': selectedPaymentMethod,
        'bank_receipt': '${ImagebaseUrl}${bankReceipte?.path}',
        'delivery_status': 'Pending',
        'order_from': 'app',
        'items': formattedItems
      };

      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      log("Order data ${orderData}");

      // API call and response handling remain the same
      final response = await http.post(
          Uri.parse('https://girlsparadisebd.com/api/v1/checkout_order'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: json.encode(orderData));

      Get.back(); // Dismiss loading indicator

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Clear cart after successful order
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('cart_items', []);
        await prefs.setString('cart_products', '{}');
        await prefs.setStringList('wishlist_items', []);
        await prefs.setString('wishlist_products', '{}');

        Get.offAll(() => const SuccessOrderScreen(),
            transition: Transition.noTransition);
      } else {
        throw Exception('Failed to place order: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    _handleImageSelection(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    _handleImageSelection(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleImageSelection(File image) {
    setState(() {
      bankReceipte = image;
    });
  }

  var filterList = [
    "Best Sale",
    "High Rated",
    "Low Rated",
  ];

  final CardController cardController = Get.put(CardController());
  final ProfileController profileController = Get.put(ProfileController());

  Future<void> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    cardController.updateCartItemCount(savedCartItems.length);
  }

  final ProductController productController = Get.put(ProductController());
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

  File? bankReceipte;
  Future<void> _launchMessenger() async {
    await NativeMessengerLauncher.launchMessenger();
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
              Navigator.pop(context, true);
            },
          ),
        ),
        title: const Text(
          'Checkout',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Padding(
                padding: const EdgeInsets.only(left: 2.0, right: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const SizedBox(height: 6),
                    ...ThiscartItems.map((item) => Card(
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 12, right: 12, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              "${ImagebaseUrl}${item['default_image']}",
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['short_name'] ?? 'Product Name',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Quantity: ${item['quantity'] ?? 1}',
                                    style:
                                    const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Color: ${item["color"] ?? ""}",
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
                                  const SizedBox(height: 2),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '৳${(double.parse(item['default_price'].toString()) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                item["discount"] == 0 || item["discount"] == ""
                                    ? Container()
                                    : const SizedBox(
                                  width: 10,
                                ),
                                item["discount"] == 0 || item["discount"] == ""
                                    ? Container()
                                    : Text(
                                  '৳ ${double.parse(item["default_price"]) + item["discount"]}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                      TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Customer Information
              Card(
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone number *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      buildDeliveryAreaDropdown(),
                      const SizedBox(height: 16),
                      buildCourierDropdown(),
                      const SizedBox(height: 16),
                      selectedCourier == "Pathao"
                          ? LocationDropdown(
                        selectedCity: selectedCity,
                        selectedZone: selectedZone,
                        selectedArea: selectedZoneArea,
                      )
                          : Container()
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method

              Card(
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (paymentMethods.isNotEmpty)
                        ...paymentMethods.map((method) {
                          if (method.slug == 'bank' &&
                              selectedPaymentMethod == 'bank' &&
                              method.details != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile(
                                  title: Row(
                                    children: [
                                      if (method.image != null)
                                        Image.network(
                                          method.image!,
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      const SizedBox(width: 10),
                                      const Text('Bank Transfer'),
                                    ],
                                  ),
                                  value: method.slug,
                                  groupValue: selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentMethod = value.toString();
                                    });
                                  },
                                ),
                                if (method.details != null &&
                                    selectedPaymentMethod == method.slug)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 88.0, right: 8, bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bank Name: ${method.details!['bank_name'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Account Name: ${method.details!['account_name'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Account Number: ${method.details!['account_number'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Branch: ${method.details!['branch_name'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Routing Number: ${method.details!['routing_number'] ?? ''}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          } else {
                            return RadioListTile(
                              title: Row(
                                children: [
                                  if (method.image != null)
                                    Image.network(
                                      method.image!,
                                      height: 30,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  const SizedBox(width: 10),
                                  Text(method.name),
                                ],
                              ),
                              value: method.slug,
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value.toString();
                                });
                              },
                            );
                          }
                        }).toList(),

                      // ...paymentMethods.map((method) {
                      //   return RadioListTile(
                      //     title: Row(
                      //       children: [
                      //         if (method.image != null)
                      //           Image.network(
                      //             method.image!,
                      //             height: 30,
                      //             width: 60,
                      //             fit: BoxFit.cover,
                      //           ),
                      //         const SizedBox(width: 10),
                      //         Text(method.name),
                      //       ],
                      //     ),
                      //     value: method.slug,
                      //     groupValue: selectedPaymentMethod,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         selectedPaymentMethod = value.toString();
                      //       });
                      //     },
                      //   );
                      // }).toList(),
                      if (selectedPaymentMethod == 'bank') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Upload Bank Receipt Photo",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        bankReceipte == null
                            ? GestureDetector(
                          onTap: () {
                            _pickImage(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload,
                                    size: 30, color: Colors.white),
                                Text(
                                  "Choose Photo",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                            : Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                bankReceipte!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    bankReceipte = null;
                                  });
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Order Total
              Card(
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ItemCount'),
                          Text('${ThiscartItems.length}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Item Subtotal'),
                          Text('৳${subtotal}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Product Discount'),
                          Text('৳${totalDiscount}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coupon Discount'),
                          Text('৳${widget.couponDiscount ?? 0.00}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gross Total',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            '৳${(subtotal - widget.couponDiscount!).toStringAsFixed(2)}',
                            style:
                            const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Charge'),
                          Text('৳${deliveryCharge.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '৳${(subtotal + deliveryCharge - widget.couponDiscount!).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedArea == null) {
                      Get.snackbar("Error", "Please select your delivery area",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    } else if (selectedCourier == null) {
                      Get.snackbar("Error", "Please select your courier",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    } else if (selectedPaymentMethod.isEmpty) {
                      Get.snackbar("Error", "Please select your payment method",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    } else {
                      if(nameController.text=="Anonymous Customer"){
                        Get.snackbar("Error", "Please Update Your Delivery Name",
                            backgroundColor: Colors.red, colorText: Colors.white);


                      }else{
                        placeOrder();
                      }

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFdc1212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Place Order & Pay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BottomNavBar(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final String slug;
  final String? image;
  final Map<String, String>? details;

  PaymentMethod({
    required this.name,
    required this.slug,
    this.image,
    this.details,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
      details: json['details'] != null
          ? Map<String, String>.from(json['details'])
          : null,
    );
  }
}