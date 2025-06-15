// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:creation_edge/Order/delivery_order.dart';
// import 'package:creation_edge/Order/order_screens.dart';
// import 'package:creation_edge/Profile/controller/profile_controller.dart';
// import 'package:creation_edge/Profile/update_profile.dart';
// import 'package:creation_edge/screens/home/bottomNavbbar.dart';
// import 'package:creation_edge/screens/home/home_screens.dart';
// import 'package:creation_edge/utils/constance.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:loading_animation_widget/loading_animation_widget.dart';
//
// import '../fullView/image_full_view.dart';
// import '../utils/local_store.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final ProfileController profileController = Get.put(ProfileController());
//
//   Widget _buildProfileHeader(ProfileController userData) {
//     return Column(
//       children: [
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             GestureDetector(
//               onTap: (){
//                 Get.to(ImageFullView(image: userData.userData.value!['banner'],),transition: Transition.noTransition);
//               },
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 color: Colors.grey[300],
//                 child: userData.userData.value!['banner'] != null &&
//                     userData.userData.value!['banner'].isNotEmpty
//                     ? CachedNetworkImage(
//                     imageUrl: "${ImagebaseUrl}${userData.userData.value!['banner']}",
//                     fit: BoxFit.fill)
//                     : Image.asset("assets/images/appbarlogo.png"),
//               ),
//             ),
//             Positioned(
//               bottom: -40,
//               left: MediaQuery.of(context).size.width / 2 - 40,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage: userData.userData.value!['photo'] != null &&
//                     userData.userData.value!['photo'].isNotEmpty
//                     ? NetworkImage(
//                     "${ImagebaseUrl}${userData.userData.value!['photo']}")
//                     : null,
//                 backgroundColor: Colors.grey[400],
//                 child: userData.userData.value!['photo'] == null ||
//                     userData.userData.value!['photo'].isEmpty
//                     ? const Icon(Icons.person, size: 40, color: Colors.white)
//                     : null,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 50),
//         Text(
//           userData.userData.value!['name'] ?? "Anonymous Customer",
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           "Joined on Jan 01, 2025",
//           style: TextStyle(fontSize: 14, color: Colors.grey),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () async {
//             var result = await Get.to(
//                 UpdateProfileScreen(userData: userData.userData.value!),
//                 transition: Transition.noTransition);
//             if (result == true) {
//               setState(() {
//                 profileController.fetchProfileData();
//               });
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.redAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           child: const Text("Edit Profile",
//               style: TextStyle(fontSize: 14, color: Colors.white)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNavigation() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildNavButton("Dashboard", 0),
//         const SizedBox(width: 8),
//         _buildNavButton("Orders", 1),
//         const SizedBox(width: 8),
//         _buildNavButton("Delivery", 2),
//       ],
//     );
//   }
//
//   Widget _buildNavButton(String title, int index) {
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           profileController.selectedIndex.value = index;
//         });
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: profileController.selectedIndex.value == index
//             ? Colors.indigo
//             : Colors.white,
//         side: const BorderSide(color: Colors.indigo),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//             color: profileController.selectedIndex.value == index
//                 ? Colors.white
//                 : Colors.indigo),
//       ),
//     );
//   }
//
//   Widget _buildDashboardCard(String title, int value) {
//     return Card(
//       elevation: 4,
//       color: Colors.white,
//       surfaceTintColor: Colors.white,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           SvgPicture.network(
//             "https://girlsparadisebd.com/public/assets/images/icon/badge-outline-filled.svg",
//             height: 50,
//             width: 70,
//           ),
//           const SizedBox(height: 20),
//           Center(
//               child: Text("$value",
//                   style: const TextStyle(fontSize: 16, color: Colors.black))),
//           const SizedBox(height: 10),
//           Center(
//               child: Text(title,
//                   style: const TextStyle(fontSize: 16, color: Colors.black))),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAboutCard() {
//     return Card(
//       elevation: 4,
//       color: Colors.white,
//       surfaceTintColor: Colors.white,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           const Padding(
//             padding: EdgeInsets.only(left: 18.0),
//             child: Text("About",
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(height: 15),
//           _buildInfoRow(Icons.cake_outlined, "Born",
//               "${profileController.userData.value!["dob"] ?? ""}"),
//           _buildInfoRow(Icons.favorite_outline_rounded, "Status:", "Active",
//               isBold: true),
//           _buildInfoRow(Icons.email_outlined, "Email:",
//               "${profileController.userData.value!["email"] ?? ""}",
//               isBold: true),
//           _buildInfoRow(Icons.location_on_outlined, "Address",
//               "${profileController.userData.value!["address"] ?? ""}"),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value,
//       {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
//       child: Row(
//         children: [
//           Icon(icon),
//           const SizedBox(width: 10),
//           Text(label,
//               style: const TextStyle(fontSize: 16, color: Colors.black)),
//           const SizedBox(width: 10),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDashboardContent() {
//     return Column(
//       children: [
//         SizedBox(
//           height: 170,
//           width: double.infinity,
//           child: _buildDashboardCard("Pending",
//               profileController.dashboardData.value?['pending'] ?? 0),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 170,
//           width: double.infinity,
//           child: _buildDashboardCard("Processing",
//               profileController.dashboardData.value?['processing'] ?? 0),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 170,
//           width: double.infinity,
//           child: _buildDashboardCard("Cancelled",
//               profileController.dashboardData.value?['cancelled'] ?? 0),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 170,
//           width: double.infinity,
//           child: _buildDashboardCard("Complete",
//               profileController.dashboardData.value?['completed'] ?? 0),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 170,
//           width: double.infinity,
//           child: _buildDashboardCard("Wishlist",
//               profileController.dashboardData.value?['wishlist'] ?? 0),
//         ),
//         const SizedBox(height: 20),
//         _buildAboutCard(),
//       ],
//     );
//   }
//
//   Widget _buildContent() {
//     switch (profileController.selectedIndex.value) {
//       case 0:
//         return _buildDashboardContent();
//       case 1:
//         return OrderScreen();
//       case 2:
//         return DeliveryOrder();
//       default:
//         return _buildDashboardContent();
//     }
//   }
//   Future logout() async {
//     var response = await http.post(
//         Uri.parse("https://girlsparadisebd.com/api/v1/auth/logout"),
//         headers: {"Authorization": "Bearer $accessToken"});
//     if (response.statusCode == 200) {
//       setState(() {
//         Get.offAll(const HomeScreens(), transition: Transition.noTransition);
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Get.offAll(const HomeScreens(),
//                   transition: Transition.noTransition);
//             },
//             icon: Icon(Icons.arrow_back)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor:Color(0xFFdc1212),
//         surfaceTintColor:Color(0xFFdc1212),
//         title: const Text("Profile", style: TextStyle(color: Colors.white)),
//       ),
//       body: Obx(() {
//         if (profileController.isLoading.value) {
//           return  LoadingAnimationWidget.progressiveDots(color: Color(0xFFdc1212), size: 30);
//         } else {
//           return profileController.userData.value == null
//               ? const Center(child: Text("Failed to load profile"))
//               : SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfileHeader(profileController),
//                 const SizedBox(height: 16),
//                 _buildNavigation(),
//                 const SizedBox(height: 16),
//                 _buildContent(),
//
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding:
//                   const EdgeInsets.only(left: 18.0, right: 18),
//                   child: GestureDetector(
//                     onTap: () async {
//                       if (accessToken.isNotEmpty) {
//                         setAccessToken("");
//                         await logout();
//                       }
//                     },
//                     child: Center(
//                       child: Container(
//                         alignment: Alignment.center,
//                         height: 50,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFdc1212),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Text(
//                           "Logout",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding:
//                   const EdgeInsets.only(left: 18.0, right: 18),
//                   child: GestureDetector(
//                     onTap: () async {
//                       if (accessToken.isNotEmpty) {
//                         setAccessToken("");
//                         await logout();
//                       }
//                     },
//                     child: Center(
//                       child: Container(
//                         alignment: Alignment.center,
//                         height: 50,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFdc1212),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Text(
//                           "Delete Account",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const BottomNavBar(),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           );
//         }
//       }),
//     );
//   }
// }
