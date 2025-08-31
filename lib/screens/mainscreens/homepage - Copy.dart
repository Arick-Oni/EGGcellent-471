import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/order/editorderedproduct.dart';
import 'package:poultry_app/newAuth/order/trackorder.dart';
import 'package:poultry_app/screens/mainscreens/filter.dart';
import 'package:poultry_app/screens/mainscreens/manual_controls_page.dart';
import 'package:poultry_app/screens/mainscreens/postad.dart';
import 'package:poultry_app/screens/mainscreens/todayrate.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/recommendationwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poultry_app/screens/mainscreens/live_monitoring_page.dart';
import 'package:poultry_app/screens/mainscreens/ESP32CameraStreamPage.dart';
import '../../Responsive_helper.dart';
import 'package:poultry_app/screens/mainscreens/automation_settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool? isBuyerLoggedIn;
  String? selectedCategory;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadBuyerLoginStatus();
    selectedCategory = null;

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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

  Future<void> _loadBuyerLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isbuyerLogin') ?? false;
    setState(() {
      isBuyerLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: GeneralAppBar(),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Section with Gradient Background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade900,
                            Colors.grey.shade800.withOpacity(0.8),
                            Colors.grey.shade900,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Animated App title with glow effect
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                          Color(0xFFFF6B35),
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        "EggCellent 🐣",
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(2, 2),
                                              blurRadius: 8,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Subtitle with animation
                            Text(
                              "Your Premium Poultry Marketplace",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Enhanced Action Buttons Grid
                            _buildActionButtonsGrid(),

                            const SizedBox(height: 32),

                            // Enhanced Hero Banner
                            if (isBuyerLoggedIn != false)
                              _buildEnhancedHeroBanner(),

                            const SizedBox(height: 32),

                            // Recommendations Section Header
                            if (isBuyerLoggedIn != false) _buildSectionHeader(),
                          ],
                        ),
                      ),
                    ),

                    // Recommendations with enhanced styling
                    if (isBuyerLoggedIn != false)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade800.withOpacity(0.3),
                              Colors.grey.shade900,
                            ],
                          ),
                        ),
                        child: SizedBox(
                          height: 600,
                          child:
                              RecommendationWidget(category: selectedCategory),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtonsGrid() {
    final buttons = <Map<String, dynamic>>[];

    buttons.add({
      'text': "Today's Rate",
      'icon': Icons.trending_up,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
      'onPressed': () => NextScreen(context, TodayRatePage()),
    });

    if (isBuyerLoggedIn != true) {
      buttons.add({
        'text': "Sell",
        'icon': Icons.sell,
        'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        'onPressed': () => NextScreen(context, PostAdPage()),
      });
    }

    if (isBuyerLoggedIn == true) {
      buttons.addAll([
        {
          'text': "Track Order",
          'icon': Icons.local_shipping,
          'gradient': [
            const Color(0xFFf093fb),
            const Color.fromARGB(255, 190, 15, 115)
          ],
          'onPressed': () => NextScreen(context, Trackorder()),
        },
        {
          'text': "Filter",
          'icon': Icons.filter_list,
          'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
          'onPressed': () => NextScreen(context, FilterScreen()),
        },
      ]);
    }

    if (isBuyerLoggedIn != true) {
      buttons.add({
        'text': "Ordered Products",
        'icon': Icons.shopping_bag,
        'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
        'onPressed': () => NextScreen(context, Editorderedproduct()),
      });
      buttons.add({
        'text': "Automation Settings",
        'icon': Icons.settings,
        'gradient': [
          const Color.fromARGB(255, 8, 224, 55),
          const Color(0xFFfee140)
        ],
        'onPressed': () => NextScreen(context, const AutomationSettings()),
      });
      // NEW: Live Monitoring button
      buttons.add({
        'text': "Live Monitoring",
        'icon': Icons.monitor_heart, // or Icons.sensors
        'gradient': [const Color(0xFF00b09b), const Color(0xFF96c93d)],
        'onPressed': () => NextScreen(context, const LiveMonitoringPage()),
      });
      buttons.add({
        'text': "Manual Control",
        'icon': Icons.monitor_heart, // or Icons.sensors
        'gradient': [
          const Color.fromARGB(255, 97, 176, 0),
          const Color(0xFF96c93d)
        ],
        'onPressed': () => NextScreen(
            context,
            ManualControlsPage(
                selectedCoop: 'coop1')), // Update with the appropriate coop
      });
      buttons.add({
        'text': "Camera Stream",
        'icon': Icons.videocam, // or Icons.camera_alt, Icons.video_camera_back
        'gradient': [
          const Color(0xFF667eea),
          const Color(0xFF764ba2)
        ], // Purple-blue gradient
        'onPressed': () => NextScreen(context, const ESP32CameraStreamPage()),
      });
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: buttons.map((button) {
        return _buildEnhancedActionButton(
          button['text'],
          button['icon'],
          button['gradient'],
          button['onPressed'],
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedActionButton(
    String text,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(
          minWidth: 140,
          maxWidth: 160,
          minHeight: 60,
          maxHeight: 70,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPressed,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Color.fromARGB(255, 5, 5, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeroBanner() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.orange.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.isDesktop(context)
                        ? 600
                        : double.infinity,
                    maxHeight: ResponsiveHelper.isDesktop(context) ? 280 : 200,
                  ),
                  child: Image.asset(
                    "assets/images/happy.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Overlay gradient for better text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color.fromARGB(255, 5, 5, 5),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Recommendations",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 5,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Text(
            "FOR YOU",
            style: TextStyle(
              color: Colors.amber.shade200,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
