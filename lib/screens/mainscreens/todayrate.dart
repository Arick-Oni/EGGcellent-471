import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/otherwidgets.dart';
import '../../Responsive_helper.dart';

class TodayRatePage extends StatefulWidget {
  const TodayRatePage({super.key});

  @override
  State<TodayRatePage> createState() => _TodayRatePageState();
}

class _TodayRatePageState extends State<TodayRatePage>
    with TickerProviderStateMixin {
  final List<String> states = ["Dhaka", "Savar", "Kishoreganj", "Chittagong"];
  final List<Map<String, String>> category = [
    {"image": "assets/images/hen.png", "title": "Broiler Chicken\nRates"},
    {"image": "assets/images/bdeshi.png", "title": "Deshi Chicken\nRates"},
    {"image": "assets/images/begg.png", "title": "Egg\nRates"},
    {"image": "assets/images/bch.png", "title": "One Day Chicks-\nBroiler"},
    {"image": "assets/images/cd.png", "title": "One Day Chicks-\nDeshi"},
    {"image": "assets/images/be.png", "title": "Hatching Egg\nRates"},
  ];
  int currentIndex = 0;
  String? selectedState;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced dark mode colors with gradients
    final bgColor = Colors.grey[900];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: const GeneralAppBar(title: "Today's Rates"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: ResponsiveHelper.responsiveLayout(
          context: context,
          mobile: _buildMobileTabletLayout(context),
          tablet: _buildMobileTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileTabletLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Enhanced category selection with shimmer effect
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[800]!.withOpacity(0.3),
                      Colors.transparent,
                      Colors.grey[800]!.withOpacity(0.3),
                    ],
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => currentIndex = index);
                        _slideController.reset();
                        _slideController.forward();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: screenWidth * 0.28,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth * 0.22,
                              height: screenWidth * 0.22,
                              decoration: BoxDecoration(
                                gradient: index == currentIndex
                                    ? LinearGradient(
                                        colors: [
                                          yellow,
                                          yellow.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey[800]!,
                                          Colors.grey[750]!,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: index == currentIndex
                                    ? [
                                        BoxShadow(
                                          color: yellow.withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                category[index]['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: screenWidth * 0.26,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                category[index]['title']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: index == currentIndex 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: index == currentIndex 
                                      ? Colors.white 
                                      : Colors.white70,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),
          
          // Enhanced dropdown section
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[800]!.withOpacity(0.7),
                    Colors.grey[850]!.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Select Location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  CustomDropdown(
                    hint: "Choose your state",
                    list: states,
                    height: 50,
                    textStyle: bodyText14normal(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: yellow.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: yellow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Broiler Chicken Rate per kg",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildEnhancedRatesList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[800]!.withOpacity(0.7),
                  Colors.grey[850]!.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() => currentIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  gradient: index == currentIndex
                                      ? LinearGradient(
                                          colors: [yellow, yellow.withOpacity(0.8)],
                                        )
                                      : LinearGradient(
                                          colors: [Colors.grey[800]!, Colors.grey[750]!],
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: index == currentIndex
                                      ? [
                                          BoxShadow(
                                            color: yellow.withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 3,
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                ),
                                padding: const EdgeInsets.all(15),
                                child: Image.asset(
                                  category[index]['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                category[index]['title']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: index == currentIndex 
                                      ? Colors.white 
                                      : Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                CustomDropdown(
                  hint: "Select State",
                  list: states,
                  height: 50,
                  textStyle: bodyText14normal(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _buildEnhancedRatesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedRatesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[800]!.withOpacity(0.8),
                  Colors.grey[850]!.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_city,
                          color: yellow,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Dhaka",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "LIVE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Today",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "190 Tk/kg",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Yesterday",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "--",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}