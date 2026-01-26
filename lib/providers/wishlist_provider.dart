import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> wishlistItems = [];

  // ✅ check if item already added
  bool isWishlisted(String name) {
    return wishlistItems.any((item) => item['name'] == name);
  }

  // ✅ add/remove wishlist
  void toggleWishlist(Map<String, dynamic> product) {
    final index =
    wishlistItems.indexWhere((item) => item['name'] == product['name']);

    if (index != -1) {
      wishlistItems.removeAt(index);
    } else {
      wishlistItems.add(product);
    }

    notifyListeners();
  }

  void removeItem(int index) {
    wishlistItems.removeAt(index);
    notifyListeners();
  }
}
