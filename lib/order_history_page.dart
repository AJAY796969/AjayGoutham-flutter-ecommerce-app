import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<CartProvider>().orderHistory;

    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: orders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final items =
          order['items'] as List<Map<String, dynamic>>;
          final date = order['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(12),
            child: ExpansionTile(
              title: Text(
                "Order on ${date.day}/${date.month}/${date.year}",
              ),
              children: items.map((item) {
                return ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['name'] as String),
                  trailing: Text("₹${item['price']}"),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
