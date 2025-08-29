import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import 'package:poultry_app/widgets/navigation.dart';

class AddMortalityPage extends StatefulWidget {
  const AddMortalityPage({super.key});

  @override
  State<AddMortalityPage> createState() => _AddMortalityPageState();
}

class _AddMortalityPageState extends State<AddMortalityPage> {
  final date = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          
          title: 'Batch',
        ),
      ),
      body: Column(
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
                        "Add Mortality",
                        style: bodyText22w600(color: black),
                      ),
                    ),
                    addVerticalSpace(20),
                    CustomTextField(
                      hintText: "Date",
                      suffix: true,
                      controller: date,
                    ),
                    CustomTextField(hintText: "Mortality"),
                    CustomTextField(hintText: "Description")
                  ]),
            ),
          ]),
          // addVerticalSpace(height(context) * .22),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CustomButton(
                text: "Add", onClick: () {}, width: width(context), height: 55),
          )
        ],
      ),
    );
  }
}
