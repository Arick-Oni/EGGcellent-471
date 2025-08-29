import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AddCustomer extends StatelessWidget {
  const AddCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Add Customer",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) * 0.88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    addVerticalSpace(20),
                    CustomTextField(hintText: "Name"),
                    CustomTextField(hintText: "Contact Number"),
                  ],
                ),
                CustomButton(text: "Add", onClick: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
