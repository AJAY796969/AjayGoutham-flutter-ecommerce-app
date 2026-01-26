import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> cartItems = [];
  final List<Map<String, dynamic>> orderHistory = [];

  String appliedCouponCode = "";
  int discountAmount = 0;

  // ✅ NEW: Selected Address during checkout
  Map<String, dynamic>? selectedAddress;

  CartProvider() {
    loadOrders(); // ✅ Load saved orders on app start
  }

  // ✅ Add item to cart
  void addItem(Map<String, dynamic> product) {
    final index = cartItems.indexWhere(
          (item) => item['name'] == product['name'],
    );

    if (index != -1) {
      cartItems[index]['quantity']++;
    } else {
      cartItems.add({
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': 1,
      });
    }

    notifyListeners();
  }

  void increaseQuantity(int index) {
    cartItems[index]['quantity']++;

    // ✅ Recalculate discount if coupon already applied
    if (appliedCouponCode.isNotEmpty) {
      _recalculateDiscount();
    }

    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity']--;
    } else {
      cartItems.removeAt(index);
    }

    // ✅ Recalculate discount if coupon already applied
    if (appliedCouponCode.isNotEmpty) {
      _recalculateDiscount();
    }

    notifyListeners();
  }

  int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  // ✅ Final total after coupon
  int get finalTotal {
    final int total = totalPrice;
    final int finalValue = total - discountAmount;

    // never negative
    return finalValue < 0 ? 0 : finalValue;
  }

  // ---------------------------------------------------------
  // ✅ CHECKOUT ADDRESS (Feature)
  // ---------------------------------------------------------

  void setSelectedAddress(Map<String, dynamic> address) {
    selectedAddress = address;
    notifyListeners();
  }

  void clearSelectedAddress() {
    selectedAddress = null;
    notifyListeners();
  }

  // ---------------------------------------------------------
  // ✅ COUPON / PROMO CODE SYSTEM (Feature B)
  // ---------------------------------------------------------

  // ✅ Apply Coupon
  bool applyCoupon(String code) {
    final enteredCode = code.trim().toUpperCase();

    if (enteredCode.isEmpty) return false;

    // ✅ Example coupon rules
    // You can add more coupons here later
    if (enteredCode == "SAVE50") {
      appliedCouponCode = enteredCode;

      // flat ₹50 off (only if total >= 500)
      if (totalPrice >= 500) {
        discountAmount = 50;
      } else {
        discountAmount = 0;
      }

      notifyListeners();
      return true;
    }

    if (enteredCode == "SAVE10") {
      appliedCouponCode = enteredCode;

      // 10% off (max 500)
      final tenPercent = (totalPrice * 0.10).round();
      discountAmount = tenPercent > 500 ? 500 : tenPercent;

      notifyListeners();
      return true;
    }

    if (enteredCode == "FREESHIP") {
      appliedCouponCode = enteredCode;

      // Example: just ₹30 off as "shipping"
      discountAmount = 30;

      notifyListeners();
      return true;
    }

    // ❌ Invalid coupon
    appliedCouponCode = "";
    discountAmount = 0;
    notifyListeners();
    return false;
  }

  // ✅ Apply coupon
  void setCoupon(String code, int discount) {
    appliedCouponCode = code;
    discountAmount = discount;
    notifyListeners();
  }

  // ✅ Remove coupon
  void removeCoupon() {
    appliedCouponCode = "";
    discountAmount = 0;
    notifyListeners();
  }

  // ✅ If cart changes, update discount automatically
  void _recalculateDiscount() {
    if (appliedCouponCode.isEmpty) return;

    // just re-apply same code logic
    applyCoupon(appliedCouponCode);
  }

  // ---------------------------------------------------------
  // ✅ ORDER SYSTEM
  // ---------------------------------------------------------

  // ✅ Place order + Save permanently
  void placeOrder() {
    if (cartItems.isEmpty) return;

    orderHistory.insert(0, {
      'orderId': "ORD${DateTime.now().millisecondsSinceEpoch}",
      'date': DateTime.now().toIso8601String(), // ✅ store as String
      'total': totalPrice,
      'discount': discountAmount, // ✅ Added
      'couponCode': appliedCouponCode, // ✅ Added
      'finalTotal': finalTotal, // ✅ Added
      'statusIndex': 0,
      'refundStatusIndex': -1, // -1 = no refund


      // ✅ NEW: SAVE DELIVERY ADDRESS WITH ORDER
      'deliveryAddress': selectedAddress,

      'items': cartItems.map((item) {
        return {
          'name': item['name'],
          'price': item['price'],
          'image': item['image'],
          'quantity': item['quantity'],
        };
      }).toList(),
    });

    cartItems.clear();

    // ✅ Reset coupon after ordering
    appliedCouponCode = "";
    discountAmount = 0;

    // ✅ Reset selected address after order
    selectedAddress = null;

    saveOrders(); // ✅ save in sharedpref
    notifyListeners();
  }

  // ✅ Update order status + Save
  void updateOrderStatus(int orderIndex, int newStatusIndex) {
    if (orderIndex < 0 || orderIndex >= orderHistory.length) return;

    orderHistory[orderIndex]['statusIndex'] = newStatusIndex;

    saveOrders(); // ✅ save after update
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();

    // ✅ Reset coupon if cart cleared
    appliedCouponCode = "";
    discountAmount = 0;

    // ✅ Reset selected address if cart cleared
    selectedAddress = null;

    notifyListeners();
  }

  // ---------------------------------------------------------
  // ✅ SAVE + LOAD ORDER HISTORY (PERMANENT STORAGE)
  // ---------------------------------------------------------

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(orderHistory);
    await prefs.setString("orderHistory", ordersJson);
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString("orderHistory");

    if (ordersJson != null) {
      final decoded = jsonDecode(ordersJson) as List<dynamic>;

      orderHistory.clear();
      orderHistory.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));

      notifyListeners();
    }
  }

  // ✅ Optional: Clear orders (if you want later)
  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("orderHistory");

    orderHistory.clear();
    notifyListeners();
  }
  // ---------------------------------------------------------
// ✅ REORDER FEATURE
// ---------------------------------------------------------

  void reorderItems(List<Map<String, dynamic>> items) {
    cartItems.clear();

    for (var item in items) {
      cartItems.add({
        'name': item['name'],
        'price': item['price'],
        'image': item['image'],
        'quantity': item['quantity'],
      });
    }

    // reset coupon & address
    appliedCouponCode = "";
    discountAmount = 0;
    selectedAddress = null;

    notifyListeners();
  }
}