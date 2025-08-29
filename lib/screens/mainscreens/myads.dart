import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/newAuth/add_post_model.dart';
import 'package:poultry_app/newAuth/order/placeorder.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';

import '../../Responsive_helper.dart';

class MyAdsPage extends StatefulWidget {
  final String adId;
  final String farmerid;

  const MyAdsPage({super.key, required this.adId, required this.farmerid});

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> with TickerProviderStateMixin {
  late Future<AdModel> _adFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _adFuture = _fetchAd();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<AdModel> _fetchAd() async {
    try {
      final doc =
      await _firestore.collection('collectionofall').doc(widget.adId).get();
      if (doc.exists) {
        return AdModel.fromMap(doc.data()!, doc.id);
      } else {
        throw Exception('Ad not found');
      }
    } catch (e) {
      throw Exception('Failed to load ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> sell = [
      {"image": "assets/images/birds.png", "name": "Broiler"},
      {"image": "assets/images/deshi.png", "name": "Deshi"},
      {"image": "assets/images/egg.png", "name": "Eggs"},
      {"image": "assets/images/eggs.png", "name": "Hatching Eggs"},
      {"image": "assets/images/chick.png", "name": "Chicks"},
      {"image": "assets/images/duck.png", "name": "Ducks"},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Product Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<AdModel>(
        future: _adFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.1),
                      const Color(0xFF764ba2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF667eea)),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading amazing deals...",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.1), Colors.pink.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.withOpacity(0.1), Colors.amber.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'No product found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final ad = snapshot.data!;
          final isDesktop = ResponsiveHelper.isDesktop(context);

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double imageWidth = isDesktop ? constraints.maxWidth * 0.5 : double.infinity;
                      double imageHeight = isDesktop ? 350 : 220;

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Enhanced Ad Name with Animation
                                  Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF667eea).withOpacity(0.1),
                                            const Color(0xFF764ba2).withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: const Color(0xFF667eea).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        ad.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 32 : 24,
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context).colorScheme.onBackground,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black.withOpacity(0.1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Enhanced Image with Beautiful Frame
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF667eea).withOpacity(0.2),
                                          const Color(0xFF764ba2).withOpacity(0.2),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.3),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: SizedBox(
                                          width: imageWidth,
                                          height: imageHeight,
                                          child: ad.imageUrl != null && ad.imageUrl!.isNotEmpty
                                              ? Image.network(
                                            ad.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              final asset = sell.firstWhere(
                                                    (element) =>
                                                element['type']!.toLowerCase() ==
                                                    ad.type.toLowerCase(),
                                                orElse: () =>
                                                {"image": "assets/images/broiler.png"},
                                              )['image']!;
                                              return Image.asset(
                                                asset,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                              : Image.asset(
                                            sell.firstWhere(
                                                  (element) =>
                                              element['name']!.toLowerCase() ==
                                                  ad.type.toLowerCase(),
                                              orElse: () =>
                                              {"image": "assets/images/broiler.png"},
                                            )['image']!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Enhanced Info Card with Beautiful Design
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.surface,
                                          Theme.of(context).colorScheme.surface.withOpacity(0.8),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF667eea).withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: const Color(0xFF667eea).withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header with icon
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "Product Information",
                                                style: TextStyle(
                                                  fontSize: isDesktop ? 20 : 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context).colorScheme.onBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          
                                          _buildEnhancedDetailRow("Type", ad.type, context, Icons.category),
                                          const SizedBox(height: 16),
                                          _buildEnhancedDetailRow("Description", ad.description, context, Icons.description),
                                          const SizedBox(height: 16),
                                          _buildEnhancedDetailRow("Quantity (unit)", ad.quantity.toString(), context, Icons.inventory),
                                          const SizedBox(height: 16),
                                          _buildEnhancedDetailRow("Price (per unit)", "৳${ad.price}", context, Icons.attach_money),
                                          const SizedBox(height: 16),
                                          _buildEnhancedDetailRow("Location", "${ad.city}, ${ad.region}", context, Icons.location_on),
                                          const SizedBox(height: 20),
                                          
                                          // Rating and Activity Row with Enhanced Design
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF667eea).withOpacity(0.1),
                                                  const Color(0xFF764ba2).withOpacity(0.1),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: const Color(0xFF667eea).withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: _buildMetricCard(
                                                    "Seller Rating", 
                                                    ad.sellerRating.toString(), 
                                                    Icons.star, 
                                                    Colors.amber,
                                                    isDesktop
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: _buildMetricCard(
                                                    "Activity", 
                                                    ad.sellerActivity.toString(), 
                                                    Icons.trending_up, 
                                                    Colors.green,
                                                    isDesktop
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),

                          // Enhanced Action Buttons
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedButton(
                                    "Order Now",
                                    Icons.shopping_cart,
                                    [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                                    () {
                                      NextScreen(
                                        context,
                                        OrderNow(
                                          orderId: ad.id,
                                          title: ad.type,
                                          farmerId: widget.farmerid,
                                        ),
                                      );
                                    },
                                    isDesktop,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEnhancedButton(
                                    "Call Seller",
                                    Icons.phone,
                                    [const Color(0xFF667eea), const Color(0xFF764ba2)],
                                    () {},
                                    isDesktop,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedDetailRow(String title, String value, BuildContext context, IconData icon) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 13,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(
    String text,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onPressed,
    bool isDesktop,
  ) {
    return Container(
      height: isDesktop ? 60 : 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}