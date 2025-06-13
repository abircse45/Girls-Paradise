import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../NativeServices/native_messenger_launcher.dart';

class SingleFacebookNewsFeed extends StatefulWidget {
  final String id;

  const SingleFacebookNewsFeed({super.key, required this.id});

  @override
  State<SingleFacebookNewsFeed> createState() => _SingleFacebookNewsFeedState();
}

class _SingleFacebookNewsFeedState extends State<SingleFacebookNewsFeed> {
  final ApiService _apiService = ApiService();
  late Future<BlogPost> _blogPostFuture;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _blogPostFuture = _apiService.fetchBlogPost(widget.id);
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer(String link) {
    final videoId = YoutubePlayer.convertUrlToId(link);
    if (videoId == null) {
      return const Text("Invalid YouTube link");
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );

    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      aspectRatio: 16 / 9,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Blog'),
      ),
      body: FutureBuilder<BlogPost>(
        future: _blogPostFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final blogPost = snapshot.data!;
          return Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: CachedNetworkImage(
                          imageUrl: "${ImagebaseUrl}${blogPost.mediaLink}",
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          errorWidget: (context, _, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.asset(
                              "assets/images/logo.jpeg",
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  blogPost.authorName ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${blogPost.createdAt}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(blogPost.description ?? ''),
                  const SizedBox(height: 8),
                  if (blogPost.mediaType == 'video')
                    _buildVideoPlayer(blogPost.mediaLink!)
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage("${ImagebaseUrl}${blogPost.mediaLink}"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "${blogPost.title ?? ""}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (blogPost.buttonLink != null) {
                            await NativeMessengerLauncher.clickhere(
                                Uri.parse(blogPost.buttonLink!));
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Buy now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ApiService {
  Future<BlogPost> fetchBlogPost(String id) async {
    final url = "https://girlsparadisebd.com/api/v1/blog/$id";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return BlogPost.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to load blog post');
        }
      } else {
        throw Exception('Failed to load blog post');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class BlogPost {
  final int id;
  final String title;
  final String description;
  final String? mediaType;
  final String? mediaLink;
  final String? buttonLink;
  final String createdAt;
  final String? authorName;
  final String? categoryName;

  BlogPost({
    required this.id,
    required this.title,
    required this.description,
    this.mediaType,
    this.mediaLink,
    this.buttonLink,
    required this.createdAt,
    this.authorName,
    this.categoryName,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mediaType: json['media_type'],
      mediaLink: json['media_link'],
      buttonLink: json['button_link'],
      createdAt: json['created_at'],
      authorName: json['entry_by']?['name'],
      categoryName: json['category']?['name'],
    );
  }
}
