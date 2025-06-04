import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/constance.dart';

class ProfileController extends GetxController {
  var userData = Rx<Map<String, dynamic>?>(null);
  var dashboardData = Rx<Map<String, dynamic>?>(null);
  var isLoading = true.obs;
  var selectedIndex = 0.obs;

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

      final profileResponse = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer ${accessToken}',
      });

      final dashboardResponse = await http.get(Uri.parse(dashboardUrl), headers: {
        'Authorization': 'Bearer ${accessToken}',
      });

      if (profileResponse.statusCode == 200 && dashboardResponse.statusCode == 200) {
        final Map<String, dynamic> profileJson = json.decode(profileResponse.body);
        final Map<String, dynamic> dashboardJson = json.decode(dashboardResponse.body);

        userData.value = profileJson['user']['data'];
        dashboardData.value = dashboardJson['data'];
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchProfileData();
  }
}