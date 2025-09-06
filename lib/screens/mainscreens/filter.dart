import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/screens/mainscreens/myads.dart';
import '../widgets/filter_panel.dart';

class Product {
  final String id;
  final String farmerid;
  final double price;
  final String name;
  final String type;
  final String city;
  final String region;
  final int? sellerActivity;
  final double? sellerRating;

  Product({
    required this.id,
    required this.farmerid,
    required this.price,
    required this.name,
    required this.type,
    required this.city,
    required this.region,
    this.sellerActivity,
    this.sellerRating,
  });

  factory Product.fromFirestore(Map data, String docId) {
    return Product(
      id: docId,
      farmerid: data['farmerid'] ?? '',
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
  State createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
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

  final Color mainBgTop = const Color(0xff232526);
  final Color mainBgBottom = const Color(0xff414345);
  final Color cardBg = const Color(0xfffef9ed);
  final Color accent = const Color(0xfff9a825);

  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _fetchProducts() async {
    try {
      final snapshot = await _productsRef.get();
      final loadedProducts = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map, doc.id))
          .toList();

      setState(() {
        allProducts = loadedProducts;
        searchQuery = '';
        filterType = '';
        filterCity = '';
        filterRegion = '';
        sortBy = '';
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

  Future _refreshProducts() async {
    setState(() {
      isLoading = true;
    });
    await _fetchProducts();
    setState(() {
      searchQuery = '';
      filterType = '';
      filterCity = '';
      filterRegion = '';
      sortBy = '';
      _applyFilters();
    });
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
      _controller.reset();
      _controller.forward();
      _setupAnimations();
    });
  }

  void _setupAnimations() {
    _slideAnimations = [];
    _fadeAnimations = [];
    final count = filteredProducts.length;
    final intervalStep = 1.0 / (count == 0 ? 1 : count);
    for (int i = 0; i < count; i++) {
      final begin = i * intervalStep;
      final end = begin + intervalStep;
      _slideAnimations.add(
          Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _controller,
                  curve: Interval(begin, end, curve: Curves.easeOut))));
      _fadeAnimations.add(Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _controller,
              curve: Interval(begin, end, curve: Curves.easeIn))));
    }
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
              const Text('Filter Products',
                  style: TextStyle(
                      color: Color(0xfff9a825),
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
              const SizedBox(width: 6),
              Icon(Icons.filter_alt_rounded, size: 28, color: accent),
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
                            : AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  _setupAnimations();
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (ctx, i) {
                                        final p = filteredProducts[i];
                                        return SlideTransition(
                                          position: _slideAnimations[i],
                                          child: FadeTransition(
                                            opacity: _fadeAnimations[i],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 8),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: cardBg,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color:
                                                        accent.withOpacity(0.4),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.amberAccent
                                                          .withOpacity(0.13),
                                                      blurRadius: 12,
                                                      offset:
                                                          const Offset(2, 5),
                                                    ),
                                                    const BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 10,
                                                      offset: Offset(3, 3),
                                                    ),
                                                  ],
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.yellow.shade100,
                                                      Colors.orange.shade50,
                                                      cardBg
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.amber.shade50,
                                                    radius: 26,
                                                    child: const Icon(
                                                        Icons.egg_rounded,
                                                        color:
                                                            Color(0xfffbc02d),
                                                        size: 29),
                                                  ),
                                                  title: Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 19,
                                                        color: Colors.black87,
                                                        letterSpacing: .2),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            "Type: ${p.type} • City: ${p.city}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15)),
                                                        Text(
                                                            "Region: ${p.region}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                "Price: \$${p.price}",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .deepOrangeAccent)),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.star,
                                                                    color: Colors
                                                                        .orange,
                                                                    size: 16),
                                                                Text(
                                                                    "${p.sellerRating ?? 'N/A'}",
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .brown)),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Icon(
                                                                    Icons
                                                                        .trending_up,
                                                                    color: Colors
                                                                        .green,
                                                                    size: 16),
                                                                Text(
                                                                    "${p.sellerActivity ?? 'N/A'}",
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .green)),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  trailing: Container(
                                                    decoration: BoxDecoration(
                                                      color: accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: accent
                                                                .withOpacity(
                                                                    0.18),
                                                            blurRadius: 7,
                                                            offset:
                                                                const Offset(
                                                                    0, 3)),
                                                      ],
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 5,
                                                        horizontal: 13),
                                                    child: const Text('Details',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyAdsPage(
                                                          adId: p.id,
                                                          farmerid: p.farmerid,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
