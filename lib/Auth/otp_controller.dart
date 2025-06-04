import 'package:get/get.dart';

class OtpController extends GetxController {
  var code = ''.obs;

  void updateCode(String newCode) {
    code.value = newCode;
  }
}
