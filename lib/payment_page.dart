import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_success_page.dart';

import 'order_history_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'UPI';

  final TextEditingController couponController = TextEditingController();

  // ✅ Saved Addresses
  List<Map<String, dynamic>> savedAddresses = [];
  int? selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    loadSavedAddresses();
  }

  Future<void> loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("savedAddresses");

    if (saved != null) {
      final decoded = jsonDecode(saved) as List<dynamic>;
      setState(() {
        savedAddresses =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });

      // ✅ Auto select first address
      if (savedAddresses.isNotEmpty) {
        setState(() {
          selectedAddressIndex = 0;
        });

        // ✅ Save into provider also
        final cart = context.read<CartProvider>();
        cart.setSelectedAddress(savedAddresses[0]);
      }
    } else {
      setState(() {
        savedAddresses = [];
        selectedAddressIndex = null;
      });
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  // ✅ Premium Section Title
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ✅ Premium Card Wrapper
  Widget _premiumCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF9FBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  // ✅ Address Card
  Widget _addressCard({
    required Map<String, dynamic> address,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color:
          selected ? const Color(0xFF2563EB).withOpacity(0.10) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color:
                selected ? const Color(0xFF2563EB) : Colors.grey.shade500,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address["name"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${address["phone"] ?? ""}",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${address["address"] ?? ""}",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${address["city"] ?? ""}, ${address["state"] ?? ""} - ${address["pincode"] ?? ""}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Premium Payment Radio Tile
  Widget _premiumRadioTile({
    required String value,
    required String groupValue,
    required String title,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final bool selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? const Color(0xFF7C3AED).withOpacity(0.10)
              : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF7C3AED) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF7C3AED).withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? const Color(0xFF7C3AED) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? const Color(0xFF7C3AED) : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }@override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final int finalTotal =
    (cart.totalPrice - cart.discountAmount).clamp(0, cart.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      // ✅ Body scroll + Fixed Bottom Pay Button
      body: Stack(
          children: [
      SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // ✅ PRICE SUMMARY
      _premiumCard(
      child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionTitle("Price Summary", Icons.receipt_long),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${cart.totalPrice}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discount",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "-₹${cart.discountAmount}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const Divider(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Final Total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹$finalTotal",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    ),

    const SizedBox(height: 16),

    // ✅ ADDRESS SELECTION
    _premiumCard(
    child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _sectionTitle("Choose Delivery Address", Icons.location_on),
    const SizedBox(height: 12),

    if (savedAddresses.isEmpty)
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "No saved address found ❌",
    style: TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 6),
    Text(
    "Go to Profile → Saved Address and add one.",
    style: TextStyle(
    fontSize: 13,
    color: Colors.grey.shade700,
    ),
    ),
    const SizedBox(height: 12),
    SizedBox(
    height: 48,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2563EB),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    ),
    ),
    onPressed: () async {
    await loadSavedAddresses();
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text("Refreshed Addresses ✅"),
    ),
    );
    },
    child: const Text(
    "Refresh",
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    ),
    ],
    )
    else
    Column(
    children: List.generate(savedAddresses.length, (index) {
    final address = savedAddresses[index];
    final bool selected = selectedAddressIndex == index;

    return _addressCard(
    address: address,
    selected: selected,
    onTap: () {
    setState(() {
    selectedAddressIndex = index;
    });

    cart.setSelectedAddress(address);

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text("Address Selected ✅"),
    duration: Duration(seconds: 1),
    ),
    );
    },
    );
    }),
    ),
    ],
    ),
    ),
    ),const SizedBox(height: 16),

            // ✅ COUPON
            _premiumCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Apply Coupon", Icons.local_offer_outlined),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: couponController,
                            decoration: InputDecoration(
                              hintText:
                              "Enter code (SAVE50 / SAVE10 / FREESHIP)",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              final code =
                              couponController.text.trim().toUpperCase();

                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Enter coupon code first"),
                                  ),
                                );
                                return;
                              }

                              final bool ok = cart.applyCoupon(code);

                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid coupon ❌"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                    Text("Coupon Applied ✅ ($code)"),
                                  ),
                                );
                              }

                              couponController.clear();
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (cart.appliedCouponCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Applied: ${cart.appliedCouponCode}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                cart.removeCoupon();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Coupon Removed ✅"),
                                  ),
                                );
                              },
                              child: const Text(
                                "Remove",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ PAYMENT METHOD
            _premiumCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                        "Select Payment Method", Icons.payments_outlined),
                    const SizedBox(height: 12),

                    _premiumRadioTile(
                      value: 'UPI',
                      groupValue: selectedPayment,
                      title: "UPI (Google Pay / PhonePe)",
                      icon: Icons.qr_code_2,
                      onChanged: (value) {
                        setState(() => selectedPayment = value!);
                      },
                    ),

                    _premiumRadioTile(
                      value: 'Card',
                      groupValue: selectedPayment,
                      title: "Credit / Debit Card",
                      icon: Icons.credit_card,
                      onChanged: (value) {
                        setState(() => selectedPayment = value!);
                      },
                    ),

                    _premiumRadioTile(
                      value: 'COD',
                      groupValue: selectedPayment,
                      title: "Cash on Delivery",
                      icon: Icons.delivery_dining,
                      onChanged: (value) {
                        setState(() => selectedPayment = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
      ),
      ),

            // ✅ FIXED BOTTOM PAY BAR
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 22,
                        offset: const Offset(0, -8),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount Payable",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹$finalTotal",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 54,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (savedAddresses.isNotEmpty && selectedAddressIndex == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please choose delivery address first 📍"),
                                ),
                              );
                              return;
                            }

                            if (savedAddresses.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Add address first (Profile → Saved Address)",
                                  ),
                                ),
                              );
                              return;
                            }

                            cart.placeOrder();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Order placed successfully 🎉 Paid ₹$finalTotal",
                                ),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>  OrderSuccessPage(
                                  amount: finalTotal,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF16A34A),
                                  Color(0xFF22C55E),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Pay Now",
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}