import 'package:flutter/material.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AddTraysSize extends StatelessWidget {
  const AddTraysSize({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Egg Tray Size",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child:
                  CustomTextField(hintText: "Standard Egg Tray Size: 30 Eggs"),
            ),
            CustomButton(text: "Add", onClick: () {})
          ],
        ),
      ),
    );
  }
}
