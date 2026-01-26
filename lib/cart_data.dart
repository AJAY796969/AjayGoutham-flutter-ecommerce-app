// cart_data.dart

List<Map<String, dynamic>> cartItems = [];

void addToCart({
  required String name,
  required int price,
  required String image,
}) {
  // Check if item already exists
  final index = cartItems.indexWhere((item) => item['name'] == name);

  if (index != -1) {
    // Increase quantity
    cartItems[index]['quantity'] += 1;
  } else {
    // Add new item
    cartItems.add({
      'name': name,
      'price': price,
      'image': image,
      'quantity': 1,
    });
  }
}

void increaseQuantity(int index) {
  cartItems[index]['quantity'] += 1;
}

void decreaseQuantity(int index) {
  if (cartItems[index]['quantity'] > 1) {
    cartItems[index]['quantity'] -= 1;
  } else {
    cartItems.removeAt(index);
  }
}

int getTotalPrice() {
  int total = 0;
  for (var item in cartItems) {
    total += item['price'] * item['quantity'] as int;
  }
  return total;
}

void clearCart() {
  cartItems.clear();
}
