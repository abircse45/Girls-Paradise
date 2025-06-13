import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Notificationsinglevideo extends StatefulWidget {
  final String? id; // Accept video ID as a parameter
  const Notificationsinglevideo({super.key, this.id});

  @override
  State<Notificationsinglevideo> createState() =>
      _NotificationsinglevideoState();
}

class _NotificationsinglevideoState extends State<Notificationsinglevideo> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  String? _videoTitle;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    fetchVideoDetails();
  }

  Future<void> fetchVideoDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/video/${widget.id}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final videoData = data['data'];
          final link = videoData['link'];

          final extractedId = _extractVideoId(link);
          if (extractedId == null) throw Exception('Invalid YouTube link');

          _controller = YoutubePlayerController(
            initialVideoId: extractedId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: true,
            ),
          );

          setState(() {
            _videoTitle = videoData['name'];
            _videoId = extractedId;
            _isLoading = false;
          });
        } else {
          throw Exception('Video data not found');
        }
      } else {
        throw Exception('Video data not found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String? _extractVideoId(String link) {
    return YoutubePlayer.convertUrlToId(link);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_videoTitle ?? 'Loading...'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          '$_error',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : _controller != null
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.redAccent,
                aspectRatio: 16 / 9,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      )
          : const Center(
        child: Text('Could not load video.'),
      ),
    );
  }
}
