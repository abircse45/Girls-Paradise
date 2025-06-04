import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Cart/cart_controller.dart';
import 'package:creation_edge/Profile/controller/profile_controller.dart';
import 'package:creation_edge/Profile/profile_screens.dart';
import 'package:creation_edge/Profile/tab_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:creation_edge/Social/social_link_controller.dart';
import 'package:creation_edge/contrroller/popular_controller.dart';
import 'package:creation_edge/footer/controller.dart';
import 'package:creation_edge/model/filter_model.dart';
import 'package:creation_edge/screens/Rells/rells.dart';
import 'package:creation_edge/screens/TermsCondition/termsandconditions.dart';
import 'package:creation_edge/screens/about_us_screen/about_us.dart';
import 'package:creation_edge/screens/contact_us/contact_us_screens.dart';
import 'package:creation_edge/screens/drawer_screen/drawer_youtube.dart';
import 'package:creation_edge/screens/home/all_card.dart';
import 'package:creation_edge/screens/popular/popular_products.dart';
import 'package:creation_edge/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:creation_edge/screens/return_refund/return_refund.dart';
import 'package:creation_edge/screens/youtube/youtube_screens.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:creation_edge/utils/local_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:playx_version_update/playx_version_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../Auth/auth_screen.dart';
import '../../Cart/cart_screen.dart';
import '../../NativeServices/native_messenger_launcher.dart';
import '../../Social/drawer.dart';
import '../../WishList/wishList_screen.dart';
import '../../main.dart';
import '../../notifications/push_notification_api_screeen.dart';
import '../../reels/home_reels.dart';
import '../../search/search_screen.dart';
import '../Arraival/controller.dart';
import '../Trending/controller.dart';
import '../bestsale/controller.dart';
import '../bestsale/model.dart';
import '../blog/blog_controller.dart';
import '../category_screen/filtercategory.dart';
import '../drawer_screen/drawer_product.dart';
import '../shop/controller/product_controller.dart';
import '../shop/product_details.dart';
import '../shop/product_list.dart';
import 'bottomNavbbar.dart';
import 'facebook_newsFeed.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  // Version tracking variables
  String _appVersion = '';
  String _buildNumber = '';
  bool _isLoading = true;
  bool _isAppPublishedOnAppStore = false;

  StreamSubscription<PlayxDownloadInfo?>? _downloadInfoStreamSubscription;

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _downloadInfoStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkVersion() async {
    final isIOS = Platform.isIOS;

    // Skip iOS check if not published on App Store
    if (isIOS && !_isAppPublishedOnAppStore) {
      log('Skipping iOS version check - app not published');
      return;
    }

    final result = await PlayxVersionUpdate.checkVersion(
      localVersion: _appVersion,
      forceUpdate: true, // Set to true for mandatory updates
      googlePlayId: 'com.girlsparadise.shoppingapp',
      appStoreId: isIOS ? 'com.girlsparadise.shoppingapp' : null,
      country: 'bn',
      language: 'en',
    );

    result.when(
      success: (info) {
        if (info.canUpdate) {
          _showUpdateDialog(info);
        }
      },
      error: (error) {
        log('Version check error: ${error.message}');
        // Retry after delay if failed
        Future.delayed(const Duration(seconds: 30), _checkVersion);
      },
    );
  }
  void _showUpdateDialog(PlayxVersionUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (context) => PlayxUpdateDialog(
        versionUpdateInfo: info,
        title: (info) => info.forceUpdate
            ? 'Update Required'
            : 'New Update Available',
        description: (info) => info.forceUpdate
            ? 'You must update to continue using the app'
            : 'A new version is available with improvements',
        releaseNotesTitle: (info) => 'What\'s New',
        showReleaseNotes: true,
        updateActionTitle: 'Update Now',
        dismissActionTitle: info.forceUpdate ? null : 'Later',
        isDismissible: !info.forceUpdate,
      ),
    );
  }
  void _listenToFlexibleDownloadUpdates() {
    _downloadInfoStreamSubscription = PlayxVersionUpdate
        .listenToFlexibleDownloadUpdate()
        .listen((info) {
      if (info?.status == PlayxDownloadStatus.downloaded) {
        _showInstallPrompt();
      }
    });
  }

  void _showInstallPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Update ready to install!'),
        action: SnackBarAction(
          label: 'INSTALL',
          onPressed: () => PlayxVersionUpdate.completeFlexibleUpdate(),
        ),
        duration: const Duration(days: 1), // Persistent until installed
      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingUpdate();
    }
  }

  Future<void> _checkPendingUpdate() async {
    final result = await PlayxVersionUpdate.isFlexibleUpdateNeedToBeInstalled();
    result.when(
      success: (needsInstall) {
        if (needsInstall) _showInstallPrompt();
      },
      error: (error) => log(error.message),
    );
  }





  late TabController _tabController;
  final FooterController footerController = Get.put(FooterController());
  final SocialLinksController socialLinksController =
      Get.put(SocialLinksController());

  String? selectFilter;
  final CardController cardController = Get.put(CardController());
  Future<void> _launchMessenger() async {
    await NativeMessengerLauncher.launchMessenger();
  }


  var filterList = [
    "Best Sale",
    "High Rated",
    "Low Rated",
    "Discount Product",
  ];

  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _initPackageInfo();
    _setupVersionUpdate();
    loadCartCount();
    loadSavedStates();
    profileController.fetchProfileData();

    // Setup token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      deviceToken = newToken;
      updateDeviceToken();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await footerController.fetchFooterSettings();
      await socialLinksController.fetchSocialLinks();
      await initialize(); // Now calls updateDeviceToken internally

    });
  }
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = info.version);
  }

  void _setupVersionUpdate() {
    _listenToFlexibleDownloadUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), _checkVersion);
    });
  }


  Future<void> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    cardController.updateCartItemCount(savedCartItems.length);
  }

  final ProductController productController = Get.put(ProductController());
  final BlogController blogController = Get.put(BlogController());
  final TrendingController trendingController = Get.put(TrendingController());
  final BestSellingController bestSellingController =
      Get.put(BestSellingController());
  final NewArrivalController newArrivalController =
      Get.put(NewArrivalController());

  // Map to track cart and wishlist states
  Map<String, bool> cartItems = {};
  Map<String, bool> wishlistItems = {};

  // Add this method to refresh cart state
  void refreshCart() {
    loadSavedStates();
    if (mounted) {
      setState(() {});
    }
  }

  // Update loadSavedStates to be public
  Future<void> loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    final savedWishlistItems = prefs.getStringList('wishlist_items') ?? [];

    if (mounted) {
      setState(() {
        cartItems.clear(); // Clear existing items
        wishlistItems.clear();

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
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  var deviceToken;
  Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get APNS token first (iOS only)
        if (Platform.isIOS) {
          String? apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            print("APNS token not yet available, will retry");
            await Future.delayed(Duration(seconds: 2));
          }
        }

        // Then get FCM token
        deviceToken = await _firebaseMessaging.getToken();
        if (deviceToken != null) {
          log("Firebase Device Token: $deviceToken");
        } else {
          print("Failed to retrieve Firebase Device Token");
        }

        // Subscribe to topic
        await _firebaseMessaging.subscribeToTopic('all_devices');
        print("Subscribed to 'all_devices' topic");
      }
    } catch (e) {
      print("Error initializing Firebase Messaging: $e");
      // Retry after delay if needed
      await Future.delayed(Duration(seconds: 5));
      await initialize();
    }
  }
  Future updateDeviceToken() async {
    if (deviceToken == null) {
      print("Device token not available yet");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("https://girlsparadisebd.com/api/v1/update_device_token"),
        body: {"device_token": "$deviceToken"},
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        print("Device token updated successfully");
      } else {
        print("Failed to update device token: ${response.statusCode}");
        // Consider retrying after delay
      }
    } catch (e) {
      print("Error updating device token: $e");
    }
  }

  bool get isLoading =>
      productController.isLoading ||
      blogController.isLoading ||
      bestSellingController.isLoading ||
      newArrivalController.isLoading ||
      bestSellingController.isLoading;

  Future<void> toggleCart(String productId, dynamic productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts =
        json.decode(prefs.getString('cart_products') ?? '{}');

    if (cartItems[productId] == true) {
      // Notify the user that the product is already in the cart
      Get.snackbar(
        'Already Added This Product',
        'This product is already in your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      // Add the product to the cart
      setState(() {
        cartItems[productId] = true;
        savedCartItems.add(productId);
        cartProducts[productId] = productData.toJson();
      });

      await prefs.setStringList('cart_items', savedCartItems);
      await prefs.setString('cart_products', json.encode(cartProducts));

      // Update cart count
      cardController.updateCartItemCount(savedCartItems.length);
    }
  }

  Future<void> toggleCartNewProduct(
      String productId, DatumNewProduct productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts =
        json.decode(prefs.getString('cart_products') ?? '{}');

    if (cartItems[productId] == true) {
      // Notify the user that the product is already in the cart
      Get.snackbar(
        'Already Added This Product',
        'This product is already in your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      // Add the product to the cart
      setState(() {
        cartItems[productId] = true;
        savedCartItems.add(productId);
        cartProducts[productId] = productData.toJson();
      });

      await prefs.setStringList('cart_items', savedCartItems);
      await prefs.setString('cart_products', json.encode(cartProducts));

      // Update cart count
      cardController.updateCartItemCount(savedCartItems.length);
    }
  }

  Future<void> toggleCartFilter(
      String productId, ProductFilter productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts =
        json.decode(prefs.getString('cart_products') ?? '{}');

    if (cartItems[productId] == true) {
      // Notify the user that the product is already in the cart
      Get.snackbar(
        'Already Added This Product',
        'This product is already in your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else {
      // Add the product to the cart
      setState(() {
        cartItems[productId] = true;
        savedCartItems.add(productId);
        cartProducts[productId] = productData.toJson();
      });

      await prefs.setStringList('cart_items', savedCartItems);
      await prefs.setString('cart_products', json.encode(cartProducts));

      // Update cart count
      cardController.updateCartItemCount(savedCartItems.length);
    }
  }

  Future<void> toggleWishlist(String productId, dynamic productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedWishlistItems =
        prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> wishlistProducts =
        json.decode(prefs.getString('wishlist_products') ?? '{}');

    if (wishlistItems[productId] == true) {
      Get.snackbar(
        'Already Added',
        'This product is already in your wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Add the product to the wishlist
    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = productData.toJson();
    });

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString('wishlist_products', json.encode(wishlistProducts));

    // Update wishlist count
    cardController.updateWishlistItemCount(savedWishlistItems.length);

    Get.snackbar(
      'Added to Wishlist',
      'Item has been added to your wishlist',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

// New product toggle method
  Future<void> toggleWishlistNewproduct(
      String productId, DatumNewProduct productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedWishlistItems =
        prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> wishlistProducts =
        json.decode(prefs.getString('wishlist_products') ?? '{}');

    if (wishlistItems[productId] == true) {
      Get.snackbar(
        'Already Added',
        'This product is already in your wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Standardize new product data
    final standardizedData = {
      'id': productId,
      'short_name': productData.shortName,
      'default_price': productData.salePrice,
      'default_image': productData.image,
      'product_type': 'new'
    };

    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = standardizedData;
    });

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString('wishlist_products', json.encode(wishlistProducts));

    // Update wishlist count
    cardController.updateWishlistItemCount(savedWishlistItems.length);

    Get.snackbar(
      'Added to Wishlist',
      'Item has been added to your wishlist',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> toggleWishlistFilter(
      String productId, ProductFilter productData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedWishlistItems =
        prefs.getStringList('wishlist_items') ?? [];
    Map<String, dynamic> wishlistProducts =
        json.decode(prefs.getString('wishlist_products') ?? '{}');

    if (wishlistItems[productId] == true) {
      Get.snackbar(
        'Already Added',
        'This product is already in your wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Standardize filter product data
    final standardizedData = {
      'id': productId,
      'short_name': productData.name,
      'default_price': productData.price,
      'default_image': productData.image,
      'product_type': 'filter'
    };

    setState(() {
      wishlistItems[productId] = true;
      savedWishlistItems.add(productId);
      wishlistProducts[productId] = standardizedData;
    });

    await prefs.setStringList('wishlist_items', savedWishlistItems);
    await prefs.setString('wishlist_products', json.encode(wishlistProducts));

    // Update wishlist count
    cardController.updateWishlistItemCount(savedWishlistItems.length);

    Get.snackbar(
      'Added to Wishlist',
      'Item has been added to your wishlist',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }


  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const MaterialApp(
    //     home: Scaffold(
    //       body: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
    // }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final bool shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                content: const Text('Are you sure you want to close the app?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 80,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/home.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Feed'),
                onTap: () {
                  Get.to(const HomeScreens(), transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/cartmain.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Shop'),
                onTap: () {
                  Get.to(DrawerProduct(), transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/video.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Video'),
                onTap: () {
                  Get.to(const DrawerYoutube(),
                      transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/reels.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Reels'),
                onTap: () {
                  Get.to(const ReelsScreen(),
                      transition: Transition.noTransition);
                },
              ),
              Obx(() {
                final controller = Get.find<SocialLinksController>();
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.socialLinks.isEmpty) {
                  return const Center(child: Text('No Social Links Available'));
                }
                return Column(
                  children: controller.socialLinks.map((link) {
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: "${ImagebaseUrl}${link.iconImage}",
                        height: 25,
                        width: 25,
                      ),
                      title: Text(link.name),
                      onTap: () async {
                        await NativeMessengerLauncher.clickhere(Uri.parse(link.link!));

                        // final Uri uri = Uri.parse(link.link);
                        // if (await canLaunchUrl(uri)) {
                        //   await launchUrl(uri,
                        //       mode: LaunchMode.externalApplication);
                        // } else {
                        //   Get.snackbar('Error', 'Could not open link');
                        // }
                      },
                    );
                  }).toList(),
                );
              }),
              const Divider(),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/link.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('About Us'),
                onTap: () {
                  Get.to(AboutUs(), transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/link.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Return & Refund Policy'),
                onTap: () {
                  Get.to(ReturnRefund(), transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/link.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Terms & Conditions'),
                onTap: () {
                  Get.to(Termsandconditions(),
                      transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/link.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Privacy Policy'),
                onTap: () {
                  Get.to(PrivacyPolicyScreen(),
                      transition: Transition.noTransition);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/images/link.svg",
                  height: 25,
                  width: 25,
                ),
                title: const Text('Contact Us'),
                onTap: () {
                  Get.to(ContactUsScreen(),
                      transition: Transition.noTransition);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(45),
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.black,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                            icon: Image.asset(
                          "assets/images/home_0.png",
                          height: 28,
                        )),
                        Tab(
                            icon: Image.asset(
                          "assets/images/shop.png",
                          height: 26,
                        )),
                        Tab(
                            icon: Image.asset(
                          "assets/images/reel.png",
                          height: 27,
                        )),
                        Tab(
                            icon: Image.asset(
                          "assets/images/video.png",
                          height: 27,
                        )),
                        Tab(
                            icon: Image.asset(
                          "assets/images/bell.png",
                          height: 25,
                        )),
                        accessToken.isNotEmpty
                            ? Obx(() {
                                if (profileController.isLoading.value) {
                                  return Center(
                                    child: Container(),
                                  );
                                } else {
                                  return CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[400],
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundImage: NetworkImage(
                                          "${ImagebaseUrl}${profileController.userData.value?["photo"]}"),
                                    ),
                                  );
                                }
                              })
                            : CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[400],
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 14,
                                  backgroundImage:
                                      AssetImage("assets/images/logo1.png"),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                size: 25,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    "assets/images/appbarlogo.png",
                    width: MediaQuery.of(context).size.width * 0.45, // Adjust width dynamically
                    height: 50, // Adjust height accordingly
                    fit: BoxFit.contain, // Ensure proper scaling
                  ),
                ),
              ),
            ],
          ),
          leadingWidth: 25,
          actions: [
            GestureDetector(
              onTap: () {
                Get.to(const SearchScreen(), transition: Transition.noTransition);
              },
              child: const Icon(
                Icons.search_outlined,
                size: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () async {
                final result = await Get.to(
                  const CartScreen(),
                  transition: Transition.noTransition,
                );

                if (result == true) {
                  await Future.wait([
                    loadCartCount(),
                    loadSavedStates(),
                    productController.fetchProducts(),
                    newArrivalController.fetchProducts(),
                    trendingController.fetchProducts(),
                    bestSellingController.fetchProducts(),
                    blogController.fetchProducts(),
                  ]);

                  if (mounted) setState(() {});
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 25,
                    color: Colors.black,
                  ),
                  Positioned(
                    right: -5,
                    top: -5,
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
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final result = await Get.to(
                  const WishlistScreen(),
                  transition: Transition.noTransition,
                );

                if (result == true) {
                  await Future.wait([
                    loadCartCount(),
                    loadSavedStates(),
                    productController.fetchProducts(),
                    newArrivalController.fetchProducts(),
                    trendingController.fetchProducts(),
                    bestSellingController.fetchProducts(),
                    blogController.fetchProducts(),
                  ]);

                  if (mounted) setState(() {});
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    size: 25,
                    color: Colors.black,
                  ),
                  Positioned(
                    right: -5,
                    top: -5,
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
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _launchMessenger,
              child: Image.asset(
                "assets/images/messenger.png",
                fit: BoxFit.contain,
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Obx(() {
          if (isLoading) {
            return ListView(
              shrinkWrap: true,
              primary: false,
              children: [
                buildProductListShimmer(), // Horizontal product shimmer

                buildProductListShimmerCategory(), // Horizontal product shimmer

                buildProductGridShimmer(),
                buildProductGridShimmerNew() // Grid product shimmer
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                     RefreshIndicator(
                        onRefresh: () async {
                          await loadCartCount();
                          await loadSavedStates();
                          await productController.fetchProducts();
                        },
                        child: ListView(
                          shrinkWrap: true,
                          primary: false,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 4.0, right: 4),
                              child: SizedBox(
                                height: 250,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: productController
                                      .products?.data?.length ??
                                      0,
                                  itemBuilder: (_, index) {
                                    var data = productController
                                        .products?.data?[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2.0, right: 2.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            ProductDetails(
                                              id: data?.id,
                                            ),
                                            transition: Transition.noTransition,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 4.0, right: 4, top: 4, bottom: 4),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Stack(
                                              children: [
                                               CachedNetworkImage(
                                                  height: 240,
                                                  width: 170,
                                                 imageUrl:  "${ImagebaseUrl}${data?.defaultImage}",
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, exception, stackTrace) {
                                                    return Image.asset(
                                                      height: 240,
                                                      width: 170,
                                                      "assets/images/logo.jpeg",
                                                      fit: BoxFit.fill,
                                                    );
                                                  },
                                                ),
                                                _buildActionButtons(data),
                                                _buildProductInfo(data),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            PopularCategories(),
                            const SizedBox(height: 5),
                            const FacebookNewsFeedScreen(),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                surfaceTintColor: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "New Arrival Product",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(() {
                                        if (newArrivalController.isLoading &&
                                            newArrivalController
                                                .displayedProducts.isEmpty) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }

                                        return Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount: (newArrivalController
                                                  .displayedProducts
                                                  .length ~/
                                                  2) +
                                                  (newArrivalController
                                                      .displayedProducts
                                                      .length %
                                                      2),
                                              itemBuilder: (_, index) {
                                                final firstItemIndex =
                                                    index * 2;
                                                final secondItemIndex =
                                                    firstItemIndex + 1;

                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: AspectRatio(
                                                        aspectRatio: 4 / 6,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Get.to(
                                                              ProductDetails(
                                                                id: newArrivalController
                                                                    .displayedProducts[
                                                                firstItemIndex]
                                                                    .id,
                                                              ),
                                                              transition: Transition
                                                                  .noTransition,
                                                            );
                                                          },
                                                          child:
                                                          _buildNewItemCard(
                                                            newArrivalController
                                                                .displayedProducts[
                                                            firstItemIndex],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: AspectRatio(
                                                        aspectRatio: 4 / 6,
                                                        child: secondItemIndex <
                                                            newArrivalController
                                                                .displayedProducts
                                                                .length
                                                            ? GestureDetector(
                                                          onTap: () {
                                                            Get.to(
                                                              ProductDetails(
                                                                id: newArrivalController
                                                                    .displayedProducts[
                                                                secondItemIndex]
                                                                    .id,
                                                              ),
                                                              transition:
                                                              Transition
                                                                  .noTransition,
                                                            );
                                                          },
                                                          child:
                                                          _buildNewItemCard(
                                                            newArrivalController
                                                                .displayedProducts[
                                                            secondItemIndex],
                                                          ),
                                                        )
                                                            : Container(),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            if (newArrivalController
                                                .hasMoreProducts)
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(10.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    newArrivalController
                                                        .loadMoreProducts();
                                                  },
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                      Alignment.center,
                                                      height: 40,
                                                      width: 180,
                                                      decoration: BoxDecoration(
                                                          color: Colors.indigo,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10)),
                                                      child: const Text(
                                                        "Load More",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                surfaceTintColor: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Best Selling Product",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: (bestSellingController
                                            .products
                                            ?.data
                                            ?.length ??
                                            0) ~/
                                            2 +
                                            (bestSellingController.products
                                                ?.data?.length ??
                                                0) %
                                                2,
                                        itemBuilder: (_, index) {
                                          // Calculate indices for two items in each row
                                          final firstItemIndex = index * 2;
                                          final secondItemIndex =
                                              firstItemIndex + 1;

                                          return Row(
                                            children: [
                                              // First item
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.to(
                                                      ProductDetails(
                                                          id: bestSellingController
                                                              .products
                                                              ?.data?[
                                                          firstItemIndex]
                                                              ?.id),
                                                      transition: Transition
                                                          .noTransition,
                                                    );
                                                  },
                                                  child: _buildNewItemCard(
                                                      bestSellingController
                                                          .products!.data![
                                                      firstItemIndex]!),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                  8), // Spacing between items
                                              // Second item (if exists)
                                              Expanded(
                                                child: secondItemIndex <
                                                    (bestSellingController
                                                        .products
                                                        ?.data
                                                        ?.length ??
                                                        0)
                                                    ? GestureDetector(
                                                  onTap: () {
                                                    Get.to(
                                                      ProductDetails(
                                                          id: bestSellingController
                                                              .products
                                                              ?.data?[
                                                          secondItemIndex]
                                                              ?.id),
                                                      transition: Transition
                                                          .noTransition,
                                                    );
                                                  },
                                                  child: _buildNewItemCard(
                                                      bestSellingController
                                                          .products!
                                                          .data![
                                                      secondItemIndex]!),
                                                )
                                                    : Container(), // Empty container for odd number of items
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Card(
                                elevation: 0,
                                color: Colors.grey[100],
                                surfaceTintColor: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Trending Product",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(() {
                                        if (trendingController.isLoading &&
                                            trendingController
                                                .displayedProducts.isEmpty) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }

                                        return Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount: (trendingController
                                                  .displayedProducts
                                                  .length ~/
                                                  2) +
                                                  (trendingController
                                                      .displayedProducts
                                                      .length %
                                                      2),
                                              itemBuilder: (_, index) {
                                                final firstItemIndex =
                                                    index * 2;
                                                final secondItemIndex =
                                                    firstItemIndex + 1;

                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            ProductDetails(
                                                              id: trendingController
                                                                  .displayedProducts[
                                                              firstItemIndex]
                                                                  .id,
                                                            ),
                                                            transition: Transition
                                                                .noTransition,
                                                          );
                                                        },
                                                        child:
                                                        _buildNewItemCard(
                                                          trendingController
                                                              .displayedProducts[
                                                          firstItemIndex],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: secondItemIndex <
                                                          trendingController
                                                              .displayedProducts
                                                              .length
                                                          ? GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            ProductDetails(
                                                              id: trendingController
                                                                  .displayedProducts[
                                                              secondItemIndex]
                                                                  .id,
                                                            ),
                                                            transition:
                                                            Transition
                                                                .noTransition,
                                                          );
                                                        },
                                                        child:
                                                        _buildNewItemCard(
                                                          trendingController
                                                              .displayedProducts[
                                                          secondItemIndex],
                                                        ),
                                                      )
                                                          : Container(),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            if (trendingController
                                                .hasMoreProducts) ...[
                                              const SizedBox(height: 20),
                                              GestureDetector(
                                                onTap: () {
                                                  trendingController
                                                      .fetchProducts();
                                                },
                                                child: Center(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 40,
                                                    width: 180,
                                                    decoration: BoxDecoration(
                                                      color: Colors.indigo,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                    ),
                                                    child: const Text(
                                                      "Load More",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const BottomNavBar(),
                          ],
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: () async {
                          await loadCartCount();
                          await loadSavedStates();
                          await productController.fetchProducts();
                        },
                        child: ListView(
                          shrinkWrap: true,
                          primary: false,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 12.0, top: 6, bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(
                                        () => Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        "${productController.filterProduct!.data!.products?.length} Item Found",
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: DropdownButtonHideUnderline(
                                        child: Container(
                                          // width: 120,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              color:
                                              Colors.indigo.withOpacity(0.1)),

                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8),
                                            child: DropdownButton(
                                                hint: const Text(
                                                  "Select Filter",
                                                  style: TextStyle(
                                                      color: Colors.indigo),
                                                ),
                                                items: filterList.map((e) {
                                                  return DropdownMenuItem(
                                                    child: Text(
                                                      e,
                                                      style: TextStyle(
                                                          color: Colors.indigo),
                                                    ),
                                                    value: e,
                                                  );
                                                }).toList(),
                                                value: selectFilter == ""
                                                    ? null
                                                    : selectFilter,
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectFilter = val!;
                                                  });

                                                  if (selectFilter == "Best Sale") {
                                                    productController
                                                        .fetchFilterProducts(
                                                        "best");
                                                  } else if (selectFilter ==
                                                      "High Rated") {
                                                    productController
                                                        .fetchFilterProducts(
                                                        "high");
                                                  } else if (selectFilter ==
                                                      "Low Rated") {
                                                    productController
                                                        .fetchFilterProducts("low");
                                                  } else if (selectFilter ==
                                                      "Discount Product") {
                                                    productController
                                                        .fetchFilterProducts(
                                                        "discount");
                                                  }
                                                }),
                                          ),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(const CategoryScreen(),
                                          transition: Transition.noTransition);
                                    },
                                    child: Container(
                                      height: 45,
                                      padding: EdgeInsets.all(10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.filter_list_alt,
                                            color: Colors.indigo,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "Filter",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.indigo),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Obx(() => isLoading
                                ? const Center(
                                child: CircularProgressIndicator())
                                : Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: (productController
                                      .displayedProducts.length ~/
                                      2) +
                                      ((productController
                                          .displayedProducts
                                          .length %
                                          2 ==
                                          0)
                                          ? 0
                                          : 1),
                                  itemBuilder: (context, index) {
                                    final int firstItemIndex = index * 2;
                                    final int secondItemIndex =
                                        firstItemIndex + 1;

                                    final firstItem = productController
                                        .displayedProducts[
                                    firstItemIndex];
                                    final secondItem = secondItemIndex <
                                        productController
                                            .displayedProducts.length
                                        ? productController
                                        .displayedProducts[
                                    secondItemIndex]
                                        : null;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4.0, right: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.to(
                                                  ProductDetails(
                                                      id: firstItem.id),
                                                  transition: Transition
                                                      .noTransition,
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 4.0,
                                                  right: 4,
                                                  top: 6,
                                                  bottom: 6,
                                                ),
                                                child:
                                                _filterbuildProductCard(
                                                    firstItem),
                                              ),
                                            ),
                                          ),
                                          if (secondItem != null)
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                    ProductDetails(
                                                        id: secondItem
                                                            .id),
                                                    transition: Transition
                                                        .noTransition,
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                    left: 4.0,
                                                    right: 4,
                                                    top: 6,
                                                    bottom: 6,
                                                  ),
                                                  child:
                                                  _filterbuildProductCard(
                                                      secondItem),
                                                ),
                                              ),
                                            )
                                          else
                                            Expanded(child: Container()),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (productController
                                    .hasMoreProducts) ...[
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      productController
                                          .loadMoreProducts();
                                    },
                                    child: Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.indigo,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Load More",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ],
                            )),
                            const SizedBox(height: 20),
                            const BottomNavBar(),
                          ],
                        ),
                      ),
                      const HomeReels(),
                      const YoutubeScreens(),
                      const PushNotificationApiScreen(),
                      const TabProfile(),
                    ],
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget buildProductListShimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Number of shimmer items
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 160,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 80,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildProductListShimmerCategory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        child: SizedBox(
          height: 140,
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: 8, // Number of shimmer items
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 160,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 80,
                                    height: 10,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

// Shimmer loader for grid/list product view
  Widget buildProductGridShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: 1, // Number of shimmer rows
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

  Widget buildProductGridShimmerNew() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: 1, // Number of shimmer rows
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4),
          child: Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
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
              ),
              Expanded(
                child: Shimmer.fromColors(
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(dynamic data) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4, top: 4, bottom: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CachedNetworkImage(
              height: 240,
              width: 170,
              imageUrl: "${ImagebaseUrl}${data?.defaultImage}",
              fit: BoxFit.cover,
              // loadingBuilder: (BuildContext context, Widget child,
              //     ImageChunkEvent? loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Center(
              //     child: CircularProgressIndicator(
              //       value: loadingProgress.expectedTotalBytes != null
              //           ? loadingProgress.cumulativeBytesLoaded /
              //               loadingProgress.expectedTotalBytes!
              //           : null,
              //     ),
              //   );
              // },
              errorWidget: (context, exception, stackTrace) {
                return Image.asset(
                  height: 240,
                  width: 170,
                  "assets/images/logo.jpeg",
                  fit: BoxFit.fill,
                );
              },
            ),
            _buildActionButtons(data),
            _buildProductInfo(data),
          ],
        ),
      ),
    );
  }

  Widget _filterbuildProductCard(ProductFilter data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width / 2,
            imageUrl: "${ImagebaseUrl}${data?.image}",
            fit: BoxFit.cover,
            // loadingBuilder: (BuildContext context, Widget child,
            //     ImageChunkEvent? loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return          buildProductGridShimmer();// Ho();
            // },
            // loadingBuilder: (BuildContext context, Widget child,
            //     ImageChunkEvent? loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return Center(
            //     child: CircularProgressIndicator(
            //       value: loadingProgress.expectedTotalBytes != null
            //           ? loadingProgress.cumulativeBytesLoaded /
            //               loadingProgress.expectedTotalBytes!
            //           : null,
            //     ),
            //   );
            // },
            errorWidget: (context, exception, stackTrace) {
              return Image.asset(
                height: 240,
                width: 170,
                "assets/images/logo.jpeg",
                fit: BoxFit.fill,
              );
            },
          ),
          _filterbuildActionButtons(data),
          _filterbuildProductInfo(data),
        ],
      ),
    );
  }

  Widget _buildProductInfo(dynamic data) {
    return Positioned(
      bottom: 5,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 2, right: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "${data?.shortName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withOpacity(0.8),
                ),
                child: Text(
                  '৳${data?.defaultPrice}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoNew(dynamic data) {
    return Positioned(
      bottom: 5,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 2, right: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "${data?.shortName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withOpacity(0.8),
                ),
                child: Text(
                  '৳${data?.salePrice}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterbuildProductInfo(ProductFilter data) {
    return Positioned(
      bottom: 5,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(left: 2, right: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "${data?.name}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withOpacity(0.8),
                ),
                child: Text(
                  '৳${data?.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic data) {
    String productId = data?.id.toString() ?? '';
    bool isInCart = cartItems[productId] ?? false;
    bool isInWishlist = wishlistItems[productId] ?? false;

    return Positioned(
      top: 10,
      left: -5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FittedBox(
          // Use FittedBox to scale content if needed
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: Icons.shopping_cart,
                onTap: () => toggleCart(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(height: 8), // Reduced spacing
              _buildButton(
                icon: Icons.favorite_outline,
                onTap: () => toggleWishlist(productId, data),
                isActive: isInWishlist,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterbuildActionButtons(ProductFilter data) {
    String productId = data?.id.toString() ?? '';
    bool isInCart = cartItems[productId] ?? false;
    bool isInWishlist = wishlistItems[productId] ?? false;

    return Positioned(
      top: 10,
      left: -5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FittedBox(
          // Use FittedBox to scale content if needed
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: Icons.shopping_cart,
                onTap: () => toggleCartFilter(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(height: 8), // Reduced spacing
              _buildButton(
                icon: Icons.favorite_outline,
                onTap: () => toggleWishlistFilter(productId, data),
                isActive: isInWishlist,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsNew(DatumNewProduct data) {
    String productId = data?.id.toString() ?? '';
    bool isInCart = cartItems[productId] ?? false;
    bool isInWishlist = wishlistItems[productId] ?? false;

    return Positioned(
      top: 10,
      left: -5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FittedBox(
          // Use FittedBox to scale content if needed
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: Icons.shopping_cart,
                onTap: () => toggleCartNewProduct(productId, data),
                isActive: isInCart,
              ),
              const SizedBox(height: 8), // Reduced spacing
              _buildButton(
                icon: Icons.favorite_outline,
                onTap: () => toggleWishlistNewproduct(productId, data),
                isActive: isInWishlist,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: SizedBox(
        width: 35,
        height: 35,
        child: Material(
          color: isActive ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewItemCard(DatumNewProduct data) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            CachedNetworkImage(
              width: double.infinity,
              fit: BoxFit.cover,
              imageUrl: "${ImagebaseUrl}${data?.image}",
              // loadingBuilder: (BuildContext context, Widget child,
              //     ImageChunkEvent? loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Center(
              //     child: CircularProgressIndicator(
              //       value: loadingProgress.expectedTotalBytes != null
              //           ? loadingProgress.cumulativeBytesLoaded /
              //               loadingProgress.expectedTotalBytes!
              //           : null,
              //     ),
              //   );
              // },
              errorWidget: (context, exception, stackTrace) {
                return Image.asset(
                  height: 240,
                  width: double.infinity,
                  "assets/images/logo.jpeg",
                  fit: BoxFit.fill,
                );
              },
            ),
            _buildActionButtonsNew(data),
            _buildProductInfoNew(data),
          ],
        ),
      ),
    );
  }
}
