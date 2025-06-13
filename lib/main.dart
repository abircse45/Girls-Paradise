import 'dart:async';
import 'dart:developer';
import 'package:creation_edge/screens/home/home_screens.dart';
import 'package:creation_edge/screens/splash/splash_screens.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'messaging/firebase_messaging.dart';
import 'notifications/pushNotifyAppbarScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initiateAccessToken();
  await Firebase.initializeApp();
  final fcmService = FirebaseMessagingService();
  await fcmService.initialize(navigatorKey); // Pass navigatorKey to the service
  await fcmService.subscribeToTopic("all_devices");
  log(accessToken);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Girls Paradise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey, // Assign the global navigator key
      initialRoute: '/',
      routes: {
        '/': (context) => accessToken.isEmpty
            ? const SplashScreens()
            : const HomeScreens(),
        '/notification': (context) => const Pushnotifyappbarscreen(), // Replace with your notification screen
      },
    );
  }
}


