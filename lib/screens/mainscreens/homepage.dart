import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/order/editorderedproduct.dart';
import 'package:poultry_app/newAuth/order/trackorder.dart';
import 'package:poultry_app/screens/mainscreens/filter.dart';
import 'package:poultry_app/screens/mainscreens/manual_controls_page.dart';
import 'package:poultry_app/screens/mainscreens/postad.dart';
import 'package:poultry_app/screens/mainscreens/todayrate.dart';
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
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _buttonAnimations;

  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadBuyerLoginStatus();
    selectedCategory = null;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    try {
      // Initialize animations
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _staggerController = AnimationController(
        duration: const Duration(milliseconds: 1500),
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

      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );

      // Initialize staggered button animations
      _buttonAnimations = [];
      for (int i = 0; i < 8; i++) {
        _buttonAnimations.add(
          Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _staggerController,
              curve: Interval(
                i * 0.1,
                0.8 + (i * 0.02),
                curve: Curves.elasticOut,
              ),
            ),
          ),
        );
      }

      _animationsInitialized = true;

      // Start animations after initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.forward();
          _pulseController.repeat(reverse: true);
          _staggerController.forward();
        }
      });
    } catch (e) {
      print('Animation initialization error: $e');
      _animationsInitialized = false;
    }
  }

  @override
  void dispose() {
    if (_animationsInitialized) {
      _animationController.dispose();
      _pulseController.dispose();
      _staggerController.dispose();
    }
    super.dispose();
  }

  // Helper method to safely get animation values
  double _safeAnimationValue(Animation<double> animation, double defaultValue) {
    if (!_animationsInitialized || !mounted) return defaultValue;

    try {
      final value = animation.value;
      if (value.isNaN || value.isInfinite) return defaultValue;
      return value.clamp(0.0, 2.0); // Clamp to reasonable bounds
    } catch (e) {
      return defaultValue;
    }
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
    if (!_animationsInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1508),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1508),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: GeneralAppBar(),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final slideValue = _safeAnimationValue(_slideAnimation, 0.0);
          final fadeValue = _safeAnimationValue(_fadeAnimation, 1.0);

          return Transform.translate(
            offset: Offset(0, slideValue),
            child: Opacity(
              opacity: fadeValue,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Modern Hero Section with Enhanced Glassmorphism
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A1508),
                            Color(0xFF2E2418),
                            Color(0xFF3E3425),
                            Color(0xFF2E2418),
                            Color(0xFF1A1508),
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Modern App title with glassmorphism card
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                final pulseValue =
                                    _safeAnimationValue(_pulseAnimation, 1.0);
                                return Transform.scale(
                                  scale: pulseValue,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.05),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFC107)
                                              .withOpacity(0.3),
                                          blurRadius: 32,
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [
                                              Color(0xFFFFC107),
                                              Color(0xFFFFD54F),
                                              Color(0xFFFF8F00),
                                              Color(0xFFFFA000),
                                            ],
                                          ).createShader(bounds),
                                          child: const Text(
                                            "EggCellent",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "🐣",
                                          style: TextStyle(
                                            fontSize: 28,
                                            shadows: [
                                              Shadow(
                                                color: const Color(0xFFFFC107)
                                                    .withOpacity(0.5),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Modern subtitle with better typography
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: const Text(
                                "Premium Poultry Marketplace & Smart Farm Management",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFFFF8E1),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Enhanced Action Buttons Grid with improved spacing
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                final scaleValue =
                                    _safeAnimationValue(_scaleAnimation, 1.0);
                                return Transform.scale(
                                  scale: scaleValue,
                                  child: _buildActionButtonsGrid(),
                                );
                              },
                            ),

                            const SizedBox(height: 40),

                            // Enhanced Hero Banner
                            if (isBuyerLoggedIn != false)
                              _buildEnhancedHeroBanner(),

                            const SizedBox(height: 40),

                            // Recommendations Section Header
                            if (isBuyerLoggedIn != false) _buildSectionHeader(),
                          ],
                        ),
                      ),
                    ),

                    // Modern Recommendations section with enhanced glassmorphism
                    if (isBuyerLoggedIn != false)
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          final slideValue =
                              _safeAnimationValue(_slideAnimation, 0.0);
                          final fadeValue =
                              _safeAnimationValue(_fadeAnimation, 1.0);

                          return Transform.translate(
                            offset: Offset(0, slideValue * 0.3),
                            child: Opacity(
                              opacity: fadeValue,
                              child: Container(
                                margin: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.03),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.15),
                                      blurRadius: 32,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(31),
                                  child: Container(
                                    height: 620,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF1A1F2E)
                                              .withOpacity(0.9),
                                          const Color(0xFF0A0E1A)
                                              .withOpacity(0.95),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Background pattern
                                        Positioned.fill(
                                          child: AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              final pulseValue =
                                                  _safeAnimationValue(
                                                      _pulseAnimation, 1.0);
                                              return Container(
                                                decoration: BoxDecoration(
                                                  gradient: RadialGradient(
                                                    center: Alignment.topRight,
                                                    radius: 1.5,
                                                    colors: [
                                                      Color(0xFF6366F1)
                                                          .withOpacity(0.1 *
                                                              pulseValue.clamp(
                                                                  0.5, 1.5)),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Main content
                                        RecommendationWidget(
                                            category: selectedCategory),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Modern Floating Action Button with enhanced design
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulseValue = _safeAnimationValue(_pulseAnimation, 1.0);
          return Transform.scale(
            scale: pulseValue,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFC107),
                    Color(0xFFFF8F00),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  _showQuickActionsBottomSheet(context);
                },
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1F2E).withOpacity(0.95),
              const Color(0xFF0A0E1A).withOpacity(0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (isBuyerLoggedIn != true)
                    _buildQuickActionButton(
                      "Add Product",
                      Icons.add_box_rounded,
                      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                      () => NextScreen(context, PostAdPage()),
                    ),
                  _buildQuickActionButton(
                    "Check Rates",
                    Icons.trending_up_rounded,
                    [const Color(0xFF667eea), const Color(0xFF764ba2)],
                    () => NextScreen(context, TodayRatePage()),
                  ),
                  if (isBuyerLoggedIn != true)
                    _buildQuickActionButton(
                      "Live Monitor",
                      Icons.monitor_heart_outlined,
                      [const Color(0xFF00b09b), const Color(0xFF96c93d)],
                      () => NextScreen(context, const LiveMonitoringPage()),
                    ),
                  if (isBuyerLoggedIn == true)
                    _buildQuickActionButton(
                      "Track Order",
                      Icons.local_shipping_rounded,
                      [
                        const Color(0xFFf093fb),
                        const Color.fromARGB(255, 190, 15, 115)
                      ],
                      () => NextScreen(context, Trackorder()),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onPressed();
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsGrid() {
    final buttons = <Map<String, dynamic>>[];

    buttons.add({
      'text': "Today's Rate",
      'icon': Icons.trending_up_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
      'onPressed': () => NextScreen(context, TodayRatePage()),
    });

    if (isBuyerLoggedIn != true) {
      buttons.add({
        'text': "Sell",
        'icon': Icons.sell_rounded,
        'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        'onPressed': () => NextScreen(context, PostAdPage()),
      });
    }

    if (isBuyerLoggedIn == true) {
      buttons.addAll([
        {
          'text': "Track Order",
          'icon': Icons.local_shipping_rounded,
          'gradient': [
            const Color(0xFFf093fb),
            const Color.fromARGB(255, 190, 15, 115)
          ],
          'onPressed': () => NextScreen(context, Trackorder()),
        },
        {
          'text': "Filter",
          'icon': Icons.filter_list_rounded,
          'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
          'onPressed': () => NextScreen(context, FilterScreen()),
        },
      ]);
    }

    if (isBuyerLoggedIn != true) {
      buttons.add({
        'text': "Ordered Products",
        'icon': Icons.shopping_bag_rounded,
        'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
        'onPressed': () => NextScreen(context, Editorderedproduct()),
      });
      buttons.add({
        'text': "Automation Settings",
        'icon': Icons.settings_applications_rounded,
        'gradient': [
          const Color.fromARGB(255, 8, 224, 55),
          const Color(0xFFfee140)
        ],
        'onPressed': () => NextScreen(context, const AutomationSettings()),
      });
      buttons.add({
        'text': "Live Monitoring",
        'icon': Icons.monitor_heart_outlined,
        'gradient': [const Color(0xFF00b09b), const Color(0xFF96c93d)],
        'onPressed': () => NextScreen(context, const LiveMonitoringPage()),
      });
      buttons.add({
        'text': "Manual Control",
        'icon': Icons.touch_app_rounded,
        'gradient': [
          const Color.fromARGB(255, 97, 176, 0),
          const Color(0xFF96c93d)
        ],
        'onPressed': () =>
            NextScreen(context, ManualControlsPage(selectedCoop: 'coop1')),
      });
      buttons.add({
        'text': "Camera Stream",
        'icon': Icons.videocam_rounded,
        'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
        'onPressed': () => NextScreen(context, const ESP32CameraStreamPage()),
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ResponsiveHelper.isDesktop(context)
          ? _buildDesktopGrid(buttons)
          : _buildMobileGrid(buttons),
    );
  }

  Widget _buildDesktopGrid(List<Map<String, dynamic>> buttons) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _buttonAnimations[index % _buttonAnimations.length],
              builder: (context, child) {
                final animationValue = _safeAnimationValue(
                    _buttonAnimations[index % _buttonAnimations.length], 1.0);
                return Transform.scale(
                  scale: animationValue,
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildEnhancedActionButton(
                      buttons[index]['text'],
                      buttons[index]['icon'],
                      buttons[index]['gradient'],
                      buttons[index]['onPressed'],
                      index,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileGrid(List<Map<String, dynamic>> buttons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isTablet(context) ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isTablet(context) ? 1.2 : 1.1,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _buttonAnimations[index % _buttonAnimations.length],
          builder: (context, child) {
            final animationValue = _safeAnimationValue(
                _buttonAnimations[index % _buttonAnimations.length], 1.0);
            return Transform.scale(
              scale: animationValue,
              child: Opacity(
                opacity: animationValue,
                child: _buildEnhancedActionButton(
                  buttons[index]['text'],
                  buttons[index]['icon'],
                  buttons[index]['gradient'],
                  buttons[index]['onPressed'],
                  index,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedActionButton(
    String text,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onPressed,
    int index,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (context, scale, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onPressed,
                  child: Container(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.isDesktop(context) ? 20 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container with enhanced styling
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.isDesktop(context) ? 16 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: ResponsiveHelper.isDesktop(context) ? 28 : 24,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                ResponsiveHelper.isDesktop(context) ? 16 : 12),

                        // Enhanced text with better styling
                        Flexible(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveHelper.isDesktop(context) ? 14 : 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.4),
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
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeroBanner() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        final slideValue = _safeAnimationValue(_slideAnimation, 0.0);
        final fadeValue = _safeAnimationValue(_fadeAnimation, 1.0);

        return Transform.translate(
          offset: Offset(0, slideValue * 0.5),
          child: Opacity(
            opacity: fadeValue,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: ResponsiveHelper.isDesktop(context) ? 300 : 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(31),
                child: Stack(
                  children: [
                    // Background Image with parallax effect
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final pulseValue =
                              _safeAnimationValue(_pulseAnimation, 1.0);
                          final scaleValue = 1.0 + (pulseValue - 1.0) * 0.02;
                          return Transform.scale(
                            scale: scaleValue.clamp(0.98, 1.02),
                            child: Image.asset(
                              "assets/images/happy.png",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),
                    // Animated gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                    // Glassmorphism overlay with animation
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulseValue =
                            _safeAnimationValue(_pulseAnimation, 1.0);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.transparent,
                                Color(0xFFFFC107).withOpacity(
                                    0.1 * pulseValue.clamp(0.5, 1.5)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Modern floating content
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFC107),
                                    Color(0xFFFF8F00)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFC107)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.agriculture_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Smart Poultry Management",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Advanced monitoring & automation system",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF00BCD4).withOpacity(0.4),
                                ),
                              ),
                              child: const Text(
                                "LIVE",
                                style: TextStyle(
                                  color: Color(0xFF00BCD4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
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
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC107),
                    Color(0xFFFF8F00),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommendations",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFC107).withOpacity(0.2),
                          const Color(0xFFFF8F00).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFC107).withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      "CURATED FOR YOU",
                      style: TextStyle(
                        color: Color(0xFFFFF8E1),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
