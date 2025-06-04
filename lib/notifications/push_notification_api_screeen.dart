import 'dart:convert'; // For JSON decoding
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'NotificationSingleVideo.dart';
import 'SingleBlog_screen.dart';

class PushNotificationApiScreen extends StatefulWidget {
  const PushNotificationApiScreen({super.key});

  @override
  State<PushNotificationApiScreen> createState() =>
      _PushNotificationApiScreenState();
}

class _PushNotificationApiScreenState extends State<PushNotificationApiScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading= true;
    });
    final url =
        Uri.parse('https://girlsparadisebd.com/api/v1/push_notifications');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data['data']['push_notifications'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle non-200 response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? buildProductGridShimmer()
          : notifications.isEmpty
              ? const Center(child: Text('No notifications found.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await fetchNotifications();
                  },
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          surfaceTintColor: Colors.white,
                          margin: const EdgeInsets.all(5.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage("assets/images/logo1.png"),
                            ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification['title'] ?? 'No Title',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  notification['data_date'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              notification['body'] ?? 'No Body',
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              if (notification["notification_type"] ==
                                  "video") {
                                Get.to(
                                    Notificationsinglevideo(
                                      id: notification["data_id"].toString(),
                                    ),
                                    transition: Transition.noTransition);
                                print("id${notification["data_id"]}");
                              } else if (notification["notification_type"] ==
                                  "blog") {
                                Get.to(
                                    SingleFacebookNewsFeed(
                                      id: notification["data_id"],
                                    ),
                                    transition: Transition.noTransition);
                              } else if (notification["notification_type"] ==
                                  "product") {
                                Get.to(
                                    ProductDetails(
                                      id: (notification["data_id"]),
                                    ),
                                    transition: Transition.noTransition);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
  Widget buildProductGridShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: 10, // Number of shimmer rows
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 80,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
