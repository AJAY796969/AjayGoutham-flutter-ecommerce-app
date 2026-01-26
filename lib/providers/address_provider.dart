import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> savedAddresses = [];

  AddressProvider() {
    loadAddresses(); // ✅ auto load when app starts
  }

  // ✅ Add Address
  Future<void> addAddress(AddressModel address) async {
    savedAddresses.add(address);
    await saveAddresses();
    notifyListeners();
  }

  // ✅ Remove Address
  Future<void> removeAddress(int index) async {
    if (index < 0 || index >= savedAddresses.length) return;
    savedAddresses.removeAt(index);
    await saveAddresses();
    notifyListeners();
  }

  // ✅ Save Addresses in SharedPreferences
  Future<void> saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> list =
    savedAddresses.map((a) => a.toMap()).toList();

    await prefs.setString("savedAddresses", jsonEncode(list));
  }

  // ✅ Load Addresses from SharedPreferences
  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("savedAddresses");

    if (data != null) {
      final decoded = jsonDecode(data) as List<dynamic>;

      savedAddresses.clear();
      savedAddresses.addAll(
        decoded.map((e) => AddressModel.fromMap(Map<String, dynamic>.from(e))),
      );
      notifyListeners();
    }
  }

  // ✅ Clear All Addresses (optional)
  Future<void> clearAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("savedAddresses");
    savedAddresses.clear();
    notifyListeners();
  }
}