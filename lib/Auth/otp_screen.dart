import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../footer/controller.dart';
import '../utils/constance.dart';
import '../utils/local_store.dart';
import 'package:creation_edge/screens/home/home_screens.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  String? _code;
  final String apiUrl = "https://girlsparadisebd.com/api/v1/verify_otp";
  bool _isLoading = false;
  Timer? _timer;
  int _remainingTime = 180; // 3 minutes in seconds
  late final String signature;

  final FooterController footerController = Get.put(FooterController());

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
    startTimer();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _timer?.cancel();
    cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_remainingTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  String formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _listenForSmsCode() async {
    signature = await SmsAutoFill().getAppSignature;
    print("App Signature: $signature");
    SmsAutoFill().listenForCode();
  }

  @override
  void codeUpdated() {
    // Avoid calling `setState()` here directly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _code = code;
      });
    });
  }

  Future<void> _submitOtp() async {
    if (_code == null || _code!.isEmpty) {
      Get.snackbar("Error", "Please enter OTP",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    if (_code!.length != 4) {
      Get.snackbar("Error", "Please enter a valid 4-digit OTP",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': widget.phoneNumber, 'otp_number': _code}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final String? token = jsonResponse['token'];

        await setAccessToken(token.toString());
        await initiateAccessToken();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verification successful!')),
          );
        }
        await footerController.fetchFooterSettings();
        Get.offAll(() => const HomeScreens(), transition: Transition.noTransition);
      } else {
        Get.snackbar("Error", "Failed to verify OTP",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (error) {
      Get.snackbar("Error", "Something went wrong. Please try again later.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFFdc1212),
        title: const Text(
          "Verify OTP",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/appbarlogo.png',
                    height: 120,
                    width: 200,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your OTP will expire at: ${DateFormat('hh:mm a').format(DateTime.now().add(Duration(seconds: _remainingTime)))}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                formatTime(_remainingTime),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Login with your OTP Number",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PinFieldAutoFill(


                  currentCode: _code,
                  onCodeChanged: (code) {
                    _code = code;
                  },
                  codeLength: 4,
                  autoFocus: false,
                  decoration: UnderlineDecoration(
                    lineHeight: 2,
                    lineStrokeCap: StrokeCap.round,
                    bgColorBuilder: PinListenColorBuilder(

                        Colors.grey, Colors.grey),
                    colorBuilder: const FixedColorBuilder(Colors.transparent,),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ?      Center(child: LoadingAnimationWidget.progressiveDots(color: Color(0xFFdc1212), size: 30),)
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFdc1212),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: _remainingTime > 0 ? _submitOtp : null,
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
