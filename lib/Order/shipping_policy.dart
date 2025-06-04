import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Cart/cart_controller.dart';
import '../../Cart/cart_screen.dart';
import '../../Profile/controller/profile_controller.dart';
import '../../WishList/wishList_screen.dart';
import '../../search/search_screen.dart';
import '../NativeServices/native_messenger_launcher.dart';
import '../screens/Arraival/controller.dart';
import '../screens/Trending/controller.dart';
import '../screens/bestsale/controller.dart';
import '../screens/blog/blog_controller.dart';
import '../screens/shop/controller/product_controller.dart';
// Model classes
class AboutUsModel {
  final Data? data;
  final bool? success;
  final int? status;

  AboutUsModel({
    this.data,
    this.success,
    this.status,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) => AboutUsModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    success: json["success"],
    status: json["status"],
  );
}

class Data {
  final dynamic? id;
  final String? title;
  final String? banner;
  final String? description;
  final dynamic metaTitle;
  final dynamic metaDescription;

  Data({
    this.id,
    this.title,
    this.banner,
    this.description,
    this.metaTitle,
    this.metaDescription,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    title: json["title"],
    banner: json["banner"],
    description: json["description"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
  );
}

// Constants
const String baseUrl = 'https://girlsparadisebd.com';

class ShippingPolicy extends StatefulWidget {
  const ShippingPolicy({Key? key}) : super(key: key);

  @override
  _ShippingPolicyState createState() => _ShippingPolicyState();
}

class _ShippingPolicyState extends State<ShippingPolicy> {
  Future<AboutUsModel>? _aboutUsFuture;
  final ProductController productController = Get.put(ProductController());
  final CardController cardController = Get.put(CardController());
  final TextEditingController searchController = TextEditingController();
  Future<void> loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];

    setState(() {
      for (var id in savedCartItems) {
        cartItems[id] = true;
      }
      for (var id in savedWishlistItems) {
        wishlistItems[id] = true;
      }
      // Update counts
      cardController.updateCartItemCount(savedCartItems.length);
      cardController.updateWishlistItemCount(savedWishlistItems.length);
    });
  }

  List<dynamic>? filteredProducts;
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};
  String? selectFilter;


  Future<void> _launchMessenger() async {
    await NativeMessengerLauncher.launchMessenger();
  }


  var filterList = [
    "Best Sale",
    "High Rated",
    "Low Rated",
  ];

  final ProfileController profileController = Get.put(ProfileController());

  Future<void> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    cardController.updateCartItemCount(savedCartItems.length);
  }

  final BlogController blogController = Get.put(BlogController());
  final TrendingController trendingController = Get.put(TrendingController());
  final BestSellingController bestSellingController =
  Get.put(BestSellingController());
  final NewArrivalController newArrivalController =
  Get.put(NewArrivalController());

  @override
  void initState() {
    super.initState();
    loadCartCount();
    loadSavedStates();
    _aboutUsFuture = _fetchAboutUsData();
  }

  Future<AboutUsModel> _fetchAboutUsData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/shipping_policy'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AboutUsModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      actions: [
        IconButton(
            onPressed: () {
              Get.to(const SearchScreen(), transition: Transition.noTransition);
            },
            icon: const Icon(
              Icons.search_outlined,
              size: 30,
              color: Colors.black,
            )),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Get.to(
                  const CartScreen(),
                  transition: Transition.noTransition,
                );

                // Refresh cart when returning from CartScreen
                if (result == true) {
                  await loadCartCount();

                  await newArrivalController.fetchProducts();
                  await trendingController.fetchProducts();
                  await bestSellingController.fetchProducts();
                  await blogController.fetchProducts();
                  // If HorizontalCard is stateful, we need to trigger a rebuild
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 25,
                color: Colors.black,
              ),
            ),
            Positioned(
              right: -1,
              bottom: 10,
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cardController.cartItemCount.value > 0
                        ? '${cardController.cartItemCount.value}'
                        : '0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(
          width: 6,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Get.to(const WishlistScreen(),
                    transition: Transition.noTransition);

                // Refresh cart when returning from CartScreen
                if (result == true) {
                  await loadCartCount();

                  await newArrivalController.fetchProducts();
                  await trendingController.fetchProducts();
                  await bestSellingController.fetchProducts();
                  await blogController.fetchProducts();

                  // If HorizontalCard is stateful, we need to trigger a rebuild
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              child: const Icon(
                Icons.favorite_outline,
                size: 25,
                color: Colors.black,
              ),
            ),
            Positioned(
              right: -1,
              bottom: 10,
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cardController.wishlistItemCount.value > 0
                        ? '${cardController.wishlistItemCount.value}'
                        : '0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        SizedBox(
          width: 6,
        ),
        GestureDetector(
            onTap: _launchMessenger,
            child: Image.asset(
              "assets/images/messenger.png",
              fit: BoxFit.contain,
              height: 20,
              width: 20,
            )),
        SizedBox(
          width: 10,
        ),
      ],
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 3,
      title: const Text(
        "Shipping Policy",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<AboutUsModel>(
      future: _aboutUsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data?.data == null) {
          return const Center(
            child: Text('No data available'),
          );
        }

        return _buildContent(snapshot.data!.data!);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _aboutUsFuture = _fetchAboutUsData();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Data data) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _aboutUsFuture = _fetchAboutUsData();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(data.banner,data.title!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildDescription(data.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(String? bannerUrl, String title) {
    if (bannerUrl == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          child: CachedNetworkImage(
            imageUrl: '$ImagebaseUrl$bannerUrl',
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              );
            },
            // loadingBuilder: (context, child, loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return Center(
            //     child: CircularProgressIndicator(
            //       value: loadingProgress.expectedTotalBytes != null
            //           ? loadingProgress.cumulativeBytesLoaded /
            //           loadingProgress.expectedTotalBytes!
            //           : null,
            //     ),
            //   );
            // },
          ),
        ),
        // Title positioned at the top center-left of the image
        Positioned(
          left: 10, // Keep text slightly away from the left edge
          top: 75, // Adjust to keep text in the upper half
          child: _buildTitle(title),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDescription(String? description) {
    if (description == null) return const SizedBox.shrink();

    return HtmlWidget(
      description,
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h2':
            return {
              'font-size': '20px',
              'font-weight': 'bold',
              'margin': '16px 0',
              'color': '#000000',
            };
          case 'p':
            return {
              'font-size': '16px',
              'color': '#000000',
              'margin': '8px 0',
              'line-height': '1.5',
            };
          default:
            return null;
        }
      },
      onTapUrl: (url) async {
        // Handle URL taps here
        return true;
      },
      renderMode: RenderMode.column,
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }
}