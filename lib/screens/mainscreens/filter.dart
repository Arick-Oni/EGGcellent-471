import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/filter_panel.dart';

class Product {
  final double price;
  final String name;
  final String type;
  final String city;
  final String region;
  final int? sellerActivity;
  final double? sellerRating;

  Product({
    required this.price,
    required this.name,
    required this.type,
    required this.city,
    required this.region,
    this.sellerActivity,
    this.sellerRating,
  });

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      price: data['price'] is num
          ? (data['price'] as num).toDouble()
          : double.tryParse(data['price'].toString()) ?? 0.0,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      sellerActivity: data['sellerActivity'] == null
          ? null
          : (data['sellerActivity'] is num
              ? (data['sellerActivity'] as num).toInt()
              : int.tryParse(data['sellerActivity'].toString())),
      sellerRating: data['sellerRating'] == null
          ? null
          : (data['sellerRating'] is num
              ? (data['sellerRating'] as num).toDouble()
              : double.tryParse(data['sellerRating'].toString())),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('collectionofall');

  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  String searchQuery = '';
  String filterType = '';
  String filterRegion = '';
  String filterCity = '';
  String sortBy = '';

  // Brand Colors for EggCellent (you can tune!)
  final Color mainBgTop = const Color(0xff232526);
  final Color mainBgBottom = const Color(0xff414345);
  final Color cardBg = const Color(0xfffef9ed);
  final Color accent = const Color(0xfff9a825);

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _productsRef.get();
      final loadedProducts = snapshot.docs
          .map((doc) =>
              Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        allProducts = loadedProducts;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load products: $e';
      });
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      isLoading = true;
    });
    await _fetchProducts();
  }

  void _applyFilters() {
    final q = searchQuery.toLowerCase();
    List<Product> tempList = allProducts.where((product) {
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(q) ||
          product.type.toLowerCase().contains(q) ||
          product.city.toLowerCase().contains(q) ||
          product.region.toLowerCase().contains(q) ||
          product.price.toString().contains(searchQuery) ||
          (product.sellerRating?.toString() ?? '').contains(searchQuery) ||
          (product.sellerActivity?.toString() ?? '').contains(searchQuery);

      final matchesType = filterType.isEmpty ||
          product.type.toLowerCase() == filterType.toLowerCase();

      final matchesRegion = filterRegion.isEmpty ||
          product.region.toLowerCase().contains(filterRegion.toLowerCase());

      final matchesCity = filterCity.isEmpty ||
          product.city.toLowerCase().contains(filterCity.toLowerCase());

      return matchesSearch && matchesType && matchesRegion && matchesCity;
    }).toList();

    if (sortBy == "price") {
      tempList.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == "rating") {
      tempList
          .sort((a, b) => (b.sellerRating ?? 0).compareTo(a.sellerRating ?? 0));
    } else if (sortBy == "activity") {
      tempList.sort(
          (a, b) => (b.sellerActivity ?? 0).compareTo(a.sellerActivity ?? 0));
    }

    setState(() {
      filteredProducts = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [mainBgTop, mainBgBottom],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Row(
            children: [
              const Text('EggCellent',
                  style: TextStyle(
                      color: Color(0xfff9a825),
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
              const SizedBox(width: 6),
              Text('🐣', style: TextStyle(fontSize: 24, color: accent)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xfff9a825)),
                tooltip: 'Reload Products',
                onPressed: _refreshProducts,
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xfff9a825)))
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage,
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: accent,
                    onRefresh: _refreshProducts,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(14),
                            shadowColor: accent.withOpacity(0.36),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText:
                                    'Search by name, type, city, region, price',
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500),
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xfff9a825)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 10),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  searchQuery = val;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FilterPanel(
                            onTypeChanged: (val) {
                              setState(() {
                                filterType = val;
                                _applyFilters();
                              });
                            },
                            onCityChanged: (val) {
                              setState(() {
                                filterCity = val;
                                _applyFilters();
                              });
                            },
                            onRegionChanged: (val) {
                              setState(() {
                                filterRegion = val;
                                _applyFilters();
                              });
                            },
                            onSortChanged: (val) {
                              setState(() {
                                sortBy = val;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                        const Divider(thickness: 1, color: Color(0xfff9a825)),
                        filteredProducts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(28),
                                child: Center(
                                  child: Text(
                                    'No products found for your criteria.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredProducts.length,
                                itemBuilder: (ctx, i) {
                                  final p = filteredProducts[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: accent.withOpacity(0.35),
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 7,
                                            offset: Offset(3, 3),
                                          )
                                        ],
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.egg_rounded,
                                            color: Color(0xfffbc02d), size: 32),
                                        title: Text(
                                          p.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.black87),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            "City: ${p.city}\n"
                                            "Type: ${p.type}\n"
                                            "Region: ${p.region}\n"
                                            "Price: \$${p.price}\n"
                                            "Rating: ${p.sellerRating ?? 'N/A'}   •   Activity: ${p.sellerActivity ?? 'N/A'}",
                                            style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
