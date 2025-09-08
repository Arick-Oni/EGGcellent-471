import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/buyer_check_login.dart';
import 'package:video_player/video_player.dart';
import 'Responsive_helper.dart';
import 'newAuth/farmer_log_in.dart';

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  late AnimationController _idleAnimationController;
  late Animation<double> _idleAnimation;
  bool _isFarmerHovered = false;
  bool _isBuyerHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _idleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _idleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _idleAnimationController,
      curve: Curves.easeInOut,
    ));
    _idleAnimationController.repeat(reverse: true);
  }

  void _initializeVideo() async {
    try {
      // Try asset approach first (works locally)
      _videoController = VideoPlayerController.asset('assets/videos/vdo.mp4');
      await _videoController.initialize();

      _videoController.setLooping(true);
      _videoController.setVolume(0.0);
      _videoController.play();

      setState(() {
        _isVideoInitialized = true;
      });

      print('Video loaded from assets');
    } catch (e) {
      print('Asset video failed, trying web directory: $e');
      try {
        // Fallback to web directory (works on Vercel)
        _videoController = VideoPlayerController.network('/videos/vdo.mp4');
        await _videoController.initialize();

        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();

        setState(() {
          _isVideoInitialized = true;
        });

        print('Video loaded from web directory');
      } catch (e2) {
        print('Both video loading methods failed: $e2');
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _idleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleBuyerTap() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuyerLogin()),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isHovered,
    required ValueChanged<bool> onHover,
  }) {
    return AnimatedBuilder(
      animation: _idleAnimation,
      builder: (context, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => onHover(true),
          onExit: (_) => onHover(false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              padding: const EdgeInsets.all(24),
              transform: Matrix4.identity()
                ..scale(isHovered ? 1.05 : 1.0 + (_idleAnimation.value * 0.02))
                ..translate(0.0, isHovered ? -5.0 : _idleAnimation.value * 2.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(isHovered ? 0.8 : 0.6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isHovered
                      ? Colors.yellow.withOpacity(1.0)
                      : Colors.yellow
                          .withOpacity(0.8 + (_idleAnimation.value * 0.2)),
                  width: isHovered ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(
                        isHovered ? 0.8 : 0.4 + (_idleAnimation.value * 0.3)),
                    blurRadius:
                        isHovered ? 50 : 35 + (_idleAnimation.value * 10),
                    spreadRadius:
                        isHovered ? 5 : 3 + (_idleAnimation.value * 2),
                    offset: Offset(
                        0, isHovered ? 12 : 8 + (_idleAnimation.value * 2)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      radius: isHovered ? 45 : 40,
                      backgroundColor:
                          isHovered ? Colors.yellow[600] : Colors.yellow[700],
                      child: Icon(
                        icon,
                        size: isHovered ? 45 : 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isHovered ? 28 : 26,
                            fontWeight: FontWeight.bold,
                            color: isHovered
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFFE5D4B1),
                            letterSpacing: 1,
                            fontFamily: 'Meriva',
                            shadows: [
                              Shadow(
                                blurRadius: isHovered ? 6.0 : 4.5,
                                color: Colors.black,
                                offset: Offset(isHovered ? 1.5 : 1.2,
                                    isHovered ? 1.5 : 1.2),
                              ),
                            ],
                          ),
                          child: Text(title),
                        ),
                        const SizedBox(height: 10),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isHovered ? 17 : 16,
                            color: isHovered
                                ? const Color(0xFFFFF8E1)
                                : const Color(0xFFE8DCC6),
                            height: 1.4,
                            fontFamily: 'Meriva',
                            shadows: [
                              Shadow(
                                blurRadius: isHovered ? 6.0 : 4.5,
                                color: Colors.black,
                                offset: Offset(isHovered ? 1.5 : 1.2,
                                    isHovered ? 1.5 : 1.2),
                              ),
                            ],
                          ),
                          child: Text(subtitle),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isHovered ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: isHovered ? Colors.white : Colors.yellow,
                        size: isHovered ? 24 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth =
        ResponsiveHelper.isDesktop(context) ? 600 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Video
          if (_isVideoInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // Dark overlay to make text more readable
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Main content
          Column(
            children: [
              AppBar(
                title: const Text(
                  "Choose Your Role",
                  style: TextStyle(
                    fontFamily: 'Meriva',
                    color: Color(0xFFF8F0E3), // Very light, subtle beige
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// Farmer Card
                          _buildRoleCard(
                            icon: Icons.agriculture,
                            title: "Farmer",
                            subtitle: "Sell your products & manage your farm",
                            isHovered: _isFarmerHovered,
                            onHover: (hovered) {
                              setState(() {
                                _isFarmerHovered = hovered;
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            },
                          ),

                          /// Buyer Card
                          _buildRoleCard(
                            icon: Icons.shopping_cart,
                            title: "Buyer",
                            subtitle:
                                "Purchase products directly from local farmers",
                            isHovered: _isBuyerHovered,
                            onHover: (hovered) {
                              setState(() {
                                _isBuyerHovered = hovered;
                              });
                            },
                            onTap: _handleBuyerTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
