import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';

import 'order_details_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<CartProvider>().orderHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Order History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: orders.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 46,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "No orders yet 📦",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Place your first order and it will appear here",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          final date = DateTime.parse(order['date']);

          final total = (order['total'] ?? 0) as int;

          // ✅ NEW: Coupon + Discount + Final Total
          final int discount = (order['discount'] ?? 0) as int;
          final String couponCode = (order['couponCode'] ?? "") as String;

          // ✅ if finalTotal exists use it, else calculate fallback
          final int finalTotal =
          (order['finalTotal'] ?? (total - discount)) as int;

          final items = (order['items'] as List).cast<Map<String, dynamic>>();

          // ✅ Safe image handling
          final String? firstImage = items.isNotEmpty ? items[0]['image'] : null;

          // ✅ NEW: Address Preview
          final Map<String, dynamic>? deliveryAddress =
          order['deliveryAddress'] != null
              ? Map<String, dynamic>.from(order['deliveryAddress'])
              : null;

          String addressPreviewText = "";
          if (deliveryAddress != null) {
            final String name = deliveryAddress["name"] ?? "";
            final String city = deliveryAddress["city"] ?? "";
            final String state = deliveryAddress["state"] ?? "";
            final String pincode = deliveryAddress["pincode"] ?? "";

            addressPreviewText = "$name, $city, $state - $pincode";
          }

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(
                    order: order,
                    orderIndex: index,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
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
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ LEFT: IMAGE / ICON
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: firstImage != null
                          ? Image.asset(
                        firstImage,
                        fit: BoxFit.contain,
                      )
                          : const Icon(
                        Icons.shopping_bag,
                        color: Color(0xFF2563EB),
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ✅ MIDDLE: DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order on ${date.day}/${date.month}/${date.year}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Items: ${items.length}",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ✅ COUPON CHIP
                          if (couponCode.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_offer,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "Coupon: $couponCode  •  Saved ₹$discount",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ✅ Address preview
                          if (deliveryAddress != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF2563EB).withOpacity(0.20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      addressPreviewText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ✅ RIGHT: PRICE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "₹$finalTotal",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            "-₹$discount",
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      ],
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
}