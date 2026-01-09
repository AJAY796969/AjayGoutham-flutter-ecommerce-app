import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'order_history_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'UPI';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL AMOUNT
            Text(
              "Total Amount: ₹${cart.totalPrice}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // PAYMENT OPTIONS
            RadioListTile(
              value: 'UPI',
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() => selectedPayment = value!);
              },
              title: const Text("UPI (Google Pay / PhonePe)"),
            ),
            RadioListTile(
              value: 'Card',
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() => selectedPayment = value!);
              },
              title: const Text("Credit / Debit Card"),
            ),
            RadioListTile(
              value: 'COD',
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() => selectedPayment = value!);
              },
              title: const Text("Cash on Delivery"),
            ),

            const Spacer(),

            // PAY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  cart.placeOrder();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order placed successfully 🎉"),
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryPage(),
                    ),
                        (route) => false,
                  );
                },
                child: Text(
                  "Pay ₹${cart.totalPrice}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
