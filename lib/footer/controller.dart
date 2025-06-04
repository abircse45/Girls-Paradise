import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screens/home/bottomNavbbar.dart';

class FooterController extends GetxController {
  var footerSettings = Rx<FooterSettings?>(null);
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
   // fetchFooterSettings();
  }

  Future<void> fetchFooterSettings() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/footer_settings'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        footerSettings.value = FooterSettings.fromJson(jsonData);
      } else {
        throw Exception('Failed to load footer data');
      }
    } catch (e) {
      print('Error fetching footer settings: $e');
      footerSettings.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
