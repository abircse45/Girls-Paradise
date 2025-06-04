import 'dart:convert';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:creation_edge/screens/home/home_screens.dart';
import 'package:http/http.dart'as http;
import 'package:creation_edge/Profile/profile_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constance.dart';

 class SuccessOrderScreen extends StatefulWidget {
   const SuccessOrderScreen({super.key});

   @override
   State<SuccessOrderScreen> createState() => _SuccessOrderScreenState();
 }

 class _SuccessOrderScreenState extends State<SuccessOrderScreen> {

   List<Map<String, dynamic>> deliveryAreas = [];
   List<Map<String, dynamic>> couriers = [];

   String? name;
   String? phone;
   String? address;
   String? selectedArea;
   String? selectedCourier;
   String selectedPaymentMethod = 'Cash On Delivery';

   List<Map<String, dynamic>> cartItems = [];
   double subtotal = 0;
   double deliveryCharge = 0;
   double couponDiscount = 0;

   bool isLoading = false;
   Map<String, dynamic>? userData;
   void calculateTotal() {
     double total = 0;
     for (var item in cartItems) {
       int quantity = item['quantity'] ?? 1;
       double price = double.tryParse(item['default_price']?.toString() ?? '0') ?? 0;
       total += price * quantity;
     }
     setState(() {
       subtotal = total;
     });
   }
   Future<void> fetchProfileData() async {
     const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";

     try {
       final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
         'Authorization': 'Bearer ${accessToken}',
       });
       if (profileResponse.statusCode == 200) {
         final Map<String, dynamic> profileJson = json.decode(profileResponse.body);

         setState(() {
           userData = profileJson['user']['data'];
           name = profileJson["user"]["data"]["name"];
           phone = profileJson["user"]["data"]["phone_number"];
           address = profileJson["user"]["data"]["address"];

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
   Future<void> loadCartItems() async {
     final prefs = await SharedPreferences.getInstance();
     final savedCartItems = prefs.getStringList('cart_items') ?? [];
     final cartProducts = json.decode(prefs.getString('cart_products') ?? '{}');

     setState(() {
       cartItems = savedCartItems
           .map((id) => {
         ...Map<String, dynamic>.from(cartProducts[id] ?? {}),
         'id': id,
       })
           .toList();
       calculateTotal();
     });
   }

   @override
   void initState() {
     super.initState();
     loadCartItems();
     fetchProfileData();
   }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey[50],
       appBar: AppBar(
         surfaceTintColor:   Color(0xFFdc1212),
         centerTitle: true,
         title: const Text(
           'Order Success',
           style: TextStyle(
             color: Colors.white,
             fontSize: 20,
             fontWeight: FontWeight.w500,
           ),
         ),
         backgroundColor: Color(0xFFdc1212),
         elevation: 0,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () {
             Get.offAll(HomeScreens(),transition: Transition.noTransition);
           },
         ),
       ),

       body: SingleChildScrollView(
         child: Column(
           children: [
             Center(
               child:  SizedBox(
             
                 width: double.infinity,
                 child: Card(
                   elevation: 0,
                   color: Colors.white,
                   surfaceTintColor: Colors.white,
                   margin: const EdgeInsets.symmetric(horizontal: 16),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       const SizedBox(height: 20),
                       SvgPicture.network(
                         "https://girlsparadisebd.com/public/assets/images/icon/badge-outline-filled.svg",
                         height: 50,
                         width: 70,
                       ),
                       const SizedBox(height: 20),
                       Center(child: Text("Thank you for your order!", style:  TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold))),
                       const SizedBox(height: 10),
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Container(
                           padding: EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(10),
                             color: Colors.grey[200]
                           ),
                             child: Center(child: Column(
                               children: [
                                 Text("Your order has been placed and you will shorty receive SMS confirmation. You can check the status of your order at any time by going to", style: const TextStyle(fontSize: 16, color: Colors.black,),textAlign: TextAlign.center,),
                                 SizedBox(height: 20,),
                                 GestureDetector(
                                   onTap: (){
                                     Get.to(const ProfileScreen(),transition: Transition.noTransition);
                                   },
                                     child: Container(
                                       height: 40,
                                       width: 300,
                                       decoration: BoxDecoration(
                                         color: Colors.red,
                                         borderRadius: BorderRadius.circular(10)
                                       ),
                                         child: Center(child: Text("My Account", style:  TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold))))),
             
                               ],
                             ))),
                       ),
                       const SizedBox(height: 10),
             
             
                       BottomNavBar(),
             
                       // const SizedBox(height: 10),
                       // ...cartItems.map((item) => Padding(
                       //   padding: const EdgeInsets.only(bottom: 8.0),
                       //   child: Card(
                       //     elevation: 2,
                       //     color: Colors.white,
                       //     child: Row(
                       //       children: [
                       //         Padding(
                       //           padding: const EdgeInsets.all(8.0),
                       //           child: CachedNetworkImage(
                       //             "${ImagebaseUrl}${item['default_image']}",
                       //             width: 60,
                       //             height: 60,
                       //             fit: BoxFit.cover,
                       //           ),
                       //         ),
                       //         const SizedBox(width: 12),
                       //         Expanded(
                       //           child: Column(
                       //             crossAxisAlignment: CrossAxisAlignment.start,
                       //             children: [
                       //               Text(
                       //                 item['short_name'] ?? 'Product Name',
                       //                 style: const TextStyle(fontWeight: FontWeight.bold),
                       //               ),
                       //               Text(
                       //                 'Quantity: ${item['quantity']??1}',
                       //                 style: const TextStyle(color: Colors.grey),
                       //               ),
                       //             ],
                       //           ),
                       //         ),
                       //         Padding(
                       //           padding: const EdgeInsets.all(8.0),
                       //           child: Text(
                       //             '৳${(double.parse(item['default_price'].toString()) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                       //             style: const TextStyle(fontWeight: FontWeight.bold),
                       //           ),
                       //         ),
                       //       ],
                       //     ),
                       //   ),
                       // )),
                       // const SizedBox(height: 10),
                       // Card(
                       //   elevation: 4,
                       //   color: Colors.white,
                       //   child: Padding(
                       //     padding: const EdgeInsets.all(16.0),
                       //     child: Column(
                       //       children: [
                       //         Row(
                       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       //           children: [
                       //             const Text('Subtotal'),
                       //             Text('৳${subtotal.toStringAsFixed(2)}'),
                       //           ],
                       //         ),
                       //         const SizedBox(height: 8),
                       //         Row(
                       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       //           children: [
                       //             const Text('Delivery Charge'),
                       //             Text('৳${deliveryCharge.toStringAsFixed(2)}'),
                       //           ],
                       //         ),
                       //         const SizedBox(height: 8),
                       //         Row(
                       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       //           children: [
                       //             const Text('Coupon Discount'),
                       //             Text('৳${couponDiscount.toStringAsFixed(2)}'),
                       //           ],
                       //         ),
                       //         const Divider(),
                       //         Row(
                       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       //           children: [
                       //             const Text(
                       //               'Total',
                       //               style: TextStyle(fontWeight: FontWeight.bold),
                       //             ),
                       //             Text(
                       //               '৳${(subtotal + deliveryCharge - couponDiscount).toStringAsFixed(2)}',
                       //               style: const TextStyle(fontWeight: FontWeight.bold),
                       //             ),
                       //           ],
                       //         ),
                       //       ],
                       //     ),
                       //   ),
                       // ),
                       // const SizedBox(height: 10),
                       const SizedBox(height: 10),
                     ],
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }


 }
