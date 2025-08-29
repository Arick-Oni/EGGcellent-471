import 'package:flutter/material.dart';
import 'package:poultry_app/screens/mainscreens/postad.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/otherwidgets.dart';

class HomepageSell extends StatelessWidget {
  const HomepageSell({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> sell = [
      {"image": "assets/images/birds.png", "name": "Broiler"},
      {"image": "assets/images/deshi.png", "name": "Deshi"},
      {"image": "assets/images/egg.png", "name": "Eggs"},
      {"image": "assets/images/eggs.png", "name": "Hatching Eggs"},
      {"image": "assets/images/chick.png", "name": "Chicks"},
      {"image": "assets/images/duck.png" , "name" : "Ducks"},
    ];

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          title: "What are you selling?",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: GridView.builder(
            itemCount: sell.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9, // Slightly taller than wide to accommodate text
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                NextScreen(
                  context,
                  PostAdPage(
                    //name: sell[index]['name']!,
                  ),
                );
              },
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            sell[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            sell[index]['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: darkGray,
                            ),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}