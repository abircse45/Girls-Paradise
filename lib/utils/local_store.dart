import 'package:shared_preferences/shared_preferences.dart';
import 'constance.dart';

setAccessToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("access_token", token);
  accessToken = token;
}
getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("access_token");
  return token ?? "";
}


clearAll() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('access_token');

  prefs.clear();
}



setRememberMe(bool remember) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("rememberMe", remember);
}

Future getRememberMe() async {
  final prefs = await SharedPreferences.getInstance();
  bool? rem = prefs.getBool("rememberMe");
  return rem ?? false;
}

setUserTypeIdLocal(int userType) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt("userType", userType);
}

Future getUserTypeIdLocal() async {
  final prefs = await SharedPreferences.getInstance();
  int? userType = prefs.getInt("userType");
  return userType ?? 0;
}

setUserId(int? userId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt("userId", userId!);
}

Future getUserID() async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("userId");
  return userId ?? 0;
}

void storeFcmToken(String token) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('fcm', token);
}

Future<String> getFcmToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('fcm') ?? "";
}

setUserLoginType(String? userLoginType) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("userLoginType", userLoginType!);
}

Future getUserLoginType() async {
  final prefs = await SharedPreferences.getInstance();
  String? userLoginType = prefs.getString("userLoginType");
  return userLoginType ?? 0;
}

setUserLoginId(String? userLoginId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("userLoginId", userLoginId!);
}

Future getUserLoginId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userLoginId = prefs.getString("userLoginId");
  return userLoginId ?? 0;
}

setUserLoginPass(String? userLoginPass) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("userLoginPass", userLoginPass!);
}

Future getUserLoginPass() async {
  final prefs = await SharedPreferences.getInstance();
  String? userLoginPass = prefs.getString("userLoginPass");
  return userLoginPass ?? 0;
}
