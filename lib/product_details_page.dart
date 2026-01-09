import 'package:flutter/material.dart';
import 'cart_data.dart';

class ProductDetailsPage extends StatelessWidget {
  final String name;
  final int price;
  final String image;

  const ProductDetailsPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Center(
              child: Image.asset(
                image,
                height: 240,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // PRODUCT NAME
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // PRICE
            Text(
              "₹$price",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // RATING
            Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 18),
                SizedBox(width: 4),
                Text("4.5", style: TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            const Text(
              "This is a high quality product with excellent performance and durability. "
                  "Perfect for everyday use and highly recommended by users.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const Spacer(),

            // ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  cartItems.add({
                    'name': name,
                    'price': price,
                    'image': image,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Added to cart"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  "ADD TO CART",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

