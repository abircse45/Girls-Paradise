// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../../utils/constance.dart';
//
// class ProfileController extends GetxController {
//   var userData = Rx<Map<String, dynamic>?>(null);
//   var dashboardData = Rx<Map<String, dynamic>?>(null);
//   var isLoading = true.obs;
//   var selectedIndex = 0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchProfileData();
//   }
//
//   void setSelectedIndex(int index) {
//     selectedIndex.value = index;
//   }
//
//   Future<void> fetchProfileData() async {
//     const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";
//     const String dashboardUrl = "http://creationedge.com.bd/api/v1/order_dashboard";
//
//     try {
//       isLoading.value = true;
//
//       final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
//         'Authorization': 'Bearer ${accessToken}',
//       });
//
//       final dashboardResponse = await http.get(Uri.parse(dashboardUrl), headers: {
//         'Authorization': 'Bearer ${accessToken}',
//       });
//
//       if (profileResponse.statusCode == 200 && dashboardResponse.statusCode == 200) {
//         final Map<String, dynamic> profileJson = json.decode(profileResponse.body);
//         final Map<String, dynamic> dashboardJson = json.decode(dashboardResponse.body);
//
//         userData.value = profileJson['user']['data'];
//         dashboardData.value = dashboardJson['data'];
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (error) {
//
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> refreshProfile() async {
//     await fetchProfileData();
//   }
// }
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/constance.dart';

class ProfileController extends GetxController {
  var userData = Rx<Map<String, dynamic>?>(null);
  var dashboardData = Rx<Map<String, dynamic>?>(null);
  var isLoading = true.obs;
  var selectedIndex = 0.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  Future<void> fetchProfileData() async {
    const String apiUrl = "https://girlsparadisebd.com/api/v1/profile";
    const String dashboardUrl = "http://creationedge.com.bd/api/v1/order_dashboard";

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Fetching profile data...');
      print('Access Token: $accessToken');

      // Fetch Profile Data
      final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      print('Profile Response Status: ${profileResponse.statusCode}');
      print('Profile Response Body: ${profileResponse.body}');

      if (profileResponse.statusCode == 200) {
        final Map<String, dynamic> profileJson = json.decode(profileResponse.body);

        // Check if the response has the expected structure
        if (profileJson.containsKey('user') &&
            profileJson['user'].containsKey('data')) {
          userData.value = profileJson['user']['data'];
          print('Profile data loaded successfully: ${userData.value}');
        } else {
          print('Unexpected profile response structure: $profileJson');
          errorMessage.value = 'Invalid profile data structure';
        }
      } else {
        print('Profile API failed with status: ${profileResponse.statusCode}');
        errorMessage.value = 'Failed to load profile: ${profileResponse.statusCode}';
      }

      // Fetch Dashboard Data (separate from profile, don't fail if this fails)
      try {
        final dashboardResponse = await http.get(Uri.parse(dashboardUrl), headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        print('Dashboard Response Status: ${dashboardResponse.statusCode}');
        print('Dashboard Response Body: ${dashboardResponse.body}');

        if (dashboardResponse.statusCode == 200) {
          final Map<String, dynamic> dashboardJson = json.decode(dashboardResponse.body);

          if (dashboardJson.containsKey('data')) {
            dashboardData.value = dashboardJson['data'];
            print('Dashboard data loaded successfully: ${dashboardData.value}');
          } else {
            print('Dashboard response does not contain data field');
            // Set default dashboard data
            dashboardData.value = {
              'pending': 0,
              'processing': 0,
              'cancelled': 0,
              'completed': 0,
              'wishlist': 0,
            };
          }
        } else {
          print('Dashboard API failed with status: ${dashboardResponse.statusCode}');
          // Set default dashboard data
          dashboardData.value = {
            'pending': 0,
            'processing': 0,
            'cancelled': 0,
            'completed': 0,
            'wishlist': 0,
          };
        }
      } catch (dashboardError) {
        print('Dashboard API error: $dashboardError');
        // Set default dashboard data
        dashboardData.value = {
          'pending': 0,
          'processing': 0,
          'cancelled': 0,
          'completed': 0,
          'wishlist': 0,
        };
      }

    } catch (error) {
      print('Error in fetchProfileData: $error');
      errorMessage.value = 'Network error: $error';

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to load profile data. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchProfileData();
  }

  // Helper method to check if profile data is loaded
  bool get hasProfileData => userData.value != null;

  // Helper method to check if dashboard data is loaded
  bool get hasDashboardData => dashboardData.value != null;

  // Helper method to get user name
  String get userName => userData.value?['name'] ?? 'Anonymous Customer';

  // Helper method to get user email
  String get userEmail => userData.value?['email'] ?? 'Not provided';

  // Helper method to get user photo
  String? get userPhoto => userData.value?['photo'];

  // Helper method to get user banner
  String? get userBanner => userData.value?['banner'];

  // Helper method to get dashboard count
  int getDashboardCount(String key) {
    return dashboardData.value?[key] ?? 0;
  }

  // Method to handle logout
  Future<void> logout() async {
    try {
      final response = await http.post(
          Uri.parse("https://girlsparadisebd.com/api/v1/auth/logout"),
          headers: {
            "Authorization": "Bearer $accessToken",
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      print('Logout Response Status: ${response.statusCode}');

      // Clear data regardless of API response
      userData.value = null;
      dashboardData.value = null;

      // Clear access token (you'll need to implement this in your local storage)
      // setAccessToken("");

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      print('Logout error: $e');
      // Clear data even if logout API fails
      userData.value = null;
      dashboardData.value = null;

      Get.snackbar(
        'Info',
        'Logged out locally',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}