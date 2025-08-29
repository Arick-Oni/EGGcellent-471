import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddBodyWeight extends StatefulWidget {
  const AddBodyWeight({super.key});

  @override
  State<AddBodyWeight> createState() => _AddBodyWeightState();
}

class _AddBodyWeightState extends State<AddBodyWeight> {
  final date = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpace(20),
                    Center(
                      child: Text(
                        "Add Body Weight",
                        style: bodyText22w600(color: black),
                      ),
                    ),
                    addVerticalSpace(20),
                    CustomTextField(
                      hintText: "Date",
                      suffix: true,
                      controller: date,
                    ),
                    CustomTextField(hintText: "Average Body Weight (in grams)"),
                  ]),
            ),
          ]),
          // addVerticalSpace(height(context) * .325),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CustomButton(
                text: "Save",
                onClick: () {},
                width: width(context),
                height: 55),
          )
        ],
      ),
    );
  }
}
