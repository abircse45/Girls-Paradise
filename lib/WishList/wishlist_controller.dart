import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constance.dart';
import '../utils/local_store.dart';

class WishlistController extends GetxController {
  RxBool isLoading = false.obs;
  RxInt wishlistCount = 0.obs;
  RxMap<String, bool> wishlistItems = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // First load from local storage, then fetch from API
    _loadWishlistFromPrefs().then((_) {
      if (accessToken.isNotEmpty) {
        loadWishlistItems();
        getWishlistCount();
      }
    });
  }

  Future<void> loadWishlistItems() async {
    if (accessToken.isEmpty) return;

    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('http://creationedge.com.bd/api/v1/customer_wishlist'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          // Update items while preserving reactivity
          final Map<String, bool> newItems = {};
          for (var item in items) {
            String productId = item['product_id'].toString();
            newItems[productId] = true;
          }
          wishlistItems.value = newItems;
          // Save to SharedPreferences for persistence
          await _saveWishlistToPrefs();
        }
      }
    } catch (e) {
      print('Error loading wishlist items: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _saveWishlistToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> productIds = wishlistItems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      await prefs.setStringList('wishlist_items', productIds);
    } catch (e) {
      print('Error saving wishlist to prefs: $e');
    }
  }

  Future<void> _loadWishlistFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedItems = prefs.getStringList('wishlist_items') ?? [];
      wishlistItems.clear();
      for (String productId in savedItems) {
        wishlistItems[productId] = true;
      }
    } catch (e) {
      print('Error loading wishlist from prefs: $e');
    }
  }


  bool isProductInWishlist(String productId) {
    return wishlistItems[productId] ?? false;
  }
  Future<bool> addToWishlist(String productId) async {
    if (accessToken.isEmpty) {
      Get.snackbar(
        'Login Required',
        'Please login to add items to wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse('http://creationedge.com.bd/api/v1/add_wishlist_product'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        wishlistItems[productId] = true;
        await _saveWishlistToPrefs();
        await getWishlistCount();

        Get.snackbar(
          'Success',
          'Product added to wishlist',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse('http://creationedge.com.bd/api/v1/delete_wishlist_product'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'wishlist_id': productId}),
      );

      if (response.statusCode == 200) {
        wishlistItems.remove(productId);
        await _saveWishlistToPrefs();
        await getWishlistCount();

        Get.snackbar(
          'Success',
          'Product removed from wishlist',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Future<bool> addToWishlist(String productId) async {
  //   if (accessToken.isEmpty) {
  //     Get.snackbar(
  //       'Login Required',
  //       'Please login to add items to wishlist',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return false;
  //   }
  //
  //   try {
  //     isLoading(true);
  //
  //     final response = await http.post(
  //       Uri.parse('http://creationedge.com.bd/api/v1/add_wishlist_product'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'product_id': productId,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Update local wishlist state
  //       wishlistItems[productId] = true;
  //       await _saveWishlistToPrefs();
  //
  //       // Update the wishlist count
  //       await getWishlistCount();
  //
  //       Get.snackbar(
  //         'Success',
  //         'Product added to wishlist',
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Error adding to wishlist: $e');
  //     return false;
  //   } finally {
  //     isLoading(false);
  //   }
  // }
  //
  // final _wishlistUpdateController = StreamController<String>.broadcast();
  // Stream<String> get wishlistUpdates => _wishlistUpdateController.stream;
  //
  //
  // Future<bool> removeFromWishlist(String productId) async {
  //   try {
  //     isLoading(true);
  //
  //     final response = await http.post(
  //       Uri.parse('https://girlsparadisebd.com/api/v1/delete_wishlist_product'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'wishlist_id': productId,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Update local wishlist state
  //       wishlistItems.remove(productId);
  //       await _saveWishlistToPrefs();
  //
  //       // Update the wishlist items map
  //       wishlistItems[productId] = false;
  //
  //       // Notify all listeners about the removal
  //       _wishlistUpdateController.add(productId);
  //
  //       // Update the wishlist count
  //       await getWishlistCount();
  //
  //       Get.snackbar(
  //         'Success',
  //         'Product removed from wishlist',
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Error removing from wishlist: $e');
  //     return false;
  //   } finally {
  //     isLoading(false);
  //   }
  // }


  // Future<bool> removeFromWishlist(String productId) async {
  //   try {
  //     isLoading(true);
  //
  //     final response = await http.post(
  //       Uri.parse('https://girlsparadisebd.com/api/v1/delete_wishlist_product'),
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'wishlist_id': productId,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Update local wishlist state
  //       wishlistItems.remove(productId);
  //       await _saveWishlistToPrefs();
  //
  //       // Notify all listeners about the removal
  //       _wishlistUpdateController.add(productId);
  //
  //       // Update the wishlist count
  //       await getWishlistCount();
  //
  //       Get.snackbar(
  //         'Success',
  //         'Product removed from wishlist',
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Error removing from wishlist: $e');
  //     return false;
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> getWishlistCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://creationedge.com.bd/api/v1/customer_wishlist'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['total_wishlist'] != null) {
          wishlistCount.value = data['total_wishlist'];
        }
      }
    } catch (e) {
      print('Error getting wishlist count: $e');
    }
  }
}
