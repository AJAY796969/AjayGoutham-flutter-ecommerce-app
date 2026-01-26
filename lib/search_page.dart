import 'package:flutter/material.dart';
import 'product_details_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String selectedCategory;

  const SearchPage({
    super.key,
    required this.products,
    required this.selectedCategory,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  final List<String> recent = ["Smartphone", "Laptop", "Headphones"];

  @override
  void initState() {
    super.initState();
    results = List.from(widget.products);
  }

  void _search(String query) {
    final q = query.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        results = List.from(widget.products);
      } else {
        results = widget.products.where((p) {
          final matchesSearch =
          p['name'].toString().toLowerCase().contains(q);

          final matchesCategory = widget.selectedCategory == "All"
              ? true
              : p['category'] == widget.selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ✅ PREMIUM SEARCH APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: searchController,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    _search("");
                  },
                )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ✅ RECENT SEARCHES
          if (searchController.text.trim().isEmpty) ...[
            const Text(
              "Recent Searches",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recent.map((r) {
                return ActionChip(
                  elevation: 2,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  label: Text(
                    r,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    searchController.text = r;
                    _search(r);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              "Popular Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ✅ EMPTY STATE
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "No products found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Try searching with different keywords",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )

          // ✅ RESULTS LIST (PREMIUM CARDS)
          else
            ...results.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          name: p['name'],
                          price: p['price'],
                          image: p['image'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // IMAGE
                        Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Image.asset(
                            p['image'],
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p['category'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // PRICE
                        Text(
                          "₹${p['price']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}