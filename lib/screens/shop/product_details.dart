import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:creation_edge/screens/shop/controller/product_details_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../Cart/cart_controller.dart';
import '../../Cart/cart_screen.dart';
import '../../NativeServices/native_messenger_launcher.dart';
import '../../WishList/wishList_screen.dart';
import '../../search/search_screen.dart';
import '../Arraival/controller.dart';
import '../Trending/controller.dart';
import '../bestsale/controller.dart';
import '../blog/blog_controller.dart';
import '../home/bottomNavbbar.dart';
import 'controller/product_controller.dart';
import 'model/product_details_model.dart';

class ProductDetails extends StatefulWidget {
  final int? id;
  const ProductDetails({super.key, this.id});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with SingleTickerProviderStateMixin {
  final ProductDetailsController productDetailsController =
      Get.put(ProductDetailsController());
  final CardController cardController = Get.put(CardController());
  late TabController _tabController;
  int quantity = 1;
  String? selectedImage;
  int? orderLimit;
  int? selectedPrice;
  int? defaultOldPrice;
  int? selectedDiscountedPrice;
  bool isInCart = false;
  bool isPlayingVideo = true;
  YoutubePlayerController? _youtubeController;


  void _openWhatsApp(String productName) async {
    const phoneNumber = '+8801872650280';
    final message = 'https://girlsparadisebd.com/product/$productName';

   await NativeMessengerLauncher.openWhatsApp(
        phoneNumber: phoneNumber,
        message: message
    );
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

  String? selectedVariantColor;
  int? selectvarientId;
  String? selectedVariantSize;
  Variant? selectedVariant;
  void selectVariant(Variant variant) {
    setState(() {
      selectedImage = variant.image;
      selectedVariantColor = variant.color;
      selectedVariantSize = variant.size;
      selectvarientId = variant.id;
      orderLimit = variant.orderLimit;
      selectedPrice =
          variant.salePrice; // Update price when variant is selected
      selectedDiscountedPrice = variant.discount;
      defaultOldPrice = variant.oldPrice;
      selectedVariant = variant;
      isPlayingVideo = false;
      if (_youtubeController != null) {
        _youtubeController!.pause();
      }
    });
  }

  // Add this method to refresh cart state
  void refreshCart() {
    loadSavedStates();
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildVariantDetails(List<Variant> variants) {
    return Container(
      alignment: Alignment.center,
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        itemBuilder: (_, index) {
          var variant = variants[index];
          bool isSelected = selectedVariantColor == variant.color &&
              selectedVariantSize == variant.size;

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => selectVariant(variant),
              child: Container(
                alignment: Alignment.center,
                // margin: const EdgeInsets.only(right: 10),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4),
                      child: Row(
                        children: [
                          const Text("Color: ", style: TextStyle(fontSize: 13)),
                          Text(variant.color ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4),
                      child: Row(
                        children: [
                          const Text("Size: ", style: TextStyle(fontSize: 13)),
                          Text(variant.size ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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



  String? shortVideoUrl;

  Widget buildMediaSection(dynamic product) {
    if (isPlayingVideo && product.shortVideoUrl != null) {
      return SizedBox(
        height: 300,
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: "${ImagebaseUrl}${selectedImage ?? product.defaultImage}",
          fit: BoxFit.cover,
          errorWidget: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 100),
        ),
      );
    }
  }

  Widget buildThumbnailsSection(dynamic product, List<Variant> variants) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (product.shortVideoUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isPlayingVideo = true;
                      initializeYoutubePlayer(product.shortVideoUrl!);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isPlayingVideo ? Colors.red : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                         imageUrl:  "https://img.youtube.com/vi/${product.shortVideoUrl}/0.jpg",
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ...variants
                .map((Variant variant) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPrice = variant.salePrice;
                          selectedDiscountedPrice = variant.discount;
                          defaultOldPrice = variant.oldPrice;
                          orderLimit = variant.orderLimit;
                          selectedImage = variant.image;
                          selectedVariantColor = variant.color;
                          selectedVariantSize = variant.size;
                          selectvarientId = variant.id;
                          isPlayingVideo = false;
                          if (_youtubeController != null) {
                            _youtubeController!.pause();
                          }
                        });
                        quantity= 1;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage == variant.image &&
                                    !isPlayingVideo
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "${ImagebaseUrl}${variant.image}",
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
  Future<void> _launchMessengerAppbar() async {
    await NativeMessengerLauncher.launchMessenger();
  }


  void openMessengerChat(String productName) async {
    var message =
        'https://girlsparadisebd.com/product/${productName}'; // Replace with your message
    final url = 'https://m.me/creationedges?text=${Uri.encodeFull(message)}';

    await NativeMessengerLauncher.clickhere(Uri.parse(url));


  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    productDetailsController.fetchProducts(widget.id);

    checkCartStatus();
    loadSavedQuantity();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void initializeYoutubePlayer(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  Future<void> loadSavedQuantity() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> cartProducts =
        json.decode(prefs.getString('cart_products') ?? '{}');

    if (mounted) {
      setState(() {
        // Reset quantity to 1 if product is not in cart
        if (!cartProducts.containsKey(widget.id.toString())) {
          quantity = 1;
        } else {
          quantity = cartProducts[widget.id.toString()]['quantity'] ?? 1;
        }
      });
    }
  }
  Future<void> checkCartStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCartItems = prefs.getStringList('cart_items') ?? [];
    if (mounted) {
      setState(() {
        // Check if the current variant is in cart
        String cartItemId = selectvarientId?.toString() ?? widget.id.toString();
        isInCart = savedCartItems.contains(cartItemId);
        if (!isInCart) {
          quantity = 1; // Reset quantity when product is not in cart
        }
      });
    }
  }
  Future<void> updateQuantity(bool increment) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> cartProducts =
    json.decode(prefs.getString('cart_products') ?? '{}');

    setState(() {
      if (increment && quantity < 99 && (orderLimit == 0 || quantity < orderLimit!)) {
        quantity++;
      } else if (!increment && quantity > 1) {
        quantity--;
      }
    });

    if (isInCart) {
      if (cartProducts.containsKey(widget.id.toString())) {
        cartProducts[widget.id.toString()]['quantity'] = quantity;
        await prefs.setString('cart_products', json.encode(cartProducts));
      }
    }
  }
  Future<void> addToCart(Datum product) async {
    // Validate color and size selection
    if (product.variants != null && product.variants!.isNotEmpty) {
      if (selectedVariantColor == null || selectedVariantSize == null) {
        Get.snackbar(
          'Selection Required',
          'Please select both color and size',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Use variant ID if available, otherwise fallback to product ID
    String cartItemId = selectvarientId?.toString() ?? widget.id.toString();

    final prefs = await SharedPreferences.getInstance();
    List<String> savedCartItems = prefs.getStringList('cart_items') ?? [];
    Map<String, dynamic> cartProducts = json.decode(prefs.getString('cart_products') ?? '{}');

    // Check if this variant is already in cart
    if (savedCartItems.contains(cartItemId)) {
      Get.snackbar(
        'Already Added',
        'This product variant is already in your cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    savedCartItems.add(cartItemId);

    // Create product data with selected variant information
    Map<String, dynamic> productData = {
      'id': product.id,
      'short_name': product.shortName,
      'default_price': selectedPrice ?? defaultOldPrice,
      'default_image': selectedImage ?? product.defaultImage,
      'quantity': quantity,
      'color': selectedVariantColor,
      'size': selectedVariantSize,
      'variantId': selectvarientId,
      'discount': selectedDiscountedPrice ?? 0,
      'product_type': 'regular',
    };

    cartProducts[cartItemId] = productData;

    await prefs.setStringList('cart_items', savedCartItems);
    await prefs.setString('cart_products', json.encode(cartProducts));

    cardController.updateCartItemCount(savedCartItems.length);

    setState(() {
      isInCart = true;
    });

    Get.snackbar(
      'Success',
      'Product added to cart successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> orderNow(dynamic product) async {
    Get.to(CartScreen(), transition: Transition.noTransition);
  }

  @override
  Widget build(BuildContext context) {
    print("id--${widget.id}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Obx(() => Text(
              productDetailsController.products?.data?.first.shortName ??
                  "Product Details",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            )),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(const SearchScreen(),
                    transition: Transition.noTransition);
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
                    await loadSavedStates();
                    await checkCartStatus();
                    await loadSavedQuantity();
                    await productController.fetchProducts();
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
                    await loadSavedStates();
                    await productController.fetchProducts();
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
              onTap: () {
                _launchMessengerAppbar();
              },
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
      ),
      body: Obx(() {
        if (productDetailsController.isLoading) {
          return Center(
            child: LoadingAnimationWidget.progressiveDots(
                color: Colors.red, size: 30),
          );
        }

        final product = productDetailsController.products?.data?.first;
        if (product == null) {
          return const Center(child: Text("Product not found"));
        }

        List<Variant>? variants = product.variants!;
        final defaultPrice = product.defaultPrice ?? 0 ?? 0;
        final totalPrice = defaultPrice * quantity;

        selectedImage ??= product.defaultImage;

        if (product.shortVideoUrl != null && _youtubeController == null) {
          initializeYoutubePlayer(product.shortVideoUrl!);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMediaSection(product),
              if (variants.isNotEmpty)
                buildThumbnailsSection(product, variants),

              const SizedBox(
                height: 10,
              ),

              if (selectedImage != null &&
                  selectedImage!.isNotEmpty &&
                  !isPlayingVideo)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 16, top: 0, bottom: 14),
                  child: buildVariantDetails(product.variants!),
                ),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.longName ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.shortDescription ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Price", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 40),
                        selectedPrice != null &&
                                selectedImage != null &&
                                selectedImage!.isNotEmpty &&
                                !isPlayingVideo && selectedDiscountedPrice!= 0
                            ? Row(
                                children: [
                                  Text(
                                    "৳${selectedPrice} ",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "৳${defaultOldPrice} ",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              )
                            : Text(
                                "৳${selectedPrice ?? totalPrice} ",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Code", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 40),
                        Text(
                          product.sku ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => updateQuantity(false),
                      icon: const Icon(Icons.remove, color: Colors.blue),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                       print('order limit ${orderLimit}');
                       // print order limit 1
                        updateQuantity(true);
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

// Total Price
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text("Total Price", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 16),
                  selectedPrice== null ?  Text(
                      "৳${totalPrice} ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ): Text(
                    "৳${selectedPrice! * quantity} ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (product.variants != null &&
                              product.variants!.isNotEmpty) {
                            if (selectedVariantColor == null ||
                                selectedVariantSize == null) {
                              Get.snackbar(
                                'Selection Required',
                                'Please select both color and size',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                          }
                          addToCart(product);
                          // Set a state variable to enable the Order Now button
                          setState(() {
                            isInCart = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Add To Cart",
                          style: TextStyle(
                            fontSize: 16,
                            color: isInCart ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isInCart ? () => orderNow(product) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // Add this to visually show disabled state
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Order Now",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          openMessengerChat(
                              "${product.shortNameSlug.toString()}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Message Us",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16, right: 12),
                child: Row(
                  children: [
                    Text(
                      "Share",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              await NativeMessengerLauncher.clickhere(Uri.parse( "https://www.facebook.com/sharer/sharer.php?u=https://girlsparadisebd.com/${product.shortName}"));

                            },
                            child: Image.asset(
                              "assets/images/facebook.png",
                              height: 25,
                              width: 25,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                            onTap: () async {
                              await  NativeMessengerLauncher.clickhere(Uri.parse("https://www.linkedin.com/sharing/share-offsite?mini=true&url=https://girlsparadisebd.com/${product.shortName}"));
                            },
                            child: Image.asset(
                              "assets/images/LinkedIn.png",
                              height: 25,
                              width: 25,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                            onTap: () async{
// Example usage:
                              _openWhatsApp(product.shortNameSlug.toString());

                            },
                            child: Image.asset(
                              "assets/images/whatsapp.png",
                              height: 30,
                              width: 35,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),

              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Description'),
                  Tab(text: 'Reviews'),
                ],
              ),
              SizedBox(
                height: 350,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                      child: HtmlWidget(
                        product.longDescription ?? 'No description available',
                        // Optional configurations
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        // Handle any tap on links if needed
                        onTapUrl: (url) async {
                          // Handle URL taps here
                          return true;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'No reviews yet. Be the first to review this product!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const BottomNavBar(),
            ],
          ),
        );
      }),
    );
  }
}
