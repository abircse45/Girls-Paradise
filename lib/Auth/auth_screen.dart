import 'dart:developer';

import 'package:creation_edge/screens/home/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/constance.dart';
import '../utils/local_store.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool isLoadingGoogle = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email'],serverClientId:  "");
  bool checkbox = false;

  Future<void> _handleSignIn() async {
    setState(() {
      isLoadingGoogle = true;
    });
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      String? token;
      if (account != null) {
        // User signed in successfully, you can access the email here
        String userEmail = account.email;

        account.authentication.then((value) async {
          token = value.accessToken.toString();

          print("Id  ${account.id}");
          print("Name  ${account.displayName}");
          print("Photo  ${account.photoUrl}");
          print("AccessToken  ${value.accessToken}");
          print("idToken  ${value.idToken}");

          final Uri url =
          Uri.parse('https://girlsparadisebd.com/api/v1/auth/google_login_token');

          // Send request to backend
          final response = await http.post(
            url,
            body: {
              "access_token" : '$token'
            },
          );

          if(response.statusCode==200) {
            final Map<String, dynamic> jsonResponse = json.decode(
                response.body);
            final String? authToken = jsonResponse['token'];
            if (authToken != null) {
              await setAccessToken(authToken.toString());
              await initiateAccessToken();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Login successful!')),
              );
              Get.offAll(const HomeScreens(),
                  transition: Transition.noTransition);
              isLoadingGoogle = false;

            }
          }else{
            setState(() {
              isLoadingGoogle = false;
            });
          }

        });
        print('Signed in user email: $userEmail');

        // You can perform further actions based on the user's email
      } else {
        // User cancelled the sign-in process
        print('Sign-in cancelled by user');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }



  Future<void> sendOtp() async {
    final String phoneNumber = phoneController.text;
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://girlsparadisebd.com/api/v1/mobile_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: phoneNumber),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor:  Color(0xFFdc1212),
        surfaceTintColor:  Color(0xFFdc1212),
        elevation: 0,
        title: Text(
          "Login",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/appbarlogo.png', // Replace with your logo path
              height: 60,
            ),
            const SizedBox(height: 30),
            const Text(
              'Sign in with your phone number or you may sign in to your Google Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Please enter your number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ?  Center(
                    child: LoadingAnimationWidget.progressiveDots(color: Colors.red, size: 30),
                  )
                : ElevatedButton(
                    onPressed: sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:             Color(0xFFdc1212),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Send OTP',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            isLoadingGoogle
                ?  Center(
              child: LoadingAnimationWidget.progressiveDots(color: Colors.red, size: 30),
            )
                :  GestureDetector(
              onTap: (){
                _handleSignIn();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:   Color(0xFFdc1212),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/google.png",
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Continue With Google",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
