import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FacebookVideoPlayer extends StatelessWidget {
  final String facebookVideoId;

  const FacebookVideoPlayer({super.key, required this.facebookVideoId});

  @override
  Widget build(BuildContext context) {
    String embedUrl =
        'https://www.facebook.com/plugins/video.php?href=https://www.facebook.com/watch/?v=$facebookVideoId&show_text=false&width=734';

    return SizedBox(
    height: 700,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
      ),
    );
  }
}
