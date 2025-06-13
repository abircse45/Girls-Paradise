import 'package:url_launcher/url_launcher.dart';

class NativeMessengerLauncher {
  static Future<bool> launchMessenger({String url = 'https://m.me/creationedges'}) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print("Failed to launch messenger: $e");
      return false;
    }
  }

  static Future<bool> clickhere(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print("Failed to open URL: $e");
      return false;
    }
  }

  static Future<bool> openWhatsApp({
    String phoneNumber = '+8801872650280',
    String message = ''
  }) async {
    try {
      String url = 'https://wa.me/$phoneNumber';
      if (message.isNotEmpty) {
        url += '?text=${Uri.encodeFull(message)}';
      }

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print("Failed to open WhatsApp: $e");
      return false;
    }
  }
}
