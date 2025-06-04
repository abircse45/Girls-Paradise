import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../blog/blog_controller.dart';
import '../popular/grid_popular_product.dart';
import '../popular/popular_product_details.dart';
import '../popular/popular_products.dart';
import '../youtube/youtube_media.dart';

String getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else {
    int months = (now.year - dateTime.year) * 12 + now.month - dateTime.month;

    if (months < 12) {
      return '${months} ${months == 1 ? 'month' : 'months'} ago';
    } else {
      int years = months ~/ 12;
      return '${years} ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

class FacebookNewsFeedScreen extends StatefulWidget {
  const FacebookNewsFeedScreen({super.key});

  @override
  State<FacebookNewsFeedScreen> createState() => _FacebookNewsFeedScreenState();
}

class _FacebookNewsFeedScreenState extends State<FacebookNewsFeedScreen> {
  final BlogController blogController = Get.put(BlogController());
  final Map<String, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  Future<void> _initializeControllers() async {
    if (blogController.products?.data != null) {
      for (var data in blogController.products!.data!) {
        if (data.mediaType == 'video' && data.mediaLink != null) {
          final videoUrl = data.mediaLink!;
          if (!_controllers.containsKey(videoUrl)) {
            final controller = YoutubePlayerController.fromVideoId(
              videoId: videoUrl,
              autoPlay: false,
              params: const YoutubePlayerParams(
                showFullscreenButton: true,
                mute: false,
                showControls: true,
              ),
            );
            _controllers[videoUrl] = controller;
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    super.dispose();
  }

  Widget _buildYoutubePlayer(String videoUrl) {
    final controller = _controllers[videoUrl];
    if (controller == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 9 / 16, // 16:9 aspect ratio
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: YoutubePlayer(
              enableFullScreenOnVerticalDrag: false,
              key: ValueKey(videoUrl), // Stable key for widget rebuilds
              controller: controller,
              aspectRatio: 16 / 9,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (blogController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: blogController.products?.data?.length ?? 0,
        itemBuilder: (context, index) {
          var data = blogController.products?.data?[index];
          if (data == null) return const SizedBox.shrink();

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
                          imageUrl: "${ImagebaseUrl}${data.mediaLink}",
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
                                  data.entryBy?.name ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  getRelativeTime(data.createdAt!),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   data.title ?? '',
                            //   maxLines: 3,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(fontWeight: FontWeight.normal),
                            // ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data.description ?? ''),
                  const SizedBox(height: 8),
                  if (data.mediaType == 'video')
                    _buildYoutubePlayer(data.mediaLink!)
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage("${ImagebaseUrl}${data.mediaLink}"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       Text(
                        "${data.title}",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(PopularProductDetails(id: data.id),
                              transition: Transition.noTransition);
                        //  Get.to(GridPopularProduct(),transition: Transition.noTransition);
                           print("buy now --${data.id}");
                          // if (data.buttonLink != null) {
                          //   launchUrl(Uri.parse(data.buttonLink!));
                          // }
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
      );
    });
  }
}
