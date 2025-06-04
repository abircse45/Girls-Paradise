// import 'dart:convert';
// import 'package:creation_edge/screens/shop/product_details.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// import '../../utils/constance.dart';
//
// class ReelModel {
//   final int id;
//   final String shortVideo;
//   final String slug;
//
//   ReelModel({
//     required this.id,
//     required this.shortVideo,
//     required this.slug,
//   });
//
//   factory ReelModel.fromJson(Map<String, dynamic> json) {
//     return ReelModel(
//       id: json['id'],
//       shortVideo: json['short_videos'],
//       slug: json['slug'],
//     );
//   }
//
//   String get cleanVideoId {
//     // Clean up various video ID formats
//     String videoId = shortVideo;
//
//     // Remove any URL parameters
//     if (videoId.contains('?')) {
//       videoId = videoId.split('?')[0];
//     }
//
//     // Remove "v=" prefix if present
//     if (videoId.contains('v=')) {
//       videoId = videoId.split('v=')[1];
//     }
//
//     // Remove any trailing requirements
//     if (videoId.contains(' required=')) {
//       videoId = videoId.split(' required=')[0];
//     }
//
//     return videoId;
//   }
// }
//
// class ReelsScreen extends StatefulWidget {
//   const ReelsScreen({super.key});
//
//   @override
//   State<ReelsScreen> createState() => _ReelsScreenState();
// }
//
// class _ReelsScreenState extends State<ReelsScreen> {
//   final ApiService _apiService = ApiService();
//   Future<void> _launchMessenger(String productUrl) async {
//     // Messenger sharing URL format
//     final String messengerUrl = 'fb-messenger://share?link=$productUrl';
//
//     try {
//       // First try to launch in Facebook Messenger app
//       final messengerUri = Uri.parse(messengerUrl);
//       bool launched = await launchUrl(
//         messengerUri,
//         mode: LaunchMode.externalApplication,
//       );
//
//       // If Messenger app launch fails, try web fallback
//       if (!launched) {
//         final webMessengerUrl =
//             'https://www.messenger.com/share?link=$productUrl';
//         await launchUrl(
//           Uri.parse(webMessengerUrl),
//           mode: LaunchMode.inAppBrowserView,
//         );
//       }
//     } catch (e) {
//       print('Could not launch Messenger: $e');
//       // You might want to show a snackbar or alert to the user here
//     }
//   }
//
// // Usage example:
//   void shareProduct() {
//     final productUrl =
//         "https://girlsparadisebd.com/product/${_reels[_currentIndex].slug}";
//     _launchMessenger(productUrl);
//   }
//
//
//
//   List<ReelModel> _reels = [];
//   List<YoutubePlayerController> _controllers = [];
//   bool _isLoading = true;
//   String? _error;
//   int _currentIndex = 0;
//   bool _isPlaying = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadReels();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     SystemChrome.setPreferredOrientations([]);
//     super.dispose();
//   }
//
//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//       if (_currentIndex < _controllers.length) {
//         if (_isPlaying) {
//           _controllers[_currentIndex].play();
//         } else {
//           _controllers[_currentIndex].pause();
//         }
//       }
//     });
//   }
//
//   Future<void> _loadReels() async {
//     try {
//       final reels = await _apiService.fetchReels();
//       final controllers = reels.map((reel) {
//         return YoutubePlayerController(
//           initialVideoId: reel.cleanVideoId,
//           flags: const YoutubePlayerFlags(
//             autoPlay: false,
//             mute: false,
//             loop: true,
//             enableCaption: false,
//             hideControls: true,
//             forceHD: true,
//           ),
//         );
//       }).toList();
//
//       setState(() {
//         _reels = reels;
//         _controllers = controllers;
//         _isLoading = false;
//       });
//
//       if (controllers.isNotEmpty) {
//         controllers[0].play();
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _onPageChanged(int index) {
//     if (_currentIndex < _controllers.length) {
//       _controllers[_currentIndex].pause();
//     }
//     setState(() {
//       _currentIndex = index;
//       _isPlaying = true; // Reset playing state on page change
//     });
//     _controllers[index].play();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Colors.black,
//         elevation: 3,
//         title: Text(
//           "Reels",
//           style: TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white))
//             : _error != null
//                 ? Center(
//                     child: Text(_error!,
//                         style: const TextStyle(color: Colors.white)))
//                 : Stack(
//                     children: [
//                       PageView.builder(
//                         scrollDirection: Axis.vertical,
//                         onPageChanged: _onPageChanged,
//                         itemCount: _controllers.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: _togglePlayPause,
//                             child: Container(
//                               color: Colors.black,
//                               child: Stack(
//                                 fit: StackFit.expand,
//                                 children: [
//                                   Center(
//                                     child: AspectRatio(
//                                       aspectRatio: 9 / 16,
//                                       child: YoutubePlayer(
//                                         controller: _controllers[index],
//                                         showVideoProgressIndicator: true,
//                                         progressIndicatorColor: Colors.red,
//                                         progressColors: const ProgressBarColors(
//                                           playedColor: Colors.red,
//                                           handleColor: Colors.redAccent,
//                                         ),
//                                         onReady: () {
//                                           if (index == _currentIndex) {
//                                             _controllers[index].play();
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//
//                                   // Play/Pause Icon Overlay
//                                   if (!_isPlaying && index == _currentIndex)
//                                     Center(
//                                       child: Container(
//                                         padding: const EdgeInsets.all(20),
//                                         decoration: BoxDecoration(
//                                           color: Colors.black.withOpacity(0.5),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.play_arrow,
//                                           color: Colors.white,
//                                           size: 50,
//                                         ),
//                                       ),
//                                     ),
//
//                                   // Overlay Controls
//                                   Positioned(
//                                     right: 16,
//                                     bottom: 100,
//                                     child: Column(
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//                                             final currentReel =
//                                                 _reels[_currentIndex];
//                                             Get.to(
//                                                 ProductDetails(
//                                                   id: currentReel.id,
//                                                 ),
//                                                 transition:
//                                                     Transition.noTransition);
//                                             // if (data.buttonLink != null) {
//                                             //   launchUrl(Uri.parse(data.buttonLink!));
//                                             // }
//                                           },
//                                           child: Container(
//                                             padding: EdgeInsets.all(8),
//                                             height: 30,
//                                             alignment: Alignment.center,
//                                             decoration: BoxDecoration(
//                                               color: Colors.indigo,
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             child: const Text(
//                                               "Buy now",
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 20),
//                                         _buildIcoMessenger(
//                                             "assets/images/messenger.png",
//                                             'Messenger'),
//                                         const SizedBox(height: 16),
//                                         _buildIconButton(
//                                             Icons.share_outlined, 'Share'),
//                                       ],
//                                     ),
//                                   ),
//
//                                   // Video Info Overlay
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       // Top Navigation Bar
//                     ],
//                   ),
//       ),
//     );
//   }
//
//   Widget _buildIconButton(IconData icon, String label) {
//     return Column(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.4),
//             shape: BoxShape.circle,
//           ),
//           child: IconButton(
//             icon: Icon(icon, color: Colors.white),
//             onPressed: () {
//               Share.share('https://girlsparadisebd.com/');
//             },
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildIcoMessenger(String path, String label) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             shareProduct();
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.4),
//               shape: BoxShape.circle,
//             ),
//             child: Image.asset(
//               "$path",
//               height: 25,
//               width: 25,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // api_service.dart
// class ApiService {
//   Future<List<ReelModel>> fetchReels() async {
//     try {
//       final response = await http.get(Uri.parse('${baseUrl}reels'));
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true && jsonData['data'] != null) {
//           return (jsonData['data'] as List)
//               .map((reel) => ReelModel.fromJson(reel))
//               .toList();
//         }
//       }
//       throw Exception('Failed to load reels');
//     } catch (e) {
//       throw Exception('Error fetching reels: $e');
//     }
//   }
// }

import 'dart:convert';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../NativeServices/native_messenger_launcher.dart';
import '../../utils/constance.dart';

class ReelModel {
  int? id;
  String? name;
  String? slug;
  String? shortVideos;

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

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ApiService _apiService = ApiService();

  void shareProduct() async {
    var message =
        'https://girlsparadisebd.com/product/${_reels[_currentIndex].slug}'; // Replace with your message
    final url = 'https://m.me/creationedges?text=${Uri.encodeFull(message)}';
    await NativeMessengerLauncher.clickhere(Uri.parse("$url"));

    // await launchUrl(Uri.parse(url));
  }


  List<ReelModel> _reels = [];
  List<YoutubePlayerController> _controllers = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _loadReels();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
    try {
      final reels = await _apiService.fetchReels();
      final controllers = reels.map((reel) {
        return YoutubePlayerController(
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
      }).toList();

      setState(() {
        _reels = reels;
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
    _controllers[index].play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:  SafeArea(
        child: Container(
          child: _isLoading
              ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
              : _error != null
              ? Center(
              child: Text(_error!,
                  style: const TextStyle(color: Colors.white)))
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
                          Center(
                            child: SizedBox(
                              height:  MediaQuery.of(context).size.height,
                              width:MediaQuery.of(context).size.height,
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
                              ),
                            ),
                          ),
        
                          // Play/Pause Icon Overlay
                          if (!_isPlaying && index == _currentIndex)
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
                                    final currentReel =
                                    _reels[_currentIndex];
                                    Get.to(
                                        ProductDetails(
                                          id: currentReel.id,
                                        ),
                                        transition:
                                        Transition.noTransition);
                                    // if (data.buttonLink != null) {
                                    //   launchUrl(Uri.parse(data.buttonLink!));
                                    // }
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(8),
                                      // height: 30,
                                      alignment: Alignment.center,
                                      decoration:  BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle
                                      ),
                                      child: Icon(Icons.shopping_cart_outlined,color: Colors.white,
                                      )
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildIcoMessenger(
                                    "assets/images/messenger.png"),
                                const SizedBox(height: 16),
                                _buildIconButton(
                                    Icons.share_outlined, '${_reels[_currentIndex].slug}'),
                              ],
                            ),
                          ),
        
                          // Video Info Overlay
                        ],
                      ),
                    ),
                  );
                },
              ),
        
              // Top Navigation Bar
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 3,
        title: Text(
          "Reels",
          style: TextStyle(fontSize: 16, color: Colors.white),
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
          child:  GestureDetector(
              onTap: (){
                Share.share('https://girlsparadisebd.com/product/${label}');
              },
              child: Icon(icon, color: Colors.white,size: 20,)),


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
