import 'package:creation_edge/Order/delivery_order.dart';
import 'package:creation_edge/Order/order_screens.dart';
import 'package:creation_edge/Profile/update_profile.dart';
import 'package:creation_edge/fullView/image_full_view.dart';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:creation_edge/screens/home/home_screens.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import '../Auth/profile_auth.dart';
import '../utils/local_store.dart';

class TabProfile extends StatefulWidget {
  const TabProfile({super.key});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  int _selectedIndex = 0;

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });
    const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";
    const String dashboardUrl =
        "http://creationedge.com.bd/api/v1/order_dashboard";

    try {
      final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer ${accessToken}',
      });

      final dashboardResponse =
      await http.get(Uri.parse(dashboardUrl), headers: {
        'Authorization': 'Bearer ${accessToken}',
      });

      if (profileResponse.statusCode == 200 &&
          dashboardResponse.statusCode == 200) {
        final Map<String, dynamic> profileJson =
        json.decode(profileResponse.body);
        final Map<String, dynamic> dashboardJson =
        json.decode(dashboardResponse.body);

        setState(() {
          userData = profileJson['user']['data'];
          dashboardData = dashboardJson['data'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(
                    ImageFullView(
                      image: userData!['banner'],
                    ),
                    transition: Transition.noTransition);
              },
              child: Container(
                child: userData!['banner'] != null &&
                    userData!['banner'].isNotEmpty
                    ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: NetworkImage(
                          "${ImagebaseUrl}${userData!['banner']}"),
                      fit: BoxFit.fill,
                      onError: (exception, stackTrace) =>
                          Image.asset("assets/images/appbarlogo.png"),
                    ),
                  ),
                )
                    : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/appbarlogo.png"),
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[400],
                  backgroundImage:
                  NetworkImage("${ImagebaseUrl}${userData!['photo']}",),
                ),
              ),
            ),
          ],
        ),
        // Rest of the column children remain the same
        const SizedBox(height: 50),
        Text(
          userData!['name'] ?? "Anonymous Customer",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Joined on Jan 01, 2025",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            var result = await Get.to(
              UpdateProfileScreen(userData: userData!),
              transition: Transition.noTransition,
            );
            if (result == true) {
              setState(() {
                fetchProfileData();
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton("Dashboard", 0),
        const SizedBox(width: 8),
        _buildNavButton("Orders", 1),
        const SizedBox(width: 8),
        _buildNavButton("Delivery", 2),
      ],
    );
  }

  Widget _buildNavButton(String title, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedIndex == index ? Colors.indigo : Colors.white,
        side: const BorderSide(color: Colors.indigo),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.indigo),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int value) {
    return Card(
      elevation: 4,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SvgPicture.network(
            "https://girlsparadisebd.com/public/assets/images/icon/badge-outline-filled.svg",
            height: 50,
            width: 70,
          ),
          const SizedBox(height: 20),
          Center(
              child: Text("$value",
                  style: const TextStyle(fontSize: 16, color: Colors.black))),
          const SizedBox(height: 10),
          Center(
              child: Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.black))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: Text("About",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
              Icons.cake_outlined, "Born", "${userData!["dob"] ?? ""}"),
          _buildInfoRow(Icons.favorite_outline_rounded, "Status:", "Active",
              isBold: true),
          _buildInfoRow(
              Icons.email_outlined, "Email:", "${userData!["email"] ?? ""}",
              isBold: true),
          _buildInfoRow(Icons.location_on_outlined, "Address",
              "${userData!["address"] ?? ""}"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          width: double.infinity,
          child: _buildDashboardCard("Pending", dashboardData?['pending'] ?? 0),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: _buildDashboardCard(
              "Processing", dashboardData?['processing'] ?? 0),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: _buildDashboardCard(
              "Cancelled", dashboardData?['cancelled'] ?? 0),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          width: double.infinity,
          child:
          _buildDashboardCard("Complete", dashboardData?['completed'] ?? 0),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          width: double.infinity,
          child:
          _buildDashboardCard("Wishlist", dashboardData?['wishlist'] ?? 0),
        ),
        const SizedBox(height: 20),
        _buildAboutCard(),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return OrderScreen();
      case 2:
        return DeliveryOrder();
      default:
        return _buildDashboardContent();
    }
  }

  Future logout() async {
    var response = await http.post(
        Uri.parse("https://girlsparadisebd.com/api/v1/auth/logout"),
        headers: {"Authorization": "Bearer $accessToken"});
    if (response.statusCode == 200) {
      setState(() {
        Get.offAll(const HomeScreens(), transition: Transition.noTransition);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: accessToken.isEmpty
          ? const ProfileAuth()
          : isLoading
          ? Padding(
        padding: const EdgeInsets.only(left: 58.0, top: 111),
        child: LoadingAnimationWidget.progressiveDots(
            color: Color(0xFFdc1212), size: 30),
      )
          : userData == null
          ? const Center(child: Text("Failed to load profile"))
          : RefreshIndicator(
        onRefresh: () async {
          await fetchProfileData();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildNavigation(),
              const SizedBox(height: 16),
              _buildContent(),
              const SizedBox(height: 20),
              Padding(
                padding:
                const EdgeInsets.only(left: 18.0, right: 18),
                child: GestureDetector(
                  onTap: () async {
                    if (accessToken.isNotEmpty) {
                      setAccessToken("");
                      await logout();
                    }
                  },
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFdc1212),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding:
                const EdgeInsets.only(left: 18.0, right: 18),
                child: GestureDetector(
                  onTap: () async {
                    if (accessToken.isNotEmpty) {
                      setAccessToken("");
                      await logout();
                    }
                  },
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFdc1212),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Delete Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const BottomNavBar(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
