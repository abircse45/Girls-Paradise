// import 'package:creation_edge/screens/home/home_screens.dart';
// import 'package:flutter/material.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
//
// class SplashScreens extends StatefulWidget {
//   const SplashScreens({super.key});
//   @override
//   State<SplashScreens> createState() => _SplashScreensState();
// }
//
// class _SplashScreensState extends State<SplashScreens> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreens()),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10.0),
//               child: Image.asset(
//                 "assets/images/logo_main.png",
//                 height: 250,
//                 // width: 150,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             const SizedBox(height: 50),
//             LoadingAnimationWidget.progressiveDots(color: Colors.red, size: 30),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
