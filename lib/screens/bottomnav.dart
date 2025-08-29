import 'package:flutter/material.dart';
import 'package:poultry_app/screens/Graphdata.dart';
import 'package:poultry_app/screens/Inventory%20tracker/inventory_tracker.dart';
import 'package:poultry_app/screens/mainscreens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List body = [
    HomePage(),
    InventoryTrackerPage(),
    GraphData(),
  ];

  int index = 0;
  bool? isBuyerLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadBuyerLoginStatus();
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double navHeight = 72.0;

    if (isBuyerLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: body[index],
      bottomNavigationBar: (isBuyerLoggedIn == true)
          ? null
          : SizedBox(
        height: navHeight + bottomPadding,
        child: Column(
          children: [
            Divider(height: 1, color: Colors.grey[300]),
            Expanded(
              child: Container(
                color: Colors.yellowAccent.shade200,
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Row(
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_outlined,
                      label: "Dashboard",
                      isSelected: index == 0,
                      onTap: () => setState(() => index = 0),
                    ),
                    _buildNavItem(
                      icon: Icons.inventory_2_outlined,
                      label: "Inventory Tracker",
                      isSelected: index == 1,
                      onTap: () => setState(() => index = 1),
                    ),
                    _buildNavItem(
                      icon: Icons.auto_graph,
                      label: "Graphs",
                      isSelected: index == 2,
                      onTap: () => setState(() => index = 2),
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.cyanAccent[400] : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.black
                      : Colors.black.withOpacity(0.5),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
