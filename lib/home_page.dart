import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_page.dart';
import 'cart_page.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'search_page.dart'; // ✅ NEW FILE

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortOption { recommended, priceLow, priceHigh, discountHigh }

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Smartphone',
      'price': 15000,
      'mrp': 18000,
      'discount': 20,
      'image': 'assets/images/phone.png',
      'category': 'Electronics',
    },
    {
      'name': 'Headphones',
      'price': 2500,
      'mrp': 3200,
      'discount': 22,
      'image': 'assets/images/headphones.png',
      'category': 'Accessories',
    },
    {
      'name': 'Laptop',
      'price': 55000,
      'mrp': 65000,
      'discount': 15,
      'image': 'assets/images/laptop.png',
      'category': 'Computers',
    },
    {
      'name': 'Smart Watch',
      'price': 7000,
      'mrp': 9000,
      'discount': 25,
      'image': 'assets/images/watch.png',
      'category': 'Electronics',
    },
  ];

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  final List<Map<String, dynamic>> topCategories = [
    {"title": "Mobiles", "icon": Icons.phone_android},
    {"title": "Audio", "icon": Icons.headphones},
    {"title": "Laptops", "icon": Icons.laptop},
    {"title": "Watches", "icon": Icons.watch},
    {"title": "Deals", "icon": Icons.local_offer},
    {"title": "Fashion", "icon": Icons.checkroom},
  ];

  List<Map<String, dynamic>> filteredProducts = [];
  String selectedCategory = 'All';

  final TextEditingController searchController = TextEditingController();
  int _currentBannerIndex = 0;

  // ✅ Sort & Filter
  SortOption selectedSort = SortOption.recommended;
  int minPrice = 0;
  int maxPrice = 100000;

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);
    _applyAll();
  }

  void _applyAll() {
    List<Map<String, dynamic>> temp = List.from(products);

    // category filter
    if (selectedCategory != "All") {
      temp = temp.where((p) => p['category'] == selectedCategory).toList();
    }

    // price filter
    temp = temp.where((p) {
      final int price = p['price'] ?? 0;
      return price >= minPrice && price <= maxPrice;
    }).toList();

    // search filter
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      temp = temp
          .where((p) => p['name'].toString().toLowerCase().contains(query))
          .toList();
    }

    // sorting
    if (selectedSort == SortOption.priceLow) {
      temp.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (selectedSort == SortOption.priceHigh) {
      temp.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (selectedSort == SortOption.discountHigh) {
      temp.sort((a, b) => _discountPercent(b).compareTo(_discountPercent(a)));
    }

    setState(() => filteredProducts = temp);
  }

  static int _discountPercent(Map<String, dynamic> product) {
    final int price = product['price'] ?? 0;
    final int mrp = product['mrp'] ?? 0;
    if (mrp == 0) return 0;
    return (((mrp - price) / mrp) * 100).round();
  }

  void _filterByCategory(String category) {
    setState(() => selectedCategory = category);
    _applyAll();
  }

  void _searchProducts(String query) {
    _applyAll();
  }

  Widget _categoryChip(String category) {
    final bool isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        selected: isSelected,
        onSelected: (_) => _filterByCategory(category),
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade200),
        elevation: isSelected ? 3 : 1,
        shadowColor: Colors.black12,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }Widget _topCategoryItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title clicked")),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 30),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
  PreferredSizeWidget _premiumAppBar(int cartCount) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "E-Commerce App",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),

      // ✅ ONLY ONE ACTIONS BLOCK
      actions: [
        // 🛒 CART ICON WITH BADGE
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                );
              },
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    cartCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // 🚪 LOGOUT BUTTON
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // AuthWrapper will auto-redirect to LoginPage
          },
        ),
      ],

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF7C3AED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _sortTile("Recommended", SortOption.recommended),
              _sortTile("Price: Low to High", SortOption.priceLow),
              _sortTile("Price: High to Low", SortOption.priceHigh),
              _sortTile("Discount: High to Low", SortOption.discountHigh),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _sortTile(String title, SortOption option) {
    final bool selected = selectedSort == option;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: selected ? const Color(0xFFEEF2FF) : null,
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? const Color(0xFF2563EB) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      onTap: () {
        setState(() => selectedSort = option);
        Navigator.pop(context);
        _applyAll();
      },
    );
  }

  void _openFilterSheet() {
    int localMin = minPrice;
    int localMax = maxPrice;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Min: ₹$localMin",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text("Max: ₹$localMax",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    min: 0,
                    max: 100000,
                    divisions: 20,
                    value: localMin.toDouble(),
                    onChanged: (v) {
                      setLocal(() {
                        localMin = v.toInt();
                        if (localMin > localMax) localMax = localMin;
                      });
                    },
                  ),
                  Slider(
                    min: 0,
                    max: 100000,
                    divisions: 20,
                    value: localMax.toDouble(),
                    onChanged: (v) {
                      setLocal(() {
                        localMax = v.toInt();
                        if (localMax < localMin) localMin = localMax;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              minPrice = 0;
                              maxPrice = 100000;
                            });
                            Navigator.pop(context);
                            _applyAll();
                          },
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              minPrice = localMin;
                              maxPrice = localMax;
                            });
                            Navigator.pop(context);
                            _applyAll();
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }@override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final int cartCount = cart.cartItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _premiumAppBar(cartCount),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // ✅ BANNER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CarouselSlider(
                  items: banners.map((bannerPath) {
                    return Image.asset(
                      bannerPath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: bannerPath == "assets/images/banner2.png"
                          ? Alignment.topCenter
                          : Alignment.center,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 185,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() => _currentBannerIndex = index);
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final selected = _currentBannerIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: selected ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  )
                      : null,
                  color: selected ? null : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // ✅ TOP CATEGORIES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top Categories",
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 95,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: topCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final category = topCategories[index];
                      return _topCategoryItem(
                        category['title'],
                        category['icon'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ✅ CATEGORY CHIPS
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _categoryChip('All'),
                _categoryChip('Electronics'),
                _categoryChip('Accessories'),
                _categoryChip('Computers'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ✅ SEARCH BAR (Premium • Clean • Professional)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                        products: products,
                        selectedCategory: selectedCategory,
                      ),
                    ),
                  );

                  if (result != null && result is String) {
                    searchController.text = result;
                    _applyAll();
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ✅ SORT + FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _openSortSheet,
                    icon: const Icon(Icons.swap_vert, size: 18),
                    label: const Text(
                      "Sort",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text(
                      "Filter",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ PRODUCTS GRID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.64,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final int price = product['price'];
                final int mrp = product['mrp'];
                final int discountPercent = _discountPercent(product);

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          name: product['name'],
                          price: product['price'],
                          image: product['image'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 20,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    product['image'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // ✅ Discount
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF16A34A),
                                        Color(0xFF22C55E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$discountPercent% OFF",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // ✅ Wishlist
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Consumer<WishlistProvider>(
                                  builder: (context, wishlist, child) {
                                    final isFav =
                                    wishlist.isWishlisted(product['name']);

                                    return GestureDetector(
                                      onTap: () {
                                        wishlist.toggleWishlist(product);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isFav
                                                  ? "Removed from Wishlist"
                                                  : "Added to Wishlist ❤️",
                                            ),
                                            duration:
                                            const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                          isFav ? Colors.red : Colors.grey,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFED7AA)),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.star, size: 15, color: Colors.orange),
                                          SizedBox(width: 4),
                                          Text(
                                            "4.5",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 7,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      "₹$price",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                    Text(
                                      "₹$mrp",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    Text(
                                      "$discountPercent% OFF",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}