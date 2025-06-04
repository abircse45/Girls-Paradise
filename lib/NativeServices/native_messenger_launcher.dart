import 'package:flutter/services.dart';

class NativeMessengerLauncher {
  static const MethodChannel _channel =
  MethodChannel('com.girlsparadise.shoppingapp/messenger');

  static Future<bool> launchMessenger({String url = 'https://m.me/creationedges'}) async {
    try {
      final bool result = await _channel.invokeMethod(
        'launchMessenger',
        {'url': url},
      );
      return result;
    } on PlatformException catch (e) {
      print("Failed to launch messenger: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> clickhere(Uri uri) async {
    try {
      final bool result = await _channel.invokeMethod(
        'openUrl',
        {'url': uri.toString()},
      );
      return result;
    } on PlatformException catch (e) {
      print("Failed to open URL: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> openWhatsApp({
    String phoneNumber = '+8801872650280',
    String message = ''
  }) async {
    try {
      String url = 'https://wa.me/$phoneNumber';

      // Add message if provided
      if (message.isNotEmpty) {
        url += '?text=${Uri.encodeFull(message)}';
      }

      final bool result = await _channel.invokeMethod(
        'openWhatsApp',
        {'url': url},
      );
      return result;
    } on PlatformException catch (e) {
      print("Failed to open WhatsApp: '${e.message}'.");
      return false;
    }
  }
}