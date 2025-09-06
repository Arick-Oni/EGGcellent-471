import 'package:flutter/material.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/rewards/games/quiz_page.dart';
import 'package:poultry_app/rewards/games/spin_wheel_page.dart';
import 'package:poultry_app/rewards/games/snake_game_page.dart';
import 'package:poultry_app/rewards/games/scratch_page.dart';

// Elegant Games hub page with larger, responsive icons and glossy cards
class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: const Color(0xFF1A1508),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF12151C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, cons) {
            // Responsive sizing using LayoutBuilder (avoid hardcoded sizes) [10][12]
            final maxW = cons.maxWidth;
            final isTablet = maxW >= 720;
            final cardW = isTablet ? 240.0 : 190.0;
            final cardH = isTablet ? 165.0 : 135.0;
            final iconSize = isTablet ? 64.0 : 52.0; // big, visible icons
            final faintSize = isTablet ? 140.0 : 110.0;
            final titleSize = isTablet ? 20.0 : 17.0;

            Widget gameCard({
              required IconData icon,
              required String title,
              required VoidCallback onTap,
              required List<Color> gradient,
            }) {
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Ink(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: gradient.first.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -18,
                        bottom: -18,
                        child: Icon(icon,
                            size: faintSize,
                            color: Colors.black.withOpacity(0.08)),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: Colors.black87, size: iconSize),
                            const SizedBox(width: 12),
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w900,
                                fontSize: titleSize,
                                letterSpacing: 0.3,
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

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    gameCard(
                      icon: Icons.sports_esports_rounded,
                      title: 'Snake',
                      onTap: () => NextScreen(context, const SnakeGamePage()),
                      gradient: const [Color(0xFF7CFFB2), Color(0xFF2ED08E)],
                    ),
                    gameCard(
                      icon: Icons.casino_rounded,
                      title: 'Spin Wheel',
                      onTap: () => NextScreen(context, const SpinWheelPage()),
                      gradient: const [Color(0xFFFFD27F), Color(0xFFFF9F43)],
                    ),
                    gameCard(
                      icon: Icons.quiz_rounded,
                      title: 'Quiz',
                      onTap: () => NextScreen(context, const QuizPage()),
                      gradient: const [Color(0xFF7FB3FF), Color(0xFF4EA1FF)],
                    ),
                    gameCard(
                      icon: Icons.style_rounded,
                      title: 'Scratch Card',
                      onTap: () => NextScreen(context, const ScratchPage()),
                      gradient: const [Color(0xFFFF9AD5), Color(0xFFFF6EB2)],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
