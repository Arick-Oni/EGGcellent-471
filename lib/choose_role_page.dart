import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/buyer_check_login.dart';
import 'Responsive_helper.dart';
import 'newAuth/farmer_log_in.dart';

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  State<ChooseRolePage> createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
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
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.yellow.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.yellow[700],
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.yellow,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = ResponsiveHelper.isDesktop(context) ? 600 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Choose Your Role"),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Continue as:",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[700],
                  ),
                ),
                const SizedBox(height: 40),

                /// Farmer Card
                _buildRoleCard(
                  icon: Icons.agriculture,
                  title: "Farmer",
                  subtitle: "Sell your products and manage your farm",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),

                /// Buyer Card
                _buildRoleCard(
                  icon: Icons.shopping_cart,
                  title: "Buyer",
                  subtitle: "Purchase products directly from local farmers",
                  onTap: _handleBuyerTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
