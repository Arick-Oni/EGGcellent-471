import 'package:flutter/material.dart';
import 'package:poultry_app/screens/farmsettings/addeggtraysize.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/floatbutton.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class EggTraySize extends StatelessWidget {
  const EggTraySize({super.key});

  @override
  Widget build(BuildContext context) {
    List cat = [
      "30 Eggs",
      "20 Eggs",
      "25 Eggs",
    ];
    return Scaffold(
      floatingActionButton: FloatedButton(onTap: () {
        NextScreen(context, AddTraysSize());
      }),
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Egg Tray Size",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            addVerticalSpace(10),
            Divider(
              height: 0,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cat.length,
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                  );
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      cat[index],
                      style: bodyText17w500(color: black),
                    ),
                  );
                }),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}
