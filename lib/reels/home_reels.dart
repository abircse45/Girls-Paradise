import 'dart:convert';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../utils/constance.dart';
import '../NativeServices/native_messenger_launcher.dart';

class ReelModel {
  int? id;
  String? name;
  String? slug;
  String? shortVideos;
  bool hasError = false;

  ReelModel({
    required this.id,
    required this.shortVideos,
    required this.slug,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'],
      shortVideos: json['short_videos']?.toString() ?? '',
      slug: json['slug'],
    );
  }

  String get cleanVideoId {
    String videoId = shortVideos ?? '';

    // Remove URL parameters
    if (videoId.contains('?')) {
      videoId = videoId.split('?')[0];
    }

    // Remove 'v=' prefix
    if (videoId.contains('v=')) {
      videoId = videoId.split('v=')[1];
    }

    // Remove 'required=' suffix
    if (videoId.contains(' required=')) {
      videoId = videoId.split(' required=')[0];
    }

    // Remove any invalid or non-standard characters
    videoId = videoId.trim();

    // Ensure it's an 11-character YouTube video ID
    return videoId.length == 11 ? videoId : '';
  }
}

class HomeReels extends StatefulWidget {
  const HomeReels({super.key});

  @override
  State<HomeReels> createState() => _HomeReelsState();
}

class _HomeReelsState extends State<HomeReels> {
  final ApiService _apiService = ApiService();

  void shareProduct() async {
    var message = 'https://girlsparadisebd.com/product/${_reels[_currentIndex].slug}';
    final url = 'https://m.me/creationedges?text=${Uri.encodeFull(message)}';
    await NativeMessengerLauncher.launchMessenger(url: url);
  }
  List<ReelModel> _reels = [];
  List<YoutubePlayerController> _controllers = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  bool _isPlaying = true;
  List<bool> _videoErrors = [];

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_currentIndex < _controllers.length) {
        if (_isPlaying) {
          _controllers[_currentIndex].play();
        } else {
          _controllers[_currentIndex].pause();
        }
      }
    });
  }

  Future<void> _loadReels() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reels = await _apiService.fetchReels();

      // Filter out reels with invalid video IDs
      final validReels = reels.where((reel) => reel.cleanVideoId.isNotEmpty).toList();

      if (validReels.isEmpty) {
        setState(() {
          _error = "No valid videos found";
          _isLoading = false;
        });
        return;
      }

      // Initialize error tracking for each video
      _videoErrors = List.generate(validReels.length, (_) => false);

      final controllers = validReels.map((reel) {
        final controller = YoutubePlayerController(
          initialVideoId: reel.cleanVideoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            loop: true,
            enableCaption: false,
            hideControls: true,
            forceHD: true,
          ),
        );

        // Add error listener
        controller.addListener(() {
          if (controller.value.errorCode != 0 && controller.value.isReady) {
            final index = _controllers.indexOf(controller);
            if (index != -1 && index < _videoErrors.length && !_videoErrors[index]) {
              setState(() {
                _videoErrors[index] = true;
              });
            }
          }
        });

        return controller;
      }).toList();

      setState(() {
        _reels = validReels;
        _controllers = controllers;
        _isLoading = false;
      });

      if (controllers.isNotEmpty) {
        controllers[0].play();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex < _controllers.length) {
      _controllers[_currentIndex].pause();
    }
    setState(() {
      _currentIndex = index;
      _isPlaying = true; // Reset playing state on page change
    });
    if (!_videoErrors[index]) {
      _controllers[index].play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadReels();
      },
      child: Container(
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Colors.white))
            : _error != null
            ? Center(
            child: Text(_error!,
                style: const TextStyle(color: Colors.black)))
            : Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video or error placeholder
                        _videoErrors[index]
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.white, size: 48),
                              SizedBox(height: 16),
                              Text(
                                "Video unavailable",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                            : Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.height,
                            child: YoutubePlayer(
                              controller: _controllers[index],
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.red,
                              progressColors: const ProgressBarColors(
                                playedColor: Colors.red,
                                handleColor: Colors.redAccent,
                              ),
                              onReady: () {
                                if (index == _currentIndex) {
                                  _controllers[index].play();
                                }
                              },
                              onEnded: (_) {
                                // Loop the video manually
                                _controllers[index].seekTo(const Duration(seconds: 0));
                                _controllers[index].play();
                              },
                            ),
                          ),
                        ),

                        // Play/Pause Icon Overlay
                        if (!_isPlaying && index == _currentIndex && !_videoErrors[index])
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),

                        // Overlay Controls
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final currentReel = _reels[_currentIndex];
                                  Get.to(
                                      ProductDetails(
                                        id: currentReel.id,
                                      ),
                                      transition: Transition.noTransition);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle
                                    ),
                                    child: Icon(Icons.shopping_cart_outlined, color: Colors.white)
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildIcoMessenger("assets/images/messenger.png"),
                              const SizedBox(height: 16),
                              _buildIconButton(
                                  Icons.share_outlined, '${_reels[_currentIndex].slug}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () {
              Share.share('https://girlsparadisebd.com/product/${label}');
            },
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildIcoMessenger(String path) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            shareProduct();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              "$path",
              height: 30,
              width: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

// api_service.dart
class ApiService {
  Future<List<ReelModel>> fetchReels() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}reels'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((reel) => ReelModel.fromJson(reel))
              .toList();
        }
      }
      throw Exception('Failed to load reels');
    } catch (e) {
      throw Exception('Error fetching reels: $e');
    }
  }
}