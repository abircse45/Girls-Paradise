import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Order/how_to_order.dart';
import 'package:creation_edge/Order/shipping_policy.dart';
import 'package:creation_edge/footer/controller.dart';
import 'package:creation_edge/screens/about_us_screen/about_us.dart';
import 'package:creation_edge/screens/contact_us/contact_us_screens.dart';
import 'package:creation_edge/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:creation_edge/screens/return_refund/return_refund.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../NativeServices/native_messenger_launcher.dart';

FooterSettings footerSettingsFromJson(String str) => FooterSettings.fromJson(json.decode(str));

String footerSettingsToJson(FooterSettings data) => json.encode(data.toJson());

class FooterSettings {
  List<DatumBottom>? data;
  bool? success;
  int? status;

  FooterSettings({
    this.data,
    this.success,
    this.status,
  });

  factory FooterSettings.fromJson(Map<String, dynamic> json) => FooterSettings(
    data: json["data"] == null ? [] : List<DatumBottom>.from(json["data"]!.map((x) => DatumBottom.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class DatumBottom {
  dynamic? id;
  String? footerText;
  String? footerAddress;
  String? footerLogo;
  String? helplineNumber;
  String? copyrightText;
  String? googleMapLink;
  String? facebookPageLink;
  dynamic facebookGroupLink;
  String? youttubeChannelLink;

  DatumBottom({
    this.id,
    this.footerText,
    this.footerAddress,
    this.footerLogo,
    this.helplineNumber,
    this.copyrightText,
    this.googleMapLink,
    this.facebookPageLink,
    this.facebookGroupLink,
    this.youttubeChannelLink,
  });

  factory DatumBottom.fromJson(Map<String, dynamic> json) => DatumBottom(
    id: json["id"],
    footerText: json["footer_text"],
    footerAddress: json["footer_address"],
    footerLogo: json["footer_logo"],
    helplineNumber: json["helpline_number"],
    copyrightText: json["copyright_text"],
    googleMapLink: json["google_map_link"],
    facebookPageLink: json["facebook_page_link"],
    facebookGroupLink: json["facebook_group_link"],
    youttubeChannelLink: json["youttube_channel_link"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "footer_text": footerText,
    "footer_address": footerAddress,
    "footer_logo": footerLogo,
    "helpline_number": helplineNumber,
    "copyright_text": copyrightText,
    "google_map_link": googleMapLink,
    "facebook_page_link": facebookPageLink,
    "facebook_group_link": facebookGroupLink,
    "youttube_channel_link": youttubeChannelLink,
  };
}





class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  final FooterController footerController = Get.put(FooterController());

  Future<void> _launchUrl(String? url) async {
    if (url == null) {
      print("Invalid URL: $url");
      return;
    }

    // Extract the src from iframe if iframe content is provided
    if (url.startsWith('<iframe')) {
      final regex = RegExp(r'src="([^"]+)"');
      final match = regex.firstMatch(url);
      if (match != null) {
        url = match.group(1);
      } else {
        print("No src found in iframe");
        return;
      }
    }
    await NativeMessengerLauncher.clickhere(Uri.parse(url!));
  }
  void _openWhatsApp() async {
   await NativeMessengerLauncher.openWhatsApp(phoneNumber: "+8809606500333");
  }

  @override
  Widget build(BuildContext context) {

    return Obx((){
      if (footerController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (footerController.footerSettings.value == null || footerController.footerSettings!.value!.data == null) {
        return const Center(child: Text('Failed to load footer data'));
      }

      final footer = footerController.footerSettings!.value!.data!.first;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (footer.footerLogo != null)
              CachedNetworkImage(
                imageUrl: '$ImagebaseUrl${footer.footerLogo}',
                height: 70,
                width: 200,
                errorWidget: (context, error, stackTrace) =>
                const Icon(Icons.error),
              ),

            if (footer.footerText != null)
              HtmlWidget(
                footer.footerText!,
                textStyle: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (footer.footerAddress != null) ...[
              const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
              HtmlWidget(footer.footerAddress!),
              const SizedBox(height: 8),
            ],
            if (footer.helplineNumber != null) ...[
              const Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () => _launchUrl('tel:${footer.helplineNumber}'),
                child: Text(
                  footer.helplineNumber!,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Quick Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _buildQuickLinks(),
            const SizedBox(height: 16),
            if (footer.googleMapLink != null)
              InkWell(
                onTap: () => _launchUrl(footer.googleMapLink),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Color(0xFFdc1212),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "View Map Location",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Follow us",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18),
              ),
            ),
            SizedBox(height: 10,),
            if (footer.facebookPageLink != null || footer.youttubeChannelLink != null)
              Row(
                children: [
                  SizedBox(width: 10,),
                  if (footer.facebookPageLink != null)
                    GestureDetector(
                      child: Image.asset("assets/images/facebook.png",height: 20,width: 20,),
                      onTap: () => _launchUrl(footer.facebookPageLink),
                    ),
                  SizedBox(width: 10,),
                  if (footer.youttubeChannelLink != null)
                    GestureDetector(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset("assets/images/youtube.png",height: 30,width: 30,)),
                      onTap: () => _launchUrl(footer.youttubeChannelLink),
                    ),
                  SizedBox(width: 10,),
                    GestureDetector(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                          child: Image.asset("assets/images/whatsapp.png",height: 30,width: 25,)),
                      onTap: () {
                        _openWhatsApp();
                      },
                    ),
                ],
              ),
            const SizedBox(height: 11),
            CreationEdgePage(),
            const SizedBox(height: 16),
            if (footer.copyrightText != null)
              Center(
                child: HtmlWidget(
                  footer.copyrightText!,
                  textStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            GestureDetector(
              onTap: () async {
                await NativeMessengerLauncher.clickhere(Uri.parse("https://bigbagsoftware.com/"));

                // launchUrl(Uri.parse("https://bigbagsoftware.com/"));
              },
              child: const Center(
                child: Text(
                  'Developed by Bigbag Software Ltd.',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickLinks() {
    final links = [
      {'text': 'About Us', 'screen': const AboutUs()},
      {'text': 'Contact Us', 'screen': ContactUsScreen()},
      {'text': 'Privacy Policy', 'screen': const PrivacyPolicyScreen()},
      {'text': 'How to Order', 'screen': const HowToOrder()},
      {'text': 'Return Policy', 'screen': const ReturnRefund()},
      {'text': 'Shipping Policy', 'screen': const ShippingPolicy()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: links.map((link) {
        final text = link['text'] as String;
        final screen = link['screen'] as Widget;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screen),
              );
            },
            child: Text(
              text,
              style: const TextStyle(color: Colors.black,),
            ),
          ),
        );
      }).toList(),
    );
  }

}

class CreationEdgePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Adjust width based on your requirements
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 1,

          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/cover.jpg", // Add your background image
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile image and name row
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 2),
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: AssetImage("assets/images/logo.jpeg"), // Add your profile image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Girls Paradise",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "997,861 followers",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Background text (Girls Paradise)
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Girls Paradise",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Buttons row
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await NativeMessengerLauncher.clickhere(Uri.parse("https://www.facebook.com/plugins/error/confirm/page?iframe_referer=https%3A%2F%2Fcreationedge.com.bd%2F&kid_directed_site=false&secure=true&plugin=page&return_params=%7B%22href%22%3A%22https%3A%2F%2Fwww.facebook.com%2Fcreationedges%22%2C%22tabs%22%3A%22timeline%22%2C%22width%22%3A%22340%22%2C%22height%22%3A%22100%22%2C%22small_header%22%3A%22false%22%2C%22adapt_container_width%22%3A%22true%22%2C%22hide_cover%22%3A%22false%22%2C%22show_facepile%22%3A%22true%22%2C%22appId%22%3A%22726419731521824%22%2C%22ret%22%3A%22sentry%22%2C%22act%22%3Anull%7D"));
                        // launchUrl(Uri.parse("https://www.facebook.com/plugins/error/confirm/page?iframe_referer=https%3A%2F%2Fcreationedge.com.bd%2F&kid_directed_site=false&secure=true&plugin=page&return_params=%7B%22href%22%3A%22https%3A%2F%2Fwww.facebook.com%2Fcreationedges%22%2C%22tabs%22%3A%22timeline%22%2C%22width%22%3A%22340%22%2C%22height%22%3A%22100%22%2C%22small_header%22%3A%22false%22%2C%22adapt_container_width%22%3A%22true%22%2C%22hide_cover%22%3A%22false%22%2C%22show_facepile%22%3A%22true%22%2C%22appId%22%3A%22726419731521824%22%2C%22ret%22%3A%22sentry%22%2C%22act%22%3Anull%7D"));
                      },
                      icon: const Icon(Icons.facebook),
                      label: const Text("Follow Page"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Share.share('https://www.facebook.com/plugins/error/confirm/page?iframe_referer=https%3A%2F%2Fcreationedge.com.bd%2F&kid_directed_site=false&secure=true&plugin=page&return_params=%7B%22href%22%3A%22https%3A%2F%2Fwww.facebook.com%2Fcreationedges%22%2C%22tabs%22%3A%22timeline%22%2C%22width%22%3A%22340%22%2C%22height%22%3A%22100%22%2C%22small_header%22%3A%22false%22%2C%22adapt_container_width%22%3A%22true%22%2C%22hide_cover%22%3A%22false%22%2C%22show_facepile%22%3A%22true%22%2C%22appId%22%3A%22726419731521824%22%2C%22ret%22%3A%22sentry%22%2C%22act%22%3Anull%7D');

                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}