import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Social/social_link_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../NativeServices/native_messenger_launcher.dart';
class MyDrawer extends StatelessWidget {
  final SocialLinksController controller = Get.find<SocialLinksController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.socialLinks.isEmpty) {
          return const Center(child: Text('No Social Links Available'));
        }
        return ListView(
          children: [

            ...controller.socialLinks.map((link) {
              return ListTile(
                leading: CachedNetworkImage(
                 imageUrl:  link.iconImage,
                  height: 25,
                  width: 25,
                  errorWidget: (context, error, stackTrace) => Icon(Icons.link),
                ),
                title: Text(link.name),
                onTap: () async {
                  await NativeMessengerLauncher.clickhere(Uri.parse(link.link));
                  //
                  // final Uri uri = Uri.parse(link.link);
                  // await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}
