import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/screens/mainscreens/myads.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/navigation.dart';
import '../Responsive_helper.dart';

List<Map<String, String>> sell = [
  {"image": "assets/images/birds.png", "name": "Broiler"},
  {"image": "assets/images/deshi.png", "name": "Deshi"},
  {"image": "assets/images/egg.png", "name": "Eggs"},
  {"image": "assets/images/eggs.png", "name": "Hatching Eggs"},
  {"image": "assets/images/chick.png", "name": "Chicks"},
  {"image": "assets/images/duck.png", "name": "Ducks"},
];

class RecommendationWidget extends StatefulWidget {
  final String? category;

  const RecommendationWidget({super.key, this.category});

  @override
  State<RecommendationWidget> createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _cardControllers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String getAssetForType(String type) {
    final match = sell.firstWhere(
      (element) => element['name']!.toLowerCase() == type.toLowerCase(),
      orElse: () => {"image": "assets/images/recommend.png"},
    );
    return match['image']!;
  }

  Color _getGradientColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'broiler':
        return const Color(0xFF667eea);
      case 'deshi':
        return const Color(0xFF11998e);
      case 'eggs':
        return const Color(0xFFf093fb);
      case 'hatching eggs':
        return const Color(0xFF4facfe);
      case 'chicks':
        return const Color(0xFFfa709a);
      case 'ducks':
        return const Color(0xFF764ba2);
      default:
        return const Color(0xFF667eea);
    }
  }

  List<Color> _getGradientColorsForType(String type) {
    final baseColor = _getGradientColorForType(type);
    return [baseColor, baseColor.withOpacity(0.7)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('collectionofall');

    if (widget.category != null && widget.category!.isNotEmpty) {
      query = query.where('type', isEqualTo: widget.category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(const Color(0xFF667eea)),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading recommendations...',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.amber.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize card controllers if needed
        while (_cardControllers.length < docs.length) {
          final controller = AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: this,
          );
          _cardControllers.add(controller);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth >= 1200) {
              crossAxisCount = 5;
              childAspectRatio = 0.75;
            } else if (constraints.maxWidth >= 900) {
              crossAxisCount = 4;
              childAspectRatio = 0.70;
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 3;
              childAspectRatio = 0.68;
            } else {
              crossAxisCount = 2;
              childAspectRatio = 0.75;
            }

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final type = data['type'] ?? '';
                    final imageAsset = data['imageUrl'] != null &&
                            data['imageUrl'] != ''
                        ? null
                        : getAssetForType(type);

                    return AnimatedBuilder(
                      animation: _cardControllers[index],
                      builder: (context, child) {
                        final scaleValue = 1.0 + (_cardControllers[index].value * 0.05);
                        return Transform.scale(
                          scale: scaleValue,
                          child: _buildProductCard(
                            context,
                            data,
                            imageAsset,
                            docs[index].id,
                            index,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> data,
    String? imageAsset,
    String docId,
    int index,
  ) {
    final theme = Theme.of(context);
    final type = data['type'] ?? '';
    final gradientColors = _getGradientColorsForType(type);

    return GestureDetector(
      onTap: () {
        NextScreen(
          context,
          MyAdsPage(
            adId: docId,
            farmerid: data['userId'] ?? '',
          ),
        );
      },
      onTapDown: (_) => _cardControllers[index].forward(),
      onTapUp: (_) => _cardControllers[index].reverse(),
      onTapCancel: () => _cardControllers[index].reverse(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
          border: Border.all(
            color: gradientColors.first.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Flexible(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: imageAsset != null
                            ? Image.asset(
                                imageAsset,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gradientColors.first,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Flexible(
                      child: Text(
                        data['name'] ?? 'No Name',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Price and Quantity Row
                    Row(
                      children: [
                        Flexible(
                          child: _buildInfoChip(
                            "৳${data['price']?.toString() ?? '0'}",
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: _buildInfoChip(
                            "${data['quantity']?.toString() ?? '0'}",
                            Icons.inventory_2,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: gradientColors.first,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${data['city'] ?? 'N/A'}, ${data['region'] ?? 'N/A'}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Rating and Activity Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRatingWidget(
                          double.tryParse(
                                  data['sellerRating']?.toString() ?? '0') ??
                              0.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradientColors.first.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: gradientColors.first.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Act: ${data['sellerActivity']?.toString() ?? '0'}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: gradientColors.first,
                            ),
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
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingWidget(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}
