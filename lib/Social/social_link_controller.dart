import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SocialLinksController extends GetxController {
  // Observable list to store social links
  var socialLinks = <SocialLink>[].obs;
  var isLoading = true.obs;

  // API URL
  final String apiUrl = "https://girlsparadisebd.com/api/v1/social_links";

  @override
  void onInit() {
    super.onInit();
    fetchSocialLinks(); // Fetch data when the controller is initialized
  }

  // Function to fetch social links from the API
  Future<void> fetchSocialLinks() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("re--${response.body}");
        if (data['success'] == true) {
          // Parse the list of social links
          socialLinks.value = (data['data'] as List)
              .map((e) => SocialLink.fromJson(e))
              .toList();
        } else {
          Get.snackbar("Error", "Failed to fetch social links");
        }
      } else {
        Get.snackbar("Error", "Failed to fetch data. Status: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }
  }
}

// Model for a single social link
class SocialLink {
  final String name;
  final String icon;
  final String iconImage;
  final String link;

  SocialLink({
    required this.name,
    required this.icon,
    required this.iconImage,
    required this.link,
  });

  // Factory method to parse JSON
  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      name: json['name'] as String,
      icon: json['icon'] as String,
      iconImage: json['icon_image'] as String,
      link: json['link'] as String,
    );
  }
}
