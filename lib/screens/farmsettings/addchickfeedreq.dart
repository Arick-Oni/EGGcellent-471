import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';

class AddChickFeedReq extends StatefulWidget {
  const AddChickFeedReq({super.key});

  @override
  State<AddChickFeedReq> createState() => _AddChickFeedReqState();
}

class _AddChickFeedReqState extends State<AddChickFeedReq> {
  List breed = ["Broiler", "Deshi", "Layer", "Breeder Farm"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GeneralAppBar(
          
          title: "Chick Feed Requirement",
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height(context) - 135,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    addVerticalSpace(20),
                    CustomTextField(hintText: "Day"),
                    CustomDropdown(list: breed, height: 58, hint: "Breed"),
                    CustomDropdown(
                        list: ['Pre Starter', 'Starter', 'Phase-1', 'Phase-2'],
                        height: 58,
                        hint: "Feed Type"),
                    CustomTextField(hintText: "Grams"),
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
