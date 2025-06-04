import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:creation_edge/screens/home/bottomNavbbar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../utils/constance.dart';

class VideoModel {
  final int id;
  final String name;
  final String link;
  final dynamic status;

  VideoModel({
    required this.id,
    required this.name,
    required this.link,
    required this.status,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      name: json['name'],
      link: json['link'],
      status: json['status'],
    );
  }

  String get videoId {
    final uri = Uri.parse(link);
    final queryParams = uri.queryParameters;
    if (uri.pathSegments.contains('embed')) {
      return uri.pathSegments.last;
    } else if (queryParams.containsKey('v')) {
      return queryParams['v']!;
    } else if (uri.pathSegments.length > 1) {
      return uri.pathSegments.last;
    }
    throw Exception('Could not extract video ID from: $link');
  }
}

class ApiService {
  Future<List<VideoModel>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}videos'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((video) => VideoModel.fromJson(video))
              .toList();
        }
      }
      throw Exception('Failed to load videos');
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}


class YoutubeScreens extends StatefulWidget {
  const YoutubeScreens({super.key});

  @override
  State<YoutubeScreens> createState() => _YoutubeScreensState();
}

class _YoutubeScreensState extends State<YoutubeScreens> {
  final ApiService _apiService = ApiService();
  List<VideoModel> _videos = [];
  List<YoutubePlayerController> _controllers = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final videos = await _apiService.fetchVideos();
      for (var controller in _controllers) {
        controller.close();
      }
      final controllers = videos.map((video) {
        return YoutubePlayerController.fromVideoId(
          videoId: video.videoId,
        );
      }).toList();

      setState(() {
        _videos = videos;
        _controllers = controllers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildVideoPlayer(VideoModel video, YoutubePlayerController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: YoutubePlayer(
        enableFullScreenOnVerticalDrag: false,
        aspectRatio: 16/9,
        controller: controller,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.close();
    }
    _scrollController.dispose();
    super.dispose();
  }
  Widget buildProductGridShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: 10, // Number of shimmer rows
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 180,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ?  buildProductGridShimmer()
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadVideos,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8,bottom: 8,top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_videos.isEmpty)
                      const Center(
                        child: Text('No videos available'),
                      )
                    else
                      ...List.generate(
                        _videos.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildVideoPlayer(
                            _videos[index],
                            _controllers[index],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const BottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
