List<Map<String, dynamic>> cartItems = [];

void addToCart(Map<String, dynamic> product) {
  for (var item in cartItems) {
    if (item['name'] == product['name']) {
      item['qty'] += 1;
      return;
    }
  }

  cartItems.add({
    'name': product['name'],
    'price': product['price'],
    'icon': product['icon'],
    'qty': 1,
  });
}

int getTotalPrice() {
  int total = 0;
  for (var item in cartItems) {
    total += (item['price'] as int) * (item['qty'] as int);
  }
  return total;
}
