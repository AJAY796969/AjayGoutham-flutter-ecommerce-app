import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _orderHistory = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;

  // ADD ITEM (with quantity)
  void addItem(Map<String, dynamic> product) {
    final index =
    _cartItems.indexWhere((item) => item['name'] == product['name']);

    if (index >= 0) {
      _cartItems[index]['quantity']++;
    } else {
      _cartItems.add({
        ...product,
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  // INCREASE QUANTITY
  void increaseQuantity(int index) {
    _cartItems[index]['quantity']++;
    notifyListeners();
  }

  // DECREASE QUANTITY
  void decreaseQuantity(int index) {
    if (_cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity']--;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  // PLACE ORDER
  void placeOrder() {
    if (_cartItems.isEmpty) return;

    _orderHistory.add({
      'items': List<Map<String, dynamic>>.from(_cartItems),
      'date': DateTime.now(),
    });

    _cartItems.clear();
    notifyListeners();
  }

  // TOTAL PRICE
  int get totalPrice {
    return _cartItems.fold(
      0,
          (sum, item) =>
      sum + (item['price'] as int) * (item['quantity'] as int),
    );
  }
}
