import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../notifications/NotificationSingleVideo.dart';
import '../notifications/SingleBlog_screen.dart';
import '../screens/shop/product_details.dart'; // Assuming you're using GetX for navigation

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes Firebase Messaging and Notification settings.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    // Request notification permissions (for iOS)
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = jsonEncode(message.data);
      _handleNotificationTap(payload);
    });

    // Handle notification tap when app is launched from terminated state
    final launchDetails = await _firebaseMessaging.getInitialMessage();
    if (launchDetails != null) {
      final payload = jsonEncode(launchDetails.data);
      _handleNotificationTap(payload);
    }
  }

  /// Displays a local notification with an image (if available).
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final Map<String, dynamic> data = message.data;
    final String? imageUrl = data['data_image'];

    String? localImagePath;
    if (imageUrl != null) {
      localImagePath = await _downloadAndSaveImage(imageUrl);
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: localImagePath != null
          ? BigPictureStyleInformation(
        FilePathAndroidBitmap(localImagePath), // Big picture
        largeIcon: FilePathAndroidBitmap(localImagePath), // Large icon
        hideExpandedLargeIcon: false, // Show large icon in expanded view
        contentTitle: message.notification?.title, // Title in expanded view
        summaryText: message.notification?.body, // Summary text in expanded view
      )
          : null,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      attachments: localImagePath != null
          ? [DarwinNotificationAttachment(localImagePath)]
          : null,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      message.notification?.hashCode ?? 0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(data), // Pass the entire data as payload
    );

    // Print the message response
    debugPrint('Message received: ${message.notification?.title}');
    debugPrint('Message body: ${message.notification?.body}');
    debugPrint('Message data: $data');
    if (imageUrl != null) {
      debugPrint('Image URL: $imageUrl');
    }
  }
  /// Downloads and saves an image from a URL to a local file.
  Future<String?> _downloadAndSaveImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/notification_image.jpg');
        file.writeAsBytesSync(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
    return null;
  }

  /// Handles notification tap and routes to the appropriate screen.
  void _handleNotificationTap(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String? notificationType = data['notification_type'];
      final String? dataId = data['data_id'];

      if (notificationType == "video") {
        Get.to(
          Notificationsinglevideo(id: dataId),
          transition: Transition.noTransition,
        );
      } else if (notificationType == "blog") {
        Get.to(
          SingleFacebookNewsFeed(id: dataId!),
          transition: Transition.noTransition,
        );
      } else if (notificationType == "product") {
        Get.to(
          ProductDetails(id: int.parse(dataId!)),
          transition: Transition.noTransition,
        );
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Retrieves the Firebase Cloud Messaging (FCM) token.
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error retrieving FCM token: $e');
      return null;
    }
  }

  /// Subscribes to a specific topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribes from a specific topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
}